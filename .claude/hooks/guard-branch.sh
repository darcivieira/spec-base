#!/usr/bin/env bash
# Impede que o agente commite, empurre ou faça merge direto em branch protegida.
#
# Registrar em .claude/settings.json sob hooks.PreToolUse, matcher "Bash".
# Exit 0 = permite | Exit 2 = nega e devolve a mensagem ao agente.
#
# Este hook existe mesmo em repositório com branch protection no servidor: lá a proteção
# só age no push, e a essa altura o commit já está na branch errada, com o histórico local
# a desfazer. Aqui o comando não chega a rodar.
#
# Configuração em .spec-base.json -> branches. Sem o arquivo, o default é (main|master).

set -uo pipefail
input=$(cat)

RAIZ="${CLAUDE_PROJECT_DIR:-.}"
CONFIG="$RAIZ/.spec-base.json"

# --- configuração -------------------------------------------------------------
PROTEGIDAS_REGEX='^(main|master)$'
PRINCIPAL='main'
INTEGRACAO=''
TAREFA='<tipo>/<id>-<slug>'

if [ -f "$CONFIG" ] && command -v jq >/dev/null 2>&1; then
  lista=$(jq -r '(.branches.protegidas // []) | join("|")' "$CONFIG" 2>/dev/null)
  [ -n "$lista" ] && [ "$lista" != "null" ] && PROTEGIDAS_REGEX="^($lista)$"
  PRINCIPAL=$(jq -r '.branches.principal // "main"' "$CONFIG" 2>/dev/null)
  INTEGRACAO=$(jq -r '.branches.integracao // ""' "$CONFIG" 2>/dev/null)
  [ "$INTEGRACAO" = "null" ] && INTEGRACAO=''
  t=$(jq -r '.branches.tarefa // ""' "$CONFIG" 2>/dev/null)
  [ -n "$t" ] && [ "$t" != "null" ] && TAREFA="$t"
fi

# Base do PR: a de integração quando existe; a principal quando o fluxo é de duas pontas.
BASE_PR="${INTEGRACAO:-$PRINCIPAL}"
# -----------------------------------------------------------------------------

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$cmd" ] && exit 0

# Só interessam commit, push e merge. Qualquer outro git passa.
printf '%s' "$cmd" | grep -Eq '(^|[;&|(]|[[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+(commit|push|merge)([[:space:]]|$)' || exit 0

# Se o comando muda de diretório antes do git, é lá que a branch é lida.
dir="$RAIZ"
if printf '%s' "$cmd" | grep -Eq '^[[:space:]]*cd[[:space:]]+[^;&|]+'; then
  alvo=$(printf '%s' "$cmd" | sed -E 's/^[[:space:]]*cd[[:space:]]+([^;&|]+).*/\1/' | tr -d '"'"'"' ')
  [ -d "$alvo" ] && dir="$alvo"
fi

# `branch --show-current` responde também em branch ainda sem commit, onde `rev-parse`
# falha — e falhar aqui significaria liberar o primeiro commit direto na branch principal.
branch=$(git -C "$dir" branch --show-current 2>/dev/null || echo "")
[ -z "$branch" ] && branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")

bloqueia() {
  atualiza="git fetch origin && git checkout $BASE_PR && git pull --ff-only origin $BASE_PR"
  cat >&2 <<MSG
BLOQUEADO: $1

  O agente não commita, não empurra e não faz merge direto em branch protegida.
  Não há exceção — nem com autorização na conversa. A saída é criar branch.

  Fluxo:  branch de tarefa  --PR-->  ${INTEGRACAO:+$INTEGRACAO  --PR-->  }$PRINCIPAL

  Para seguir:
    $atualiza
    git checkout -b $TAREFA
    # trabalhe, commite e empurre na branch
    gh pr create --base $BASE_PR

  Ver specs/governanca/09-fluxo-de-trabalho.md.
MSG
  exit 2
}

# --- push: o alvo pode estar explícito no comando -----------------------------
if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+push([[:space:]]|$)'; then
  # captura o refspec depois do remote, ex.: "origin main" ou "origin HEAD:main"
  destino=$(printf '%s' "$cmd" \
    | sed -nE 's/.*git([[:space:]]+-[^[:space:]]+)*[[:space:]]+push[[:space:]]+([^;&|]*)/\2/p' \
    | tr ' ' '\n' | grep -v '^-' | sed -n '2p')
  destino="${destino##*:}"   # HEAD:main -> main

  if [ -n "$destino" ]; then
    printf '%s' "$destino" | grep -Eq "$PROTEGIDAS_REGEX" \
      && bloqueia "push para '$destino'."
  elif printf '%s' "$branch" | grep -Eq "$PROTEGIDAS_REGEX"; then
    # push sem alvo explícito, estando numa branch protegida
    bloqueia "push implícito a partir de '$branch'."
  fi
fi

# --- commit e merge: valem pela branch em que se está -------------------------
if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])git([[:space:]]+-[^[:space:]]+)*[[:space:]]+(commit|merge)([[:space:]]|$)'; then
  printf '%s' "$branch" | grep -Eq "$PROTEGIDAS_REGEX" \
    && bloqueia "commit ou merge estando em '$branch'."
fi

exit 0
