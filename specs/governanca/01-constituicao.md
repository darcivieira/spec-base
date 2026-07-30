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

<<PREENCHER: 5 a 10 regras concretas e verificáveis, com caminhos reais. Exemplos do formato:
- A camada de domínio não importa nada de `infra/` nem de framework web.
- Toda escrita em banco passa por repositório; nenhum acesso direto a ORM fora de `repositories/`.
- Nenhum componente de UI faz fetch direto; dados entram por props ou por hook de dados dedicado.
- Toda rota exposta declara schema de entrada e de saída; sem `dict` solto ou `any`.
- Migrations são a única forma de alterar schema; nenhum DDL manual.
>>

## Limites de escopo

<<PREENCHER: o que este sistema explicitamente NÃO faz. Não-objetivos evitam que o agente
"ajude" expandindo escopo.>>

## Governança

- Alterar este arquivo é uma mudança **RED** (ver `03-limites-agente.md`).
- Um invariante só cai por ADR que o revogue explicitamente.
