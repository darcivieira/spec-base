#!/usr/bin/env bash
# Bloqueia edições em código de produção quando não há mudança especificada e aprovada.
# Registrar em .claude/settings.json sob hooks.PreToolUse, matcher "Edit|Write".
# Exit 0 = permite | Exit 2 = nega e devolve a mensagem ao agente.
#
# Configuração em .spec-base.json -> caminhos. Sem o arquivo, valem os defaults abaixo.

set -uo pipefail
input=$(cat)

RAIZ="${CLAUDE_PROJECT_DIR:-.}"
CONFIG="$RAIZ/.spec-base.json"

# --- defaults, usados quando não há .spec-base.json ou jq ---------------------
PROTEGIDOS_REGEX='(^|/)(src|app|lib|api|packages|services)/'
LIVRES_REGEX='(^|/)(tests?|__tests__|specs)/|\.(test|spec)\.[jt]sx?$|_test\.py$'
IMUTAVEIS_REGEX=''
REF_PRINCIPAL='origin/main'

if [ -f "$CONFIG" ] && command -v jq >/dev/null 2>&1; then
  # As listas são unidas por "|" e viram uma alternância de regex estendida.
  v=$(jq -r '(.caminhos.protegidos // []) | join("|")' "$CONFIG" 2>/dev/null)
  [ -n "$v" ] && [ "$v" != "null" ] && PROTEGIDOS_REGEX="$v"
  v=$(jq -r '(.caminhos.livres // []) | join("|")' "$CONFIG" 2>/dev/null)
  [ "$v" != "null" ] && LIVRES_REGEX="$v"
  v=$(jq -r '(.caminhos.imutaveis_apos_publicacao // []) | join("|")' "$CONFIG" 2>/dev/null)
  [ "$v" != "null" ] && IMUTAVEIS_REGEX="$v"
  v=$(jq -r '.caminhos.ref_principal // ""' "$CONFIG" 2>/dev/null)
  [ -n "$v" ] && [ "$v" != "null" ] && REF_PRINCIPAL="$v"
fi
# -----------------------------------------------------------------------------

path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
[ -z "$path" ] && exit 0

rel="${path#"$RAIZ"/}"

# --- Arquivos imutáveis depois de publicados ---------------------------------
# Criar é livre — é o fluxo normal de trabalho. Editar o que JÁ RODOU em outro ambiente é
# o caso irrecuperável: deixa ambientes em estados divergentes, sem caminho de volta.
#
# Proxy de "publicado": o arquivo já existe na ref principal, de onde saem os deploys.
# É proxy, não a verdade — migration aplicada só no ambiente local de alguém não é detectada.
#
# Nota deliberada: proteger o diretório inteiro NÃO funciona. Se toda tarefa de banco dispara
# o bloqueio, o controle vira ruído e perde a proteção real.
if [ -n "$IMUTAVEIS_REGEX" ] && printf '%s' "$rel" | grep -Eq "$IMUTAVEIS_REGEX"; then
  if git -C "$RAIZ" cat-file -e "$REF_PRINCIPAL:$rel" 2>/dev/null; then
    cat >&2 <<MSG
BLOQUEADO: '$rel' já está publicado em $REF_PRINCIPAL.
Editar arquivo que outros ambientes já aplicaram deixa esses ambientes em estados
divergentes, sem caminho de volta.

Crie um arquivo novo. Esta regra é ⛔ SEM EXCEÇÃO — nem a declaração GREEN a libera.
Ver specs/governanca/08-guardas.md e 03-limites-agente.md.
MSG
    exit 2
  fi
  exit 0   # ainda não publicado nesta branch: livre
fi

# Fora do código protegido: libera (specs, docs, config)
printf '%s' "$rel" | grep -Eq "$PROTEGIDOS_REGEX" || exit 0

# Caminhos sempre liberados (testes, specs)
[ -n "$LIVRES_REGEX" ] && printf '%s' "$rel" | grep -Eq "$LIVRES_REGEX" && exit 0

SPECS="$RAIZ/specs"
ACTIVE="$SPECS/ACTIVE.md"

if [ ! -f "$ACTIVE" ]; then
  echo "BLOQUEADO: specs/ACTIVE.md não existe. Rode a skill spec-bootstrap." >&2
  exit 2
fi

id=$(head -n1 "$ACTIVE" | tr -d '\r\n[:space:]')

if [ -z "$id" ] || [ "$id" = "nenhuma" ]; then
  cat >&2 <<MSG
BLOQUEADO: não há mudança ativa em specs/ACTIVE.md.
Arquivo alvo: $rel

Classifique a mudança em specs/governanca/03-limites-agente.md.
  - GREEN  -> registre a exceção: echo "GREEN: <motivo>" > specs/ACTIVE.md
  - YELLOW/RED -> rode a skill spec-nova antes de editar código.
MSG
  exit 2
fi

# Exceção GREEN declarada explicitamente
case "$id" in GREEN:*) exit 0 ;; esac

dir="$SPECS/mudancas/$id"
if [ ! -d "$dir" ]; then
  echo "BLOQUEADO: ACTIVE.md aponta para '$id', mas specs/mudancas/$id não existe." >&2
  exit 2
fi

if [ ! -f "$dir/plan.md" ]; then
  echo "BLOQUEADO: a mudança '$id' não tem plan.md. Rode a skill spec-plano." >&2
  exit 2
fi

if ! grep -q '^\*\*Aprovação humana:\*\* ☑' "$dir/plan.md"; then
  cat >&2 <<MSG
BLOQUEADO: o plano de '$id' ainda não foi aprovado.
Apresente o plano ao humano. Após o "pode ir", ele marca a caixa em:
  $dir/plan.md   ->   **Aprovação humana:** ☑ aprovado
MSG
  exit 2
fi

exit 0
