# Fluxo de trabalho — da demanda ao merge

Como uma demanda vira código publicado. Não há exceção "essa é rapidinha" — se é rápida, o fluxo
é rápido.

**Projeto solo, sem rastreador de cards:** apague a coluna do rastreador e os pontos ① a ④.
O que sobra — specs e git — continua valendo inteiro.

## As três cadeias

Elas correm em paralelo, e o valor está justamente em não deixar nenhuma para depois.

```
CADEIA DE SPECS         CADEIA DO RASTREADOR    CADEIA DO GIT
                        card em "A Fazer"       base de integração atualizada
   demanda chega  ────▶ ① mover p/ "Fazendo"    ⓐ branch a partir da base
   spec-nova
   spec-plano
   aprovação  ────────▶ ② comentar o plano
   executor                                     commits na branch de tarefa
   validador
   entrega  ──────────▶ ③ comentar a entrega    ⓑ PR da branch → base
                        ④ mover p/ "Em análise"
   spec-fechar
                        (quem revisa: "Feito")  (humano: PR base → principal)
```

## O identificador da mudança

Vem de [`.spec-base.json`](../../.spec-base.json) → `identificador.esquema`, e o formato exato
está em [02-convencoes](02-convencoes.md).

| Esquema | Diretório | Quando serve |
|---|---|---|
| `sequencial` | `001-slug` | Trabalho solo. Um contador local basta |
| `rastreador` | `<chave>-<slug>` | Duas ou mais pessoas. Ninguém escolhe o número, então ninguém colide |
| `multiplo` | `<chave do primário>-<slug>` + espelhos no frontmatter | Controle em dois sistemas — ex. Jira e GitHub Issues |

Nos esquemas com rastreador, **sem card não há nome de diretório válido**. Isso deixa de ser regra
a lembrar: quem tentar pular o card não consegue nomear o trabalho.

`python3 scripts/spec_check.py --relacionar` imprime a tabela mudança ↔ card ↔ issue.

## Card fatiado

Nem toda demanda cabe numa mudança só. Quando o trabalho tiver **partes com risco ou revisão
diferentes**, ele é fatiado.

> Fatie por risco, não por ordem. Duas partes que apenas se sucedem no tempo são dois commits,
> não duas mudanças.

**Quando decidir:** durante o `spec-nova`, antes de escrever a primeira spec. Não antes — o
fatiamento é conclusão de quem dimensionou o trabalho, e ninguém sabe isso ao abrir o card.

**Quem carrega o fluxo:** a fatia. Cada uma tem spec, plano, branch e PR próprios. O card pai
acompanha, mas **não recebe comentário por fatia** — receberia vários "o que foi entregue", cada um
descrevendo um pedaço e nenhum descrevendo o todo, e quem chega depois lê o último e acha que é tudo.

| Momento | Fatia | Card pai |
|---|---|---|
| A primeira fatia começa | ① *Fazendo* | ① *Fazendo* |
| Plano de uma fatia aprovado | ② comentar o plano | — |
| Uma fatia entrega | ③ comentar · ④ *Em análise* | — |
| A **última** fatia entrega | ③ comentar · ④ *Em análise* | ④ *Em análise* |

## As branches

<<PREENCHER: confirme que a tabela bate com `branches` do `.spec-base.json`.>>

| Branch | Papel | Recebe |
|---|---|---|
| `<principal>` | Publicada | **Só PR vindo da base de integração** — ou da branch de tarefa, em fluxo de duas pontas |
| `<integracao>` | Integração | PR das branches de tarefa |
| `<tipo>/<id>-<slug>` | Trabalho | Commits |

> **O agente não commita, não empurra e não faz merge em branch protegida. Sem exceção.**
> Com `guard_branch` ligado, o hook bloqueia o comando ([08-guardas](08-guardas.md)).

### ⓐ Abrir a branch — antes do `spec-nova`

```bash
git fetch origin
git checkout <base> && git pull --ff-only origin <base>
git checkout -b <tipo>/<id>-<slug>
```

Atualizar a base **antes** não é zelo: branch criada de base velha vira conflito no PR.

Worktree serve igualmente, e é preferível quando há trabalho em paralelo:

```bash
git worktree add ../<projeto>-<id> -b <tipo>/<id>-<slug> <base>
```

### ⓑ Fechar por PR — depois do comentário de entrega

```bash
git push -u origin <tipo>/<id>-<slug>
gh pr create --base <base> --title "<tipo>(<escopo>): <o que muda>"
```

## Os quatro pontos de contato com o rastreador

O registro vive no repositório, e **quem não abriu o repositório naquele dia não o lê**. Estes
quatro pontos são onde o trabalho fica visível para os outros — enquanto ainda dá para influenciar.

### ① Mover para "Fazendo" — ao aceitar, antes do `spec-nova`

Sinaliza que o card está tomado. É o que impede duas pessoas de começarem o mesmo trabalho.

### ② Comentar o plano — depois de aprovado, **antes** de executar

- O caminho escolhido, em uma frase
- Arquivos e módulos que serão tocados
- Decisões que valem revisão, e o ADR se houver
- O que fica fora, de propósito

**Antes da execução, não depois.** Comentário posterior é relato; anterior é chance de alguém
dizer "espera".

### ③ Comentar a entrega — o que de fato foi feito

| Bloco | Conteúdo |
|---|---|
| **Entregue** | O que existe agora que não existia antes |
| **Critérios de aceite** | Um a um: atendido, não atendido, ou não aplicável — **com o motivo quando não atendido**. Nunca marcar em bloco |
| **O que testar** | Caminho de verificação em passos, e o que caracteriza falha |

Divergência entre o planejado e o entregue entra aqui, explícita. Plano que mudou no meio não é
problema; plano que mudou em silêncio é.

### ④ Mover para "Em análise" — antes do `spec-fechar`

> **Nunca mova para "Feito".** Quem executou não declara a própria entrega aprovada. "Feito" é
> decisão de quem revisa.

<<PREENCHER: os nomes reais das colunas neste projeto e quem move cada uma. Se a automação usar
ids de transição, registre-os aqui — é o único lugar onde eles são fato, não detalhe de código.>>

## A cadeia de specs

| Etapa | Skill / agente | Sai quando |
|---|---|---|
| Especificar | `spec-nova` | `spec.md` descreve o comportamento esperado e os critérios |
| Planejar | `spec-plano` | `plan.md` e `tasks.md` existem |
| **Aprovar** | — humano | `plan.md` tem `**Aprovação humana:** ☑` |
| Implementar | `executor` | `tasks.md` marcado |
| Validar | `validador` | Sem lacuna contra a spec |
| Fechar | `spec-fechar` | Specs de estado absorveram a mudança, `ACTIVE.md` limpo |

Com `require_spec` ligado, o hook **bloqueia** a escrita em código até a aprovação existir.

## Quando a demanda chega sem card

Criar o card primeiro. Trabalho sem card não é rastreável, e não é alcançado por nenhuma revisão
periódica.

Exceção: 🟢 GREEN declarado — typo, comentário, formatação. Aí o registro é a mensagem de commit,
como manda [06-decisao-e-registro](06-decisao-e-registro.md).
