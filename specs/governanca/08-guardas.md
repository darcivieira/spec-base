# Guardas — o que é bloqueado por mecanismo

Dono do fato: o que os hooks impedem, o que eles **não** impedem, e como desligá-los.

A diferença entre este arquivo e os outros da governança: o resto são regras que um agente pode
despriorizar numa sessão longa. O que está aqui **não é lembrado, é imposto** — o comando não roda.

Configuração: [`.spec-base.json`](../../.spec-base.json), na raiz. `python3 scripts/spec_check.py --explicar`
imprime o que cada chave faz.

## Estado deste projeto

<<PREENCHER: marque o que está ligado. As três são independentes.>>

| Guarda | Onde | Ligada? | O que impede |
|---|---|---|---|
| `require-spec.sh` | `PreToolUse` · `Edit\|Write` | - [ ] | Editar código sem mudança ativa e aprovada |
| `guard-branch.sh` | `PreToolUse` · `Bash` | - [ ] | Commit, push ou merge direto em branch protegida |
| `dod_por_mudanca` | `scripts/spec_check.py` | - [ ] | Fechar mudança sem verificação item a item do DoD |

Nenhuma ligada = **modo consultivo**: as skills orientam e nada bloqueia. É uma escolha legítima,
e não uma pendência — mas então a garantia é a disciplina de quem revisa, não o mecanismo.

## require-spec — código exige mudança aprovada

| Caminho | Política |
|---|---|
| `caminhos.protegidos` do `.spec-base.json` | Exige mudança ativa em [`ACTIVE.md`](../ACTIVE.md), ou exceção `GREEN:` declarada |
| `caminhos.livres` — testes, specs, docs, configuração | Livre |
| `caminhos.imutaveis_apos_publicacao` | **Regra própria** — ver abaixo |

### Fluxo quando o hook bloqueia

1. Leia `specs/ACTIVE.md`.
2. Classifique por [03-limites-agente](03-limites-agente.md) e **declare em voz alta**.
3. 🟢 GREEN → registre a exceção e implemente:
   ```bash
   echo "GREEN: <motivo>" > specs/ACTIVE.md
   ```
4. 🟡 YELLOW / 🔴 RED → rode `spec-nova`, depois `spec-plano`. O hook só libera quando o `plan.md`
   da mudança contém `**Aprovação humana:** ☑`.

A exceção `GREEN:` é deliberadamente fácil de escrever e deliberadamente visível: ela fica no
diff, e quem revisa vê que alguém declarou uma mudança trivial.

## Arquivos imutáveis depois de publicados

Alguns arquivos são livres de **criar** e proibidos de **editar** depois que rodaram em algum
ambiente. Migrations são o caso clássico; changelogs publicados e arquivos gerados por codegen
também.

Proteger o diretório inteiro não funciona: se toda tarefa de banco dispara o bloqueio, o controle
vira ruído e perde a proteção real. O risco nunca foi "escreveram uma migration"; foi **"editaram
uma migration que já rodou"**, que deixa ambientes em estados divergentes e sem caminho de volta.

| Ação | Política |
|---|---|
| Criar arquivo novo | **Livre** |
| Editar arquivo já publicado | **Bloqueado, sem exceção** — nem `GREEN:` libera |
| Editar arquivo criado nesta branch, ainda não publicado | Livre |
| Apagar arquivo já publicado | **Bloqueado por regra, não por hook** — ver limitação |

**Como o hook decide se foi publicado:** o arquivo já existe em `caminhos.ref_principal`
(default `origin/main`), de onde saem os deploys.

> É um **proxy, não a verdade**. Migration aplicada só no ambiente local de alguém não é detectada.

### Limitação conhecida

**Apagar arquivo não passa pelo hook**, porque exclusão não usa `Edit` nem `Write`. A proteção vem
da regra 🔴 RED em [03-limites-agente](03-limites-agente.md) e da revisão de PR — não do mecanismo.
Está escrito aqui para que ninguém confie numa garantia que não existe.

## guard-branch — branch protegida

Bloqueia `git commit`, `git push` e `git merge` quando a branch atual, ou o destino explícito do
push, está em `branches.protegidas`.

**Não tem exceção.** Diferente do `GREEN:`, não há declaração que o libere: se for pedido na
conversa, a resposta é criar a branch.

Vale mesmo com branch protection configurada no servidor. Lá a proteção só age no `push`, e a essa
altura o commit já está na branch errada, com histórico local a desfazer.

Fluxo completo em [09-fluxo-de-trabalho](09-fluxo-de-trabalho.md).

## Verificar antes de confiar

Guarda que nunca foi vista bloquear não foi demonstrada. Rode os casos que importam:

```bash
# require-spec: código sem mudança ativa deve bloquear (exit=2)
echo '{"tool_input":{"file_path":"'"$PWD"'/src/foo.ts"}}' \
  | CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/require-spec.sh ; echo "exit=$?"

# guard-branch: estando na branch principal, commit deve bloquear (exit=2)
echo '{"tool_input":{"command":"git commit -m x"}}' \
  | CLAUDE_PROJECT_DIR="$PWD" .claude/hooks/guard-branch.sh ; echo "exit=$?"

# e o caso simétrico: em branch de tarefa, o mesmo comando deve liberar (exit=0)
```

## Desligar

Remover o bloco correspondente de `hooks.PreToolUse` em `.claude/settings.json` e marcar a caixa
neste arquivo.

**É mudança de governança: exige ADR.** Desligar uma guarda em silêncio é a forma mais barata de
transformar um sistema verificado num sistema que parece verificado.
