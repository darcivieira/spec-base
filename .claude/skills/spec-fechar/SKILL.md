---
name: spec-fechar
description: Fecha uma mudança concluída — absorve o que foi implementado nos specs de estado (modulos, ui, dados), atualiza checklists, registra ADRs pendentes e limpa ACTIVE.md. Use sempre que o usuário disser que terminou a implementação, que a feature está pronta, que vai abrir o PR, ou pedir para atualizar/sincronizar as specs depois de codar. Use também ao detectar que todas as tarefas de tasks.md estão marcadas.
---

# spec-fechar

Sem este passo o sistema apodrece: specs de estado congelam e viram mentira.

## Passo 1 — Verificar de verdade

Não confie nas caixas marcadas em `tasks.md`. Compare o `spec.md` com o **código real**:

| Verificação | Como |
|---|---|
| Cada RF foi implementado? | Localize o código que o satisfaz. Cite arquivo e linha. |
| Cada critério de aceite tem teste? | Localize o teste. |
| O que foi feito além da spec? | Escopo extra é achado, não bônus — reporte. |
| O que ficou faltando? | Liste explicitamente. |

Divergência entre spec e código **não é erro de spec por padrão**. Pergunte qual dos dois
está certo antes de mexer.

## Passo 2 — Rodar o DoD

Percorra `specs/governanca/04-definition-of-done.md` item por item, marcando só o que você
verificou. Item não verificado fica desmarcado e é reportado — nunca marcado por otimismo.

**Se `.spec-base.json` tem `guardas.dod_por_mudanca: true`**, o resultado não fica na conversa:
escreva `specs/mudancas/<id>/dod.md` a partir de `specs/_templates/MUDANCA-dod.md`.

Regras do artefato:

- O checklist de governança é reutilizável e **não é marcado** — marcá-lo faria a próxima
  mudança herdar as caixas desta.
- Três estados, e só três: `[x]` **com o como** na mesma linha, `[ ]` não atendido **com o
  motivo**, `[n/a]` **com a razão**. "Passa" sem o comando não é verificação.
- Preencha a tabela requisito por requisito e a seção de escopo extra. Extra sem justificativa
  é expansão silenciosa de escopo.
- Feche com a contagem: atendidos, não atendidos, não aplicáveis.

Mudança concluída sem `dod.md` reprova em `python3 scripts/spec_check.py --ci`.

## Passo 3 — Absorver no estado

| Mudou | Atualize |
|---|---|
| Endpoint, regra de negócio | `modulos/<mod>.md` — checklists e contratos |
| Entidade, campo, migration | `dados/entidades/<mod>.md` e `dados/INDICE.md` |
| Tela, rota, estado de UI | `ui/telas/<tela>.md` |
| Componente compartilhado | `ui/COMPONENTES.md` |
| Topologia, camada, fluxo | `arquitetura/VISAO_TECNICA.md` |
| Termo novo do domínio | `visao/GLOSSARIO.md` |
| Entrega de roadmap | `visao/ROADMAP.md` |

Respeite a propriedade de fatos de `governanca/02-convencoes.md`: um fato, um dono.
Se você está prestes a escrever a mesma informação em dois arquivos, pare — um deles deve referenciar.

## Passo 3.5 — Rotear os follow-ups

Se existe `specs/mudancas/<id>/followups.md`, percorra-o inteiro. **Nada sai daqui como
`pendente`:** cada achado ou virou registro em algum lugar, ou foi descartado com motivo escrito.

| Destino | O que fazer |
|---|---|
| Card ou issue nova | Redija título e corpo. Publique conforme `integracoes.publicacao_externa` |
| Comentário no card atual | Idem |
| ADR | Rode `spec-adr` |
| Documento | Escreva no caminho indicado |
| Descartado | Escreva o **motivo**. Descarte sem motivo é achado perdido com etiqueta |

Preencha o campo **Estado** com a referência real. Estado sem referência é o mesmo que pendente.

Se houver **entregas parciais** registradas, o comentário de fechamento diz o que a última porção
fechou e confirma que nada ficou aberto — quem lê o card só encontra o último comentário.

Todo texto que sai do repositório segue `specs/governanca/10-voz.md` e vai com o nome de uma
pessoa. No default `rascunho`, você **redige e mostra**; quem publica é o humano.

**Percebeu que a mesma investigação se repetiu pela terceira vez?** Isso é um follow-up com
destino próprio: propor uma skill ou agente para o domínio. Uma vez não justifica; três, sim.

## Passo 4 — ADRs

Para cada linha de `plan.md` marcada "vira ADR: sim", e para toda decisão tomada durante a
implementação que um revisor questionaria: use a skill `spec-adr`.

Decisão que revoga ADR anterior **não edita o anterior** — cria sucessor e marca o antigo
como `substituído`.

## Passo 5 — Encerrar

1. `spec.md` → `status: concluida`
2. `specs/ACTIVE.md` → `nenhuma`
3. Mantenha `mudancas/<id>/` no repositório. É o histórico do porquê.
4. Rode `python3 scripts/spec_status.py` e `python3 scripts/spec_check.py` e reporte.

## Saída

Resumo com: RFs entregues, o que ficou pendente e por quê, arquivos de spec atualizados,
ADRs criados, e itens de DoD que **não** puderam ser verificados.

Seja honesto sobre o pendente. Fechamento otimista é o modo mais rápido de a spec virar ficção.
