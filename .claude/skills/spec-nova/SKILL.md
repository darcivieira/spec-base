---
name: spec-nova
description: Cria a especificação de uma mudança em specs/mudancas/<id>/spec.md antes de qualquer código ser escrito. Use sempre que o usuário pedir uma feature nova, uma alteração de comportamento, um endpoint, uma tela, ou qualquer mudança classificada como YELLOW ou RED em specs/governanca/03-limites-agente.md — mesmo que ele peça "só implementa rápido". Use também quando o pedido tiver ambiguidade de requisito ou tocar três ou mais arquivos.
---

# spec-nova

Transforma um pedido em requisito verificável **antes** de existir código.

## Passo 1 — Classificar

Leia `specs/governanca/03-limites-agente.md` e declare no formato:

```
CLASSIFICAÇÃO: 🟡 YELLOW
MOTIVO: <uma frase>
```

Se for 🟢 GREEN, **não crie spec**. Diga que é GREEN e implemente direto —
burocracia em mudança trivial destrói a adesão ao processo.

## Passo 2 — Contexto

Carregue o mínimo: `governanca/01-constituicao.md`, `visao/GLOSSARIO.md`, e os
`modulos/` ou `ui/telas/` que o pedido toca. Não carregue `specs/` inteiro.

Verifique `specs/ACTIVE.md`. Se já houver mudança em curso, pergunte antes de abrir outra —
duas frentes simultâneas é como o processo apodrece.

## Passo 2.5 — Não se limite às skills desta base

Antes de desenhar qualquer coisa, olhe **o que está disponível nesta sessão** — skills e agentes,
não só os `spec-*`. Eles estão listados no seu contexto; não há cadastro a consultar nem nada a
instalar.

**Se existe uma que serve a este pedido, acione-a agora, na especificação.** Não deixe para a
execução: uma spec escrita em cima de diagnóstico é outra coisa de uma spec escrita em cima de
hipótese — e a segunda *parece* igualmente fundamentada, que é o problema.

| Situação | O que fazer |
|---|---|
| Spider parou de retornar itens, e há um agente de investigação de scraping | O diagnóstico vem dele. A spec descreve o que ele achou |
| Tela nova, e há uma skill de modelagem ou de design | Chame-a para o desenho da interface antes de escrever os RFs |
| Domínio que você não conhece, e há skill que o cobre | Leia-a antes de propor |

O julgamento é simples: **serve a este pedido e chega ao resultado com mais eficiência?** Se
serve, use. Estar fora deste conjunto de skills não é motivo para ignorar.

A regra vale em toda etapa — especificar, desenhar, implementar, testar, depurar. Aqui ela pesa
mais só porque acionar cedo muda **o que se especifica**; acionar depois só confirma o que já
foi decidido.

Dois limites, para não virar delegação por delegação:

- Subagente quando poupa o contexto principal ou quando a especialização é real — não porque
  está disponível
- Nada de **criar** skill ou agente aqui. Se faltou capacidade, diga isso no resumo; criar é
  🔴 RED e passa por aprovação

## Passo 3 — Interrogar

Escreva o rascunho e marque **cada suposição** com `[PRECISA DECISÃO]`. Depois pergunte
apenas sobre elas — no máximo 5 por vez, com opções concretas, não perguntas abertas.

Perguntas que sempre valem a pena:
- O que acontece no caminho infeliz? (dado ausente, permissão negada, serviço fora)
- Isso muda algo que já está em produção?
- Qual o comportamento com volume grande / lista vazia?
- Quem pode fazer isso?

## Passo 4 — Escrever

Nomeie o diretório conforme `identificador.esquema` em `.spec-base.json`:

| Esquema | Nome | Como obter |
|---|---|---|
| `sequencial` | `001-slug` | Próximo número livre em `specs/mudancas/`, 3 dígitos |
| `rastreador` / `multiplo` | `<chave>-<slug>` | A chave vem do card. **Sem card, crie o card antes** — não existe nome válido sem ele |

Com `fatiamento` ligado, trabalho com partes de **risco ou revisão diferentes** vira
`<chave>-<fatia>-<slug>`, uma subtarefa por fatia, decidido aqui e não depois. Fatie por
risco, não por ordem: duas partes que só se sucedem no tempo são dois commits, não duas
mudanças.

No esquema `multiplo`, preencha também o campo de espelho no frontmatter — `spec_check.py`
reprova sem ele. Formato completo em `specs/governanca/02-convencoes.md`.
Use `specs/_templates/MUDANCA-spec.md`. Preencha tudo, especialmente:

- **Fora de escopo** — o que impede expansão silenciosa
- **RF numerados e testáveis** — se não dá para escrever o teste, o RF está vago
- **Critérios de aceite** em Dado/Quando/Então
- **Impacto no existente** com caminhos reais, obtidos por leitura do código

Atualize `specs/ACTIVE.md` com o id da mudança.

## Passo 5 — Parar

Nenhum `[PRECISA DECISÃO]` pode sobreviver. Resolva todos com o humano.

Depois: apresente um resumo curto e **pare**. Não gere plano, não escreva código.
O próximo passo é a skill `spec-plano`, e ele é do humano.
