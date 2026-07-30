# Atualizar uma base já em uso

Esta atualização **só adiciona arquivos**. Nada do que você já preencheu é tocado —
nenhum arquivo de `specs/` muda, exceto se você escolher (nada aqui exige).

## O que mudou

| Arquivo | Ação |
|---|---|
| `.claude/agents/planejador.md` | **novo** |
| `.claude/agents/executor.md` | **novo** |
| `.claude/agents/validador.md` | **novo** |
| `.claude/CLAUDE.md.bloco` | **alterado** — nova seção "Cadeia de agentes" |
| `ATUALIZAR.md` | **novo** (este arquivo) |

Tudo em `specs/`, `scripts/`, `.claude/skills/` e `.claude/hooks/`: **inalterado**.

## Procedimento

```bash
cd /caminho/do/seu/projeto
git status                     # commite o que estiver pendente antes

# 1. os três agentes (arquivos novos, zero conflito)
mkdir -p .claude/agents
cp /caminho/spec-base/.claude/agents/*.md .claude/agents/
```

### 2. atualizar o bloco no CLAUDE.md

O bloco vive entre `<!-- SPEC-BASE:INICIO -->` e `<!-- SPEC-BASE:FIM -->`.
Substitua **só o conteúdo entre os marcadores**, preservando o resto do arquivo:

```bash
python3 - <<'PY'
from pathlib import Path
alvo = Path("CLAUDE.md")
novo  = Path("/caminho/spec-base/.claude/CLAUDE.md.bloco").read_text(encoding="utf-8")
t = alvo.read_text(encoding="utf-8")
i, f = "<!-- SPEC-BASE:INICIO -->", "<!-- SPEC-BASE:FIM -->"
if i in t and f in t:
    t = t[:t.index(i)] + novo.strip() + t[t.index(f)+len(f):]
else:
    t = t.rstrip() + "\n\n" + novo
alvo.write_text(t, encoding="utf-8")
print("CLAUDE.md atualizado")
PY
```

Se você tinha customizado o bloco à mão, faça um `diff` antes — a substituição é total
dentro dos marcadores.

### 3. reiniciar o Claude Code

**Obrigatório.** Subagentes definidos em arquivo são carregados no início da sessão — editar o arquivo em disco exige reiniciar o Claude Code para a mudança valer.

### 4. conferir

```bash
ls .claude/agents/            # 3 arquivos
grep -c "Cadeia de agentes" CLAUDE.md   # 1
python3 scripts/spec_status.py
```

Dentro do Claude Code, `/agents` lista os agentes carregados.

## Ajustes que talvez você queira

**Modelo do validador.** Está `sonnet`. Se quiser Haiku, saiba o que muda: Haiku roda a
suíte e reporta bem, mas julga mal se o teste realmente cobre o requisito — que é o item
de maior valor do relatório. Alternativa mais barata sem perder isso: mantenha `sonnet`
no validador e crie um quarto agente `haiku` só para rodar comandos.

**Ferramentas do executor.** Se seu projeto não usa `Bash` nas tarefas, remova da
allowlist — a lista de `tools` é um allowlist — especificada, o subagente só usa o que está nela, então cortar reduz superfície.

**Permissão de escrita do validador.** Não adicione `Write` nem `Edit`. Um validador que
pode corrigir deixa de ser validador.

## Reverter

```bash
rm -rf .claude/agents
git checkout CLAUDE.md
```

Nada mais precisa ser desfeito — as skills e o hook não dependem dos agentes.
