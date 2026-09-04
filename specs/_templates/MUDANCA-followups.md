# Follow-ups — mudança <id>

O que **não** entra nesta mudança, e o que dela já foi entregue em parte. Escrito durante o
trabalho, não no fim: achado registrado de memória horas depois perde metade do que importava.

Duas seções, e elas não se misturam:

| Seção | Responde |
|---|---|
| **Achados** | Encontrei algo que não é daqui. Para onde vai? |
| **Entregas parciais** | Este card sai por partes. O que já saiu, e o que falta |

> **Achado não se conserta.** Quem encontra, registra. Consertar o que se achou pelo caminho é
> exatamente a expansão silenciosa de escopo que a spec existe para impedir — e o revisor recebe
> um diff que não bate com o plano aprovado.

---

## Achados

Um bloco por achado. `spec_check.py` reprova mudança concluída com achado sem destino, ou com
estado ainda `pendente`.

### F-1 — <título curto, o problema e não a solução>

- **O quê:** <o que existe hoje, com caminho e linha. Evidência, não impressão>
- **Por que não é desta mudança:** <o motivo de não entrar agora — escopo, risco, dependência>
- **Impacto se ficar como está:** <o que dói, e para quem. "Nada por enquanto" é resposta válida>
- **Destino:** <card novo · comentário no card <id> · ADR · doc <caminho> · descartado>
- **Estado:** <pendente · registrado em <referência> · descartado — <motivo>>

<!-- Copie o bloco acima para F-2, F-3… -->

---

## Entregas parciais

Use quando o **mesmo card** sai por partes. Isto **não é fatiamento**: fatiar cria mudanças
separadas, com spec, plano, branch e PR próprios, decidido no `spec-nova` por diferença de risco.
Aqui é uma mudança só, entregue em porções — normalmente porque o trabalho é grande e vale
mostrar antes de terminar.

Se as porções tiverem risco ou revisão **diferentes**, pare: era fatiamento, e a decisão volta
para o `spec-nova`.

### E-1 — <o que foi entregue nesta porção>

- **Data:** <AAAA-MM-DD>
- **Entregue:** <o que existe agora que não existia antes>
- **Requisitos cobertos:** <RF-1, RF-3 — os desta porção>
- **O que ainda falta:** <o resto, nomeado>
- **Dá para usar já?** <sim, com ressalva X · não, só faz sentido com a porção seguinte>
- **Registrado em:** <referência do comentário no card, ou "rascunho, não publicado">

<!-- Copie o bloco acima para E-2, E-3… -->

---

## Ao fechar

O `spec-fechar` percorre este arquivo e roteia cada item. Nada sai daqui como "pendente":
ou virou registro em algum lugar, ou foi descartado **com motivo escrito**.

O texto que vai para fora — comentário de card, descrição de issue, entrada de documento — sai
com o **seu** nome, e por isso o agente redige e você publica, salvo se
`integracoes.publicacao_externa` disser outra coisa.

O estilo vem de `specs/governanca/10-voz.md`. No default, a referência é como você escreve nesta
conversa — com um cuidado: instrução para uma ferramenta é mais curta que um comentário para
colegas. O que se transporta é o vocabulário e a forma de tratar incerteza, não a economia.
