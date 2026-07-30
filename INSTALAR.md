# Instalação

## 1. Copiar para o repositório

```bash
# a partir da raiz do seu projeto
cp -r /caminho/para/spec-base/specs .
cp -r /caminho/para/spec-base/scripts .
cp -r /caminho/para/spec-base/.claude/skills .claude/
cp -r /caminho/para/spec-base/.claude/hooks .claude/
cp -r /caminho/para/spec-base/.claude/agents .claude/
```

Se `.claude/` ainda não existir: `mkdir -p .claude`.

Se já houver `.claude/skills/`, os cinco diretórios `spec-*` apenas se somam aos existentes.

## 2. Rodar o bootstrap

Abra o Claude Code na raiz do projeto e cole o prompt de `BOOTSTRAP.md`.

## 3. (Opcional) Modo estrito

Só depois do bootstrap, e só se você quiser bloqueio real:

```bash
# requer jq instalado
jq -s '.[0] * .[1]' .claude/settings.json /caminho/para/spec-base/.claude/settings.json.exemplo \
  > /tmp/s.json && mv /tmp/s.json .claude/settings.json
chmod +x .claude/hooks/require-spec.sh
```

Se `.claude/settings.json` não existir, copie o exemplo direto.

**Ajuste `PROTEGIDOS_REGEX` no topo do hook** para os diretórios de código reais do projeto.
O padrão cobre `src/`, `app/`, `lib/`, `api/`, `packages/`, `services/`.

Teste antes de confiar:

```bash
echo '{"tool_input":{"file_path":"'"$PWD"'/src/foo.ts"}}' | \
  CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/require-spec.sh ; echo "exit=$?"
# esperado: exit=2 com a mensagem de bloqueio
```

### Escapes do modo estrito

| Situação | Como |
|---|---|
| Mudança trivial (GREEN) | `echo "GREEN: corrige typo no log" > specs/ACTIVE.md` |
| Emergência | `git commit --no-verify` não ajuda aqui — desligue o hook em `settings.json` |
| Voltar ao normal | `echo "nenhuma" > specs/ACTIVE.md` |

## 4. Cadeia de agentes

Os três subagentes (`planejador` opus · `executor` sonnet · `validador` sonnet read-only)
ficam disponíveis assim que você reiniciar o Claude Code. Confira com `/agents`.

O `validador` lê a spec antes do código de propósito — não dê a ele `Write` nem `Edit`.

## 5. Versionar

```bash
git add specs scripts .claude CLAUDE.md
git commit -m "chore: base de especificações spec-driven"
```

`specs/mudancas/` **fica no repositório**. É o histórico do porquê — o ativo mais valioso
da base depois de seis meses.

## O que NÃO fazer

- Não rode o bootstrap com trabalho não commitado. Ele edita `CLAUDE.md`.
- Não ligue o modo estrito antes de a governança estar preenchida — você vai se bloquear
  com uma spec vazia.
- Não deixe `specs/ui/` num projeto sem frontend. Seção vazia é ruído que compete por
  contexto com o que importa.

## Limites honestos

O disparo automático de skill é **probabilístico**: depende de o Claude Code casar o pedido
com a `description` da skill. O hook é **determinístico**: ou bloqueia ou não.

Se a garantia importa, use o modo estrito. Se você só quer estrutura e disciplina assistida,
o consultivo entrega 80% com zero atrito — e você pode invocar a skill pelo nome sempre
que quiser certeza.
