# Definition of Done — mudança <id>

Verificação item a item de [`governanca/04-definition-of-done.md`](../../governanca/04-definition-of-done.md).

> O checklist de governança é reutilizável e **não é marcado** — marcá-lo faria a próxima mudança
> herdar as caixas desta.

## Como preencher

Três estados, e só três:

| Estado | Significa | Exige |
|---|---|---|
| `[x]` | Verificado | **Como** foi verificado, na mesma linha. "Passa" sem o comando não é verificação |
| `[ ]` | **Não atendido** | O motivo, e o que delimita |
| `[n/a]` | Não se aplica | Por que não se aplica |

Item que você não conseguiu verificar fica `[ ]` com o motivo. **Nunca marque em bloco** — DoD
marcado em bloco é a forma mais barata de transformar verificação em ritual.

## Sempre

- [ ] **Comportamento bate com a spec** — <como foi verificado>
- [ ] **Nenhum requisito sem implementação** — <n de n>
- [ ] **Spec de estado atualizada** — <quais arquivos>
- [ ] **Lint e type-check passam** — <comando e resultado>
- [ ] **Testes passam; testes novos cobrem os critérios** — <n passando, n pulados>
- [ ] **Sem `TODO`, código morto ou comentado**
- [ ] **Sem segredo, credencial ou dado real**
- [ ] **Erros tratados com contexto** — <a mensagem nomeia o culpado, ou é genérica?>
- [ ] **Decisão não-óbvia registrada como ADR** — <link, ou "nenhuma decisão não-óbvia">

## Backend

<Repita as linhas de backend do DoD de governança, ou escreva "Todos n/a — a mudança não toca
o backend", com o motivo.>

## Frontend

<Idem.>

## Gates específicos do projeto

<Repita aqui os gates da seção própria do DoD de governança.>

## Verificação de cada requisito

A tabela que separa "eu acho que fiz" de "eu verifiquei".

| RF | Como foi verificado | Resultado |
|---|---|---|
| RF-1 | <comando, teste, ou inspeção — literal> | <o que apareceu> |

> Requisito verificado por teste novo: **o teste foi visto falhar antes?** Guarda que nunca foi
> vista vermelha não foi demonstrada — ela pode estar passando por engano.

## Escopo extra encontrado

O que foi feito além do que a spec pedia, e por que ficou. Se não houve, escreva "nenhum".

| Extra | Por que ficou |
|---|---|
| | |

Extra sem justificativa é expansão silenciosa de escopo, e é exatamente o que a spec existe para
impedir. Extra **declarado** é decisão — e quem revisa pode discordar dela.

## Notas para quem vier depois

<Armadilha encontrada no caminho, atalho que não funcionou, ou coisa que o próximo vai
achar que é bug e não é. Opcional, e é a seção mais lida seis meses depois.>

## Resumo

| | Quantidade |
|---|---|
| Atendidos | |
| **Não atendidos** | |
| Não aplicáveis | |

<Uma frase sobre cada não atendido: o que o delimita, e o que precisa acontecer para fechá-lo.>
