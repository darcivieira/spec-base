# Instalação

## 1. Instalar

Um comando, a partir da raiz do seu projeto:

```bash
curl -fsSL https://raw.githubusercontent.com/darcivieira/spec-base/master/install.sh | sh
```

Ele clona sem histórico, copia `specs/`, `scripts/`, `.claude/{skills,hooks,agents}` e
`.spec-base.json`, dá `chmod +x` nos hooks e some. **Nenhum vínculo de git**: nada de submódulo,
nada de `.git` estranho no seu projeto.

O que **não** é copiado: `README.md`, `INSTALAR.md`, `BOOTSTRAP.md`, `ATUALIZAR.md`,
`MIGRAR-IDENTIFICADOR.md`, `AGENTS.md.exemplo` e `.github/`. São documentação do kit, não do seu
projeto — o script imprime os links no fim.

**O `README.md` do seu projeto está a salvo.** A cópia é por lista explícita, não por exclusão:
arquivo novo na raiz do kit não vaza para o destino por esquecimento.

**Nada é sobrescrito em silêncio.** Arquivo que já existe e difere vira `<nome>.novo`, e a lista
sai no relatório para você resolver com `diff`. Rodar de novo num projeto que já tem a base é o
caminho de atualização.

| Variável | Para quê |
|---|---|
| `SPEC_BASE_REF` | Instalar de outra branch ou tag |
| `SPEC_BASE_REPO` | Instalar de um fork ou de um clone local |
| `SPEC_BASE_YES=1` | Responder "sim" aos avisos, em automação |

Sem terminal e sem `SPEC_BASE_YES`, o script **aborta** em vez de seguir sozinho. Ele avisa e
para em dois casos: fora de repositório git, e com trabalho não commitado — porque é o commit
anterior que faz `git checkout .` desfazer a instalação inteira se você desistir.

Se o repositório for privado, o `curl` cru não alcança o `raw.githubusercontent.com`. Use o `gh`,
que aproveita a autenticação que você já tem:

```bash
sh -c "$(gh api repos/darcivieira/spec-base/contents/install.sh --jq .content | base64 -d)"
```

### Ou copiar à mão

```bash
# a partir da raiz do seu projeto
cp -r /caminho/para/spec-base/specs .
cp -r /caminho/para/spec-base/scripts .
cp    /caminho/para/spec-base/.spec-base.json .
cp -r /caminho/para/spec-base/.claude/skills .claude/
cp -r /caminho/para/spec-base/.claude/hooks .claude/
cp -r /caminho/para/spec-base/.claude/agents .claude/
```

Se `.claude/` ainda não existir: `mkdir -p .claude`.

Se já houver `.claude/skills/`, os cinco diretórios `spec-*` apenas se somam aos existentes.

Opcionais, e todos com sufixo `.exemplo` para não entrarem em vigor por acidente:

```bash
cp /caminho/para/spec-base/AGENTS.md.exemplo AGENTS.md
cp /caminho/para/spec-base/.github/workflows/ci.yml.exemplo .github/workflows/ci.yml
cp /caminho/para/spec-base/.github/workflows/claude-code-review.yml.exemplo \
   .github/workflows/claude-code-review.yml
```

## 2. Rodar o bootstrap

Abra o Claude Code na raiz do projeto e cole o prompt de `BOOTSTRAP.md`.

O bootstrap decide, com você, três coisas que a base não pode escolher sozinha:
o **esquema de identificador** de mudança, quais **guardas** ficam ligadas, e se cada mudança
escreve o próprio **DoD**. Os defaults do `.spec-base.json` são os mais conservadores —
trabalho solo, nada bloqueando além do `require-spec`.

## 3. `.spec-base.json` — o que dá para configurar

```bash
python3 scripts/spec_check.py --explicar    # o que cada chave faz
python3 scripts/spec_check.py               # relatório
python3 scripts/spec_check.py --ci          # exit 1 se a convenção foi violada
python3 scripts/spec_check.py --relacionar  # tabela mudança ↔ card ↔ issue
```

### Publicação externa

`integracoes.publicacao_externa` decide quem publica o texto que sai do repositório:
`rascunho` (default, o agente redige e você publica), `confirmar`, ou `automatica`.

`integracoes.voz` decide de onde vem o estilo: `conversa` (default — a amostra é como você
escreve para o agente, sem nada a preencher), `amostras` (trechos fixados em
`specs/governanca/10-voz.md`, para quando o registro do destino difere do da conversa), ou
`neutro`.

### Identificador de mudança

| Esquema | Diretório | Quando serve |
|---|---|---|
| `sequencial` (default) | `001-slug` | Trabalho solo. Um contador local basta |
| `rastreador` | `PROJ-42-slug` | Duas ou mais pessoas. Ninguém escolhe o número, ninguém colide |
| `multiplo` | `PROJ-42-slug` + espelho no frontmatter | Controle em dois sistemas — ex. Jira **e** GitHub Issues |

Nos dois últimos, **sem card não existe nome de diretório válido** — a regra deixa de depender
de memória. O custo: o nome passa a depender de um sistema externo, e `ls` perde a ordem
cronológica.

Exemplo de configuração para o caso de dois sistemas:

```json
"identificador": {
  "esquema": "multiplo",
  "primario": "jira",
  "fatiamento": true,
  "rastreadores": {
    "jira":   { "padrao": "PROJ-\\d+", "campo": "card",  "url": "https://x.atlassian.net/browse/{id}" },
    "github": { "padrao": "GH-\\d+",   "campo": "issue", "url": "https://github.com/o/r/issues/{id}" }
  },
  "espelho_obrigatorio": ["github"]
}
```

Só um sistema dá o nome do diretório. O nome precisa de um dono, ou volta a colidir.

## 4. Guardas (opcional)

Três, independentes. Ligue depois do bootstrap — nunca antes, ou você se bloqueia com uma
spec vazia. Detalhe em `specs/governanca/08-guardas.md`.

| Guarda | Bloqueia | Ligar como |
|---|---|---|
| `require-spec.sh` | `Edit`/`Write` em código sem mudança aprovada | bloco `Edit\|Write` em `settings.json` |
| `guard-branch.sh` | `git commit`/`push`/`merge` em branch protegida | bloco `Bash` em `settings.json` |
| `dod_por_mudanca` | Fechar mudança sem `dod.md` preenchido | chave em `.spec-base.json` |

```bash
# requer jq instalado
# só o require-spec:
jq -s '.[0] * .[1]' .claude/settings.json /caminho/spec-base/.claude/settings.json.exemplo \
  > /tmp/s.json && mv /tmp/s.json .claude/settings.json

# os dois hooks:
jq -s '.[0] * .[1]' .claude/settings.json /caminho/spec-base/.claude/settings.json.exemplo-completo \
  > /tmp/s.json && mv /tmp/s.json .claude/settings.json

chmod +x .claude/hooks/*.sh
```

Se `.claude/settings.json` não existir, copie o exemplo direto.

**Ajuste `caminhos.protegidos` e `branches` no `.spec-base.json`** para o projeto real. O padrão
cobre `src/`, `app/`, `lib/`, `api/`, `packages/`, `services/`, e protege só a branch `main`.

### Teste antes de confiar

Guarda que nunca foi vista bloquear não foi demonstrada:

```bash
# require-spec: deve bloquear (exit=2)
echo '{"tool_input":{"file_path":"'"$PWD"'/src/foo.ts"}}' | \
  CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/require-spec.sh ; echo "exit=$?"

# guard-branch, estando na branch principal: deve bloquear (exit=2)
echo '{"tool_input":{"command":"git commit -m x"}}' | \
  CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/guard-branch.sh ; echo "exit=$?"

# e o simétrico, em branch de tarefa: deve liberar (exit=0)
```

### Escapes

| Situação | Como |
|---|---|
| Mudança trivial (GREEN) | `echo "GREEN: corrige typo no log" > specs/ACTIVE.md` |
| Voltar ao normal | `echo "nenhuma" > specs/ACTIVE.md` |
| Desligar uma guarda | Remover o bloco de `settings.json` — **exige ADR** |

`guard-branch.sh` **não tem escape**. Se for pedido em conversa, a resposta é criar a branch.

## 5. Cadeia de agentes

Os três subagentes (`planejador` opus · `executor` sonnet · `validador` sonnet read-only)
ficam disponíveis assim que você reiniciar o Claude Code. Confira com `/agents`.

O `validador` lê a spec antes do código de propósito — não dê a ele `Write` nem `Edit`.

## 6. Versionar

```bash
git add specs scripts .claude .spec-base.json CLAUDE.md
git commit -m "chore: base de especificações spec-driven"
```

`specs/mudancas/` **fica no repositório**. É o histórico do porquê — o ativo mais valioso
da base depois de seis meses.

## O que NÃO fazer

- Não rode o bootstrap com trabalho não commitado. Ele edita `CLAUDE.md`.
- Não ligue guarda nenhuma antes de a governança estar preenchida — você vai se bloquear
  com uma spec vazia.
- Não deixe `specs/ui/` num projeto sem frontend, nem `governanca/07-protecao-de-dados.md`
  num projeto que não processa dado pessoal. Seção vazia é ruído que compete por contexto
  com o que importa, e ensina o agente a ignorar a pasta.

## Limites honestos

O disparo automático de skill é **probabilístico**: depende de o Claude Code casar o pedido
com a `description` da skill. Hook e `spec_check.py` são **determinísticos**: ou bloqueiam
ou não.

Se a garantia importa, ligue as guardas. Se você só quer estrutura e disciplina assistida,
o consultivo entrega 80% com zero atrito — e você pode invocar a skill pelo nome sempre
que quiser certeza.

Duas coisas que nenhum hook cobre, e que estão escritas onde importa:
**apagar arquivo não passa por hook** (exclusão não usa `Edit` nem `Write`), e **decisões
conflitantes tomadas em paralelo** continuam passando, cada uma com o seu ADR correto.
