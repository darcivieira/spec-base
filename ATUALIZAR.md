# Atualizar uma base já em uso

Esta atualização é **quase toda aditiva**. Nada do que você preencheu em `specs/` é perdido, mas
sete arquivos ganham conteúdo novo e precisam de merge manual — estão marcados abaixo.

Commite o que estiver pendente antes de começar. `git status` limpo.

## O que mudou

### Arquivos novos — zero conflito

| Arquivo | O que faz |
|---|---|
| `.spec-base.json` | Configuração na raiz: formato do `<id>`, branches, guardas |
| `scripts/spec_check.py` | Cobra a convenção de specs. `--ci` · `--relacionar` · `--explicar` |
| `.claude/hooks/guard-branch.sh` | Bloqueia commit/push/merge em branch protegida |
| `.claude/settings.json.exemplo-completo` | Os dois hooks juntos |
| `specs/_templates/MUDANCA-dod.md` | O `dod.md` por mudança |
| `specs/governanca/06-decisao-e-registro.md` | Quem decide, onde registra, quem avisa |
| `specs/governanca/07-protecao-de-dados.md` | Dado pessoal como requisito |
| `specs/governanca/08-guardas.md` | O que cada hook bloqueia, e o que não bloqueia |
| `specs/governanca/09-fluxo-de-trabalho.md` | Da demanda ao merge |
| `.github/workflows/*.exemplo` | CI com guarda anti-falso-verde, e review por PR |
| `AGENTS.md.exemplo` | Ponte para agentes que não leem `CLAUDE.md` |
| `specs/governanca/10-voz.md` | Estilo do texto que sai com o seu nome |
| `specs/_templates/MUDANCA-followups.md` | Achados fora de escopo e entregas parciais |
| `.claude/skills/spec-followup/` | Skill que registra achado sem consertar |

### Arquivos alterados — merge manual

| Arquivo | O que mudou | Seu conteúdo é afetado? |
|---|---|---|
| `specs/governanca/00-indice.md` | Linhas 06 a 09 e a ordem de precedência | Não, se você não editou |
| `specs/governanca/01-constituicao.md` | Todo invariante passa a declarar **onde é verificado** | **Sim** — o `<<PREENCHER>>` mudou de forma |
| `specs/governanca/02-convencoes.md` | Bloco novo "Identificador de mudança" | Não |
| `specs/governanca/03-limites-agente.md` | Nível **⛔ SEM EXCEÇÃO** acima do RED | Não |
| `specs/governanca/04-definition-of-done.md` | Regra do checklist reutilizável e do `dod.md` | Não |
| `.claude/hooks/require-spec.sh` | Lê `.spec-base.json`; regra de imutável-após-publicação | **Sim** se você editou o `PROTEGIDOS_REGEX` |
| `.claude/CLAUDE.md.bloco` | Três seções opcionais e o nível ⛔ | **Sim** — reinserir no `CLAUDE.md` |

Além disso, `NNN` foi trocado por `<id>` nas três skills, nos três agentes e nos templates de
mudança. Se você não editou esses arquivos, copie-os por cima.

Os três agentes também ganharam a ferramenta `Skill` no frontmatter — sem ela, a regra de usar
skills de domínio durante o trabalho seria inexequível para eles. O `validador` continua
read-only: skill nenhuma lhe dá `Write`.

## Procedimento

```bash
cd /caminho/do/seu/projeto
git checkout -b chore/atualiza-spec-base

B=/caminho/spec-base

# 1. arquivos novos
cp $B/.spec-base.json .
cp $B/scripts/spec_check.py scripts/
cp $B/.claude/hooks/guard-branch.sh .claude/hooks/
cp $B/.claude/settings.json.exemplo-completo .claude/
cp $B/specs/_templates/MUDANCA-dod.md specs/_templates/
cp $B/specs/governanca/0[6789]-*.md $B/specs/governanca/10-voz.md specs/governanca/
cp $B/specs/_templates/MUDANCA-followups.md specs/_templates/
cp -r $B/.claude/skills/spec-followup .claude/skills/
chmod +x .claude/hooks/*.sh

# 2. skills, agentes e templates de mudança (só se você não os editou)
cp $B/.claude/skills/spec-*/SKILL.md   # um a um, conferindo
cp $B/.claude/agents/*.md .claude/agents/
cp $B/specs/_templates/MUDANCA-{spec,plan,tasks}.md specs/_templates/

# 3. governança alterada — veja o diff antes de aceitar
for f in 00-indice 01-constituicao 02-convencoes 03-limites-agente 04-definition-of-done; do
  diff -u specs/governanca/$f.md $B/specs/governanca/$f.md | less
done
```

### O `require-spec.sh`

Ele agora lê os caminhos do `.spec-base.json` em vez de tê-los codificados. **Antes de copiar,
anote o seu `PROTEGIDOS_REGEX` atual** e transporte-o para `caminhos.protegidos`:

```bash
grep PROTEGIDOS_REGEX .claude/hooks/require-spec.sh   # o valor antigo
cp $B/.claude/hooks/require-spec.sh .claude/hooks/
# agora edite .spec-base.json -> caminhos.protegidos com o valor que você anotou
```

Sem esse transporte o hook cai no default (`src|app|lib|api|packages|services`), que pode ser
mais largo ou mais estreito que o seu.

### O bloco do `CLAUDE.md`

Vive entre `<!-- SPEC-BASE:INICIO -->` e `<!-- SPEC-BASE:FIM -->`. Substitua **só** o conteúdo
entre os marcadores:

```bash
python3 - <<'PY'
from pathlib import Path
alvo = Path("CLAUDE.md")
novo  = Path("/caminho/spec-base/.claude/CLAUDE.md.bloco").read_text(encoding="utf-8")
t = alvo.read_text(encoding="utf-8")
i, f = "<!-- SPEC-BASE:INICIO -->", "<!-- SPEC-BASE:FIM -->"
if i in t and f in t:
    antes, resto = t.split(i, 1)
    _, depois = resto.split(f, 1)
    alvo.write_text(antes + novo.strip() + depois, encoding="utf-8")
    print("bloco substituído")
else:
    print("marcadores não encontrados — insira o bloco manualmente")
PY
```

Depois, **apague as seções opcionais** cujo recurso você não vai ligar. Elas estão entre
`<!-- OPCIONAL -->` e `<!-- FIM OPCIONAL -->`: branches protegidas, fluxo do card, DoD por
mudança. Regra que descreve mecanismo desligado ensina o agente a não confiar no arquivo.

## Configurar

Nada muda de comportamento até você escolher. Os defaults do `.spec-base.json` reproduzem o que
você já tinha: identificador `sequencial`, só o `require-spec` ligado.

```bash
python3 scripts/spec_check.py --explicar   # o que cada chave faz
python3 scripts/spec_check.py              # deve passar sem alterar nada
```

Decida três coisas, na ordem — ou rode `spec-bootstrap`, que pergunta as três:

1. **Identificador** — continuar `sequencial`, ou passar a `rastreador`/`multiplo`.
   Se mudar, siga [`MIGRAR-IDENTIFICADOR.md`](MIGRAR-IDENTIFICADOR.md) **antes** de rodar o
   `spec_check`, ou ele reprova todos os diretórios existentes de uma vez.
2. **`guard_branch`** — ligar exige nomear as branches em `.spec-base.json` e registrar o hook
   no `settings.json`.
3. **`dod_por_mudanca`** — ligar faz o `spec_check` reprovar mudança **já concluída** que não
   tenha `dod.md`. Ou você escreve os retroativos, ou liga junto com a próxima mudança.

## Depois

```bash
python3 scripts/spec_check.py --ci    # tem de sair 0
python3 scripts/spec_status.py
```

E teste as guardas antes de confiar nelas — os comandos estão em
`specs/governanca/08-guardas.md`. Guarda que nunca foi vista bloquear não foi demonstrada.

## Se algo der errado

Tudo isto está numa branch. `git checkout -` e nada aconteceu.

O único passo com efeito fora do repositório é ligar hook em `.claude/settings.json` — que é
arquivo versionado, e volta junto.
