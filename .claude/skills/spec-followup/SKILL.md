---
name: spec-followup
description: Registra um achado que não pertence à mudança em curso, ou uma entrega parcial do mesmo card, em specs/mudancas/<id>/followups.md. Use sempre que aparecer um problema, dívida ou oportunidade fora do escopo do que está sendo feito — inclusive quando o usuário disser "anota isso pra depois", "isso aqui tá errado mas não é agora", "abre um card pra isso". Use também quando parte do trabalho for entregue antes do resto e precisar ser reportada no card.
---

# spec-followup

Dá destino ao que foi encontrado e não cabe agora.

## Por que existe

Achado sem destino é uma nota que morre. Ele aparece no meio da execução, quando a atenção está
em outro lugar — e se o único momento de registro for o fechamento, ele é escrito de memória
horas depois, sem o caminho do arquivo, sem a evidência, sem metade do que importava.

## Regra que define esta skill

> **Quem acha, registra. Não conserta.**

Consertar o que se achou pelo caminho é a expansão silenciosa de escopo que a spec existe para
impedir. O revisor recebe um diff que não bate com o plano aprovado, e não tem como saber o que
foi decidido e o que foi improviso.

Exceção única: 🟢 GREEN de uma linha, declarada. Continua valendo o
`echo "GREEN: <motivo>" > specs/ACTIVE.md`.

## Passo 1 — Decidir se é achado ou entrega parcial

| É… | Quando |
|---|---|
| **Achado** | Encontrei algo que não é desta mudança |
| **Entrega parcial** | Este card sai por partes, e uma delas ficou pronta |

Se for entrega parcial, faça antes a pergunta que evita o erro mais comum: **as porções têm risco
ou revisão diferentes?** Se têm, isto não é entrega parcial, é **fatiamento** — e a decisão volta
para o `spec-nova`, com subtarefa, branch e PR próprios por fatia. Ver
`specs/governanca/09-fluxo-de-trabalho.md`.

## Passo 2 — Escrever

Arquivo: `specs/mudancas/<id>/followups.md`, a partir de `specs/_templates/MUDANCA-followups.md`.
Crie se não existir; **anexe** se existir. Nunca reescreva blocos anteriores.

Todo achado precisa dos cinco campos, e três deles são onde o registro costuma falhar:

- **O quê** — com caminho e linha. Evidência, não impressão. "O tratamento de erro está ruim" não
  é achado; "`src/api/client.ts:88` engole a exceção e devolve lista vazia" é
- **Por que não é desta mudança** — se você não consegue escrever isso, provavelmente **é** desta
  mudança, e a resposta certa é conversar sobre escopo, não registrar follow-up
- **Destino** — card novo, comentário no card atual, ADR, documento, ou descartado. Sem destino,
  não registre: pare e pergunte qual é

## Passo 3 — Rotear, se for agora

Se o destino for fora do repositório e você tiver a integração disponível, redija o texto e siga
`.spec-base.json` → `integracoes.publicacao_externa`:

| Valor | O que fazer |
|---|---|
| `rascunho` *(default)* | Mostre o texto e **pare**. Quem publica é o humano |
| `confirmar` | Apresente o texto exato e publique só depois do "pode" |
| `automatica` | Publique e anote a referência no campo **Estado** |

O texto sai com o nome de uma pessoa: siga `specs/governanca/10-voz.md`. No default a referência
é a própria conversa — mas lembre que instrução para uma ferramenta é mais curta que um
comentário para colegas: transporte o vocabulário, não a economia.

Atualize o campo **Estado** com a referência real — `registrado em PROJ-58`. Estado sem
referência é o mesmo que pendente.

## Passo 4 — Devolver

Uma linha por item registrado, e nada mais:

```
FOLLOW-UP F-3 · destino: card novo · estado: rascunho, aguardando você publicar
```

Não retome a tarefa principal por conta própria se ela estava parada. Registre e devolva o
controle.

## Ao fechar a mudança

O `spec-fechar` percorre este arquivo. **Nada sai como pendente:** ou virou registro em algum
lugar, ou foi descartado com motivo escrito. `python3 scripts/spec_check.py --ci` reprova mudança
concluída com achado sem destino ou ainda pendente.

## Erros a evitar

| Erro | Em vez disso |
|---|---|
| Consertar o achado "já que está aqui" | Registrar e seguir |
| Registrar impressão sem evidência | Caminho, linha, e o que acontece |
| Deixar o destino em branco "para decidir depois" | Perguntar agora — depois ninguém decide |
| Marcar entrega parcial quando era fatiamento | Voltar ao `spec-nova` |
| Publicar comentário sem o humano ver | Respeitar `publicacao_externa` |
| Acumular achados para escrever no fim | Anexar no momento em que aparecem |
