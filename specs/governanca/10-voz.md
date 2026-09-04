# Voz — como o agente escreve o que sai com o seu nome

Dono do fato: o estilo de todo texto que o agente produz para **fora do repositório** —
comentário de card, descrição de issue e de PR, entrada de documento, mensagem de entrega.

Não vale para código nem para spec: spec tem forma própria, em [02-convencoes](02-convencoes.md).

## O princípio

> **O agente é ferramenta de quem escreve, não coautor.** O texto sai com o nome de uma pessoa e
> precisa soar como ela — não como um sistema relatando o que um sistema fez.

Comentário que soa a robô é lido como ruído e deixa de ser lido. O registro existe para que outra
pessoa saiba o que aconteceu **enquanto ainda dá para influenciar**; texto que ninguém lê não faz
isso.

## De onde vem a voz

**Da conversa.** Como a pessoa escreve para o agente é a amostra — e ela é contínua, atual, e não
custa nada a ninguém. Cada pessoa que usa esta base traz a própria voz pela própria sessão, sem
cadastro e sem dever de casa.

`integracoes.voz` em [`.spec-base.json`](../../.spec-base.json):

| Valor | De onde o agente tira o estilo |
|---|---|
| `conversa` *(default)* | Da sessão em curso — como esta pessoa está escrevendo agora |
| `amostras` | Dos trechos fixados abaixo, quando o registro do destino difere do da conversa |
| `neutro` | De lugar nenhum. Escreve direto e sem tentar imitar ninguém |

### O ajuste de registro

Um cuidado que o modo `conversa` exige: **como alguém instrui uma ferramenta não é como escreve
para colegas.** Instrução tende a ser mais curta, mais direta, às vezes sem sujeito.

Da conversa vêm os traços que atravessam os dois contextos — vocabulário, jargão que usa e evita,
idioma, quanto hedge aceita, se prefere prosa ou lista, se vai direto ao ponto ou contextualiza.
O que **não** se transporta é a economia da instrução: um comentário de entrega precisa de
contexto que uma ordem não precisava.

Na dúvida sobre o registro do destino, pergunte uma vez. Depois disso, já está na conversa.

## O registro deste projeto

Isto é do **projeto**, não da pessoa: sobrevive à troca de quem escreve, e por isso mora aqui.

<<PREENCHER — opcional, e só o que for verdade:

| Traço | Deste projeto |
|---|---|
| Idioma dos textos que saem | |
| Formalidade mínima do destino | comentário de card interno ≠ resposta a cliente |
| O que um comentário de entrega precisa ter | |
| Convenção de título de card, issue ou PR | |

Se nada disso está decidido, deixe vazio. Vazio inventado é pior que vazio.>>

## Amostras fixadas

<<PREENCHER — **opcional**, e só se `integracoes.voz` for `amostras`.

Use quando o registro do destino for deliberadamente diferente do da conversa: alguém que instrui
de forma telegráfica aqui e escreve comentários longos no card, por exemplo.

Cole 2 ou 3 trechos reais, sem editar. Quando as amostras e a descrição acima discordarem, as
amostras vencem — elas são evidência, a descrição é memória.>>

## Quem publica

| `integracoes.publicacao_externa` | Comportamento |
|---|---|
| `rascunho` *(default)* | O agente redige e mostra. **Quem publica é você** |
| `confirmar` | O agente publica, mas só depois de você aprovar o texto exato nesta conversa |
| `automatica` | O agente publica direto. Só em fluxo já rodado muitas vezes |

Na dúvida, `rascunho`: publicar é ação para fora, e desfazer um comentário já lido não desfaz a
leitura.

## Anti-padrões

"Não seja robótico" não é instrução acionável. Estes são:

| Não | Em vez disso |
|---|---|
| "Foi realizada a implementação da funcionalidade de..." | "Implementei X." Voz ativa, sujeito explícito |
| Transformar três frases em sete bullets | Lista só quando os itens são mesmo paralelos |
| Repetir o título do card no corpo | Quem lê já está no card |
| "Conforme solicitado, segue o que foi desenvolvido" | Comece pelo que a pessoa precisa saber |
| Hedge corporativo — "possivelmente", "de certa forma" | Diga o que sabe e nomeie o que não sabe |
| Emoji decorativo e cabeçalho em texto de três linhas | Estrutura à altura do tamanho |
| Encerrar oferecendo ajuda genérica | Termine no próximo passo concreto, ou não termine com nada |

## A regra que vale mais que o estilo

**Nunca afirme mais certeza do que o trabalho sustenta.** Um comentário de entrega que diz
"testado e funcionando" sobre o que só foi lido é pior que um texto mal escrito — o segundo
irrita, o primeiro engana quem revisa.

Critério não atendido entra dito, com o motivo. Divergência entre o planejado e o entregue entra
dita. Plano que mudou no meio não é problema; plano que mudou em silêncio é.

> Imitar a voz de alguém **não** inclui imitar confiança que a pessoa teria e você não tem.
> Quando a voz da conversa é assertiva e o seu trabalho não sustenta a asserção, vence o trabalho.
