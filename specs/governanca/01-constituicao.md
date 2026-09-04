# Constituição

Invariantes deste projeto. São descritivos do que já é verdade, não aspiracionais —
se uma linha aqui não descreve o código real, ela está errada e deve ser corrigida.

## Princípios

1. **Pragmatismo sobre dogma.** Arquitetura é meio, não fim. Aplique a estrutura completa
   onde a complexidade paga por ela; resolva direto onde não paga. Justifique o excesso,
   não a simplicidade.
2. **Reuso antes de criação.** Antes de criar módulo, helper, componente ou camada nova,
   procure o existente. Criar sem justificar duplicação é violação.
3. **Nada de gold-plating.** Não implemente o que não foi pedido. Abstração especulativa
   ("vai que um dia precisamos de outro provider") é violação, salvo quando a spec pedir.
4. **Todo "porquê" não-óbvio vira ADR.** Se você tomou uma decisão que um dev competente
   questionaria em code review, registre em `arquitetura/adr/`.
5. **Falha explícita.** Nada de `except: pass`, `catch {}` silencioso ou fallback mudo.
   Erro se propaga com contexto ou é tratado com registro.
6. **Spec e código andam juntos.** Mudou o comportamento, atualizou a spec no mesmo commit.

## Invariantes técnicos

**Todo invariante termina dizendo onde é verificado.** Um invariante sem método de verificação
é um desejo: ninguém sabe se ele ainda vale, e a primeira violação passa em silêncio. Se você não
consegue nomear o que o checaria — um linter, um teste, um `grep` no CI, uma consulta ao banco —
a regra pertence a `02-convencoes.md`, não aqui.

Vale também "verificado em revisão de PR". É o método mais fraco, e escrevê-lo explicitamente é
melhor que fingir que existe automação.

<<PREENCHER: 5 a 10 regras concretas, com caminhos reais e método de verificação em cada uma.
Exemplos do formato:

1. **A camada de domínio não importa nada de `infra/` nem de framework web.**
   *Verificado por `<linter de import>` no CI.*
2. **Toda escrita em banco passa por repositório; nenhum acesso direto a ORM fora de
   `repositories/`.** *Verificado por grep no CI.*
3. **Nenhum componente de UI faz fetch direto; dados entram por props ou por hook dedicado.**
   *Verificado por regra de ESLint.*
4. **Toda rota exposta declara schema de entrada e de saída; sem `dict` solto ou `any`.**
   *Verificado por type-check e por teste de contrato.*
5. **Migrations são a única forma de alterar schema; nenhum DDL manual.**
   *Verificado por `upgrade`/`downgrade` em base limpa no CI.*
>>

## Limites de escopo

<<PREENCHER: o que este sistema explicitamente NÃO faz. Não-objetivos evitam que o agente
"ajude" expandindo escopo.>>

## Governança

- Alterar este arquivo é uma mudança **RED** (ver `03-limites-agente.md`).
- Um invariante só cai por ADR que o revogue explicitamente.
