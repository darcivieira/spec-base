# Decisão e registro

Quem pode decidir o quê, onde a decisão fica registrada, e quem precisa saber antes do merge.

Sem este arquivo, "documentamos as decisões" é intenção. Decisão sem destino declarado vira
mensagem de chat, e mensagem de chat não é lida por quem chega depois.

## Quem decide

<<PREENCHER: o modelo de decisão do projeto. Exemplos de forma:
- "Qualquer pessoa do time decide sozinha, desde que registre." — rápido, exige registro forte
- "Mudança de superfície pública exige duas pessoas." — mais lento, menos divergência
- "Uma pessoa mantém a arquitetura e assina as decisões estruturais."
Diga também o que acontece quando duas pessoas discordam.>>

## Onde registrar

O destino depende do alcance da decisão, não do seu tamanho.

| Tipo de mudança | Registro | Avisar alguém? |
|---|---|---|
| Interior de um módulo, sem mudar contrato | Mensagem de commit | Não |
| **Superfície pública** de um módulo | **ADR** em `arquitetura/adr/` | **Antes do merge** |
| Contrato de evento, fila ou mensagem | ADR | Antes do merge |
| Schema de banco / migration | <<PREENCHER: onde — ex. `dados/MIGRATIONS.md`>> + ADR se mudar semântica | Antes do merge |
| Escopo de fase — entrar ou sair do que foi prometido | ADR + `visao/ROADMAP.md` | Antes do merge |
| Dependência nova, ou upgrade maior | ADR | Antes do merge |

<<PREENCHER: ajuste as linhas acima aos limites reais deste projeto. O que é "superfície pública"
aqui? Nomeie os caminhos — ex. `application/{schemas,services}`, `src/api/`, `packages/*/index.ts`.>>

## Formato mínimo do ADR

Três linhas: **contexto → decisão → trade-off**.

> Se quem decidiu não consegue escrever o trade-off, a decisão ainda não está madura. É o único
> teste que este formato aplica, e ele reprova mais do que parece.

O template completo (`_templates/ADR.md`) pede mais campos. Use-os quando houver o que dizer, e
deixe explícito quando não houver.

**Nunca invente alternativa descartada para preencher tabela.** Se não havia alternativa, não é
ADR — é convenção, e vai para [02-convencoes](02-convencoes.md).

## Regra de reversão

Decisão registrada pode ser revertida, mas **só por um ADR novo que cite o anterior**. O antigo
passa a `substituído`, ganha `substituido-por`, e **nunca é editado**.

Editar um ADR aceito destrói o registro do que se sabia na época — que é a única razão de ele
existir. Reverter sem registrar recria exatamente o problema que o registro evita.

## O risco que este mecanismo não cobre

Registro protege contra decisão *esquecida*. Não protege contra **decisões conflitantes tomadas em
paralelo**.

O caso concreto: duas pessoas alteram a superfície pública de módulos vizinhos na mesma semana,
cada uma com ADR correto, e a integração quebra. Os dois ADRs continuam certos, e o sistema, errado.

**Mitigação:** <<PREENCHER: a periodicidade da revisão conjunta e a pauta. Sugestão que funciona:
quinze minutos a cada duas semanas, pauta única — os ADRs escritos no período. Sem isso, o modelo
funciona por alguns meses e depois se descobre que há dois desenhos convivendo no mesmo
repositório.>>

## Decisão tomada por agente

Agente não decide sozinho nada que caia em 🟡 YELLOW ou 🔴 RED
([03-limites-agente](03-limites-agente.md)). Quando um plano contiver decisão com alternativa
plausível, o agente **propõe o ADR junto do plano** — a aprovação humana do plano é o que
transforma a proposta em decisão.
