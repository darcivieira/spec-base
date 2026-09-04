#!/usr/bin/env sh
# Instala a base de specs num projeto existente, sem vínculo de git.
#
#   curl -fsSL https://raw.githubusercontent.com/darcivieira/spec-base/master/install.sh | sh
#
# Repositório privado? Use o gh, que aproveita a autenticação que você já tem:
#   sh -c "$(gh api repos/darcivieira/spec-base/contents/install.sh --jq .content | base64 -d)"
#
# O que ele copia: specs/ · scripts/ · .claude/{skills,hooks,agents} · .spec-base.json
# O que ele NÃO copia: INSTALAR.md, BOOTSTRAP.md, ATUALIZAR.md, MIGRAR-IDENTIFICADOR.md,
# AGENTS.md.exemplo, .github/ — são documentação do kit, não do seu projeto. Os caminhos
# para eles ficam impressos no fim.
#
# Nada é sobrescrito em silêncio: arquivo que já existe e difere vira <nome>.novo, e a lista
# aparece no relatório final para você resolver.

set -eu

REPO="${SPEC_BASE_REPO:-https://github.com/darcivieira/spec-base.git}"
REF="${SPEC_BASE_REF:-master}"
DESTINO="$(pwd)"

# SPEC_BASE_YES=1 responde "sim" aos avisos, para automação. Sem terminal e sem essa
# variável, a resposta é "não": um instalador que segue sozinho no escuro é pior que um
# que não instala.
CONFIRMA="${SPEC_BASE_YES:-0}"

vermelho() { printf '\033[31m%s\033[0m\n' "$*" >&2; }
verde()    { printf '\033[32m%s\033[0m\n' "$*"; }
amarelo()  { printf '\033[33m%s\033[0m\n' "$*"; }

# --------------------------------------------------------------------- pré-condições

confirmar() {
  [ "$CONFIRMA" = "1" ] && return 0
  printf 'Continuar mesmo assim? [s/N] '
  # Lê do terminal, não da stdin — que num `curl | sh` é o próprio script.
  if ! { read -r resposta </dev/tty; } 2>/dev/null; then
    echo
    echo "(sem terminal para perguntar — use SPEC_BASE_YES=1 se quiser seguir assim)"
    return 1
  fi
  case "$resposta" in [sSyY]*) return 0 ;; *) return 1 ;; esac
}

command -v git >/dev/null 2>&1 || { vermelho "erro: git não encontrado."; exit 1; }

if [ ! -d "$DESTINO/.git" ]; then
  amarelo "aviso: $DESTINO não é um repositório git."
  amarelo "A base é feita para ser versionada junto do projeto. Rode 'git init' antes,"
  amarelo "ou siga sabendo que não haverá como desfazer com 'git checkout'."
  confirmar || { echo "abortado."; exit 1; }
fi

# Trabalho não commitado + instalação que mexe em CLAUDE.md é receita de perder alteração.
if [ -d "$DESTINO/.git" ] && [ -n "$(git -C "$DESTINO" status --porcelain 2>/dev/null)" ]; then
  amarelo "aviso: há trabalho não commitado neste repositório."
  amarelo "Commite antes — assim 'git checkout .' desfaz a instalação inteira se você desistir."
  confirmar || { echo "abortado."; exit 1; }
fi

ATUALIZACAO=0
[ -d "$DESTINO/specs" ] && ATUALIZACAO=1

# ------------------------------------------------------------------------- baixar

TMP="$(mktemp -d)"
limpar() { rm -rf "$TMP"; }
trap limpar EXIT INT TERM

echo "Baixando $REPO ($REF)..."
git clone --depth 1 --branch "$REF" --quiet "$REPO" "$TMP/base" 2>/dev/null || {
  vermelho "erro: não consegui clonar $REPO"
  vermelho "Se o repositório for privado, veja o cabeçalho deste script."
  exit 1
}
rm -rf "$TMP/base/.git"

# -------------------------------------------------------------------------- copiar

CRIADOS=0
PULADOS=0
CONFLITOS=""

copiar_arquivo() {
  origem="$1"; alvo="$2"
  mkdir -p "$(dirname "$alvo")"

  if [ ! -e "$alvo" ]; then
    cp "$origem" "$alvo"
    CRIADOS=$((CRIADOS + 1))
    return
  fi

  if cmp -s "$origem" "$alvo"; then
    PULADOS=$((PULADOS + 1))
    return
  fi

  # Existe e difere: nunca sobrescreve. Você decide, com o diff na mão.
  cp "$origem" "$alvo.novo"
  CONFLITOS="$CONFLITOS  ${alvo#"$DESTINO"/}\n"
}

copiar_arvore() {
  sub="$1"
  [ -d "$TMP/base/$sub" ] || return 0
  ( cd "$TMP/base/$sub" && find . -type f -print ) | while IFS= read -r rel; do
    echo "$sub/${rel#./}"
  done > "$TMP/lista"

  while IFS= read -r rel; do
    copiar_arquivo "$TMP/base/$rel" "$DESTINO/$rel"
  done < "$TMP/lista"
}

# O subshell do while acima come as variáveis; conta-se no fim, lendo o disco.
copiar_tudo() {
  for sub in specs scripts .claude/skills .claude/hooks .claude/agents; do
    copiar_arvore "$sub"
  done
  copiar_arquivo "$TMP/base/.spec-base.json" "$DESTINO/.spec-base.json"
  [ -f "$TMP/base/.claude/CLAUDE.md.bloco" ] &&
    copiar_arquivo "$TMP/base/.claude/CLAUDE.md.bloco" "$DESTINO/.claude/CLAUDE.md.bloco"
  for exemplo in .claude/settings.json.exemplo .claude/settings.json.exemplo-completo; do
    [ -f "$TMP/base/$exemplo" ] && copiar_arquivo "$TMP/base/$exemplo" "$DESTINO/$exemplo"
  done
  return 0
}

echo "Instalando em $DESTINO..."
copiar_tudo

chmod +x "$DESTINO"/.claude/hooks/*.sh 2>/dev/null || true
chmod +x "$DESTINO"/scripts/*.py 2>/dev/null || true

NOVOS="$(find "$DESTINO/specs" "$DESTINO/scripts" "$DESTINO/.claude" -name '*.novo' 2>/dev/null | wc -l | tr -d ' ')"
[ -f "$DESTINO/.spec-base.json.novo" ] && NOVOS=$((NOVOS + 1))

# ----------------------------------------------------------------------- relatório

echo
if [ "$ATUALIZACAO" -eq 1 ]; then
  verde "Base atualizada."
else
  verde "Base instalada."
fi

if [ "$NOVOS" -gt 0 ]; then
  echo
  amarelo "$NOVOS arquivo(s) já existiam e diferiam. Nada foi sobrescrito — as versões novas"
  amarelo "ficaram com sufixo .novo, para você comparar e decidir:"
  echo
  find "$DESTINO/specs" "$DESTINO/scripts" "$DESTINO/.claude" -name '*.novo' 2>/dev/null |
    sed "s|^$DESTINO/|  |"
  [ -f "$DESTINO/.spec-base.json.novo" ] && echo "  .spec-base.json.novo"
  echo
  echo "  diff <arquivo> <arquivo>.novo    # comparar"
  echo "  find . -name '*.novo' -delete    # descartar todas as versões novas"
fi

echo
echo "Próximo passo:"
echo
if [ "$ATUALIZACAO" -eq 1 ]; then
  echo "  1. Resolva os .novo acima, se houver"
  echo "  2. python3 scripts/spec_check.py"
  echo "  3. Procedimento completo de atualização:"
  echo "     https://github.com/darcivieira/spec-base/blob/$REF/ATUALIZAR.md"
else
  echo "  1. Abra o Claude Code na raiz deste projeto"
  echo "  2. Rode a skill spec-bootstrap — ela entrevista você e preenche a base"
  echo "     O prompt pronto está em:"
  echo "     https://github.com/darcivieira/spec-base/blob/$REF/BOOTSTRAP.md"
  echo
  echo "  Nada bloqueia nada até você escolher no bootstrap: o .spec-base.json vem"
  echo "  com os defaults conservadores."
fi
echo
echo "Instalação e guardas em detalhe:"
echo "  https://github.com/darcivieira/spec-base/blob/$REF/INSTALAR.md"
