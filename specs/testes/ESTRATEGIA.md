# Estratégia de testes

## Pirâmide deste projeto
<<PREENCHER: proporção pretendida e o que cada nível cobre. Seja concreto sobre o que
NÃO se testa — testar tudo é tão ruim quanto não testar.>>

| Nível | Cobre | Não cobre | Ferramenta |
|---|---|---|---|
| Unidade | | | <<PREENCHER>> |
| Integração | | | <<PREENCHER>> |
| Ponta a ponta | | | <<PREENCHER>> |

## Regras

- Todo critério de aceite de `mudancas/NNN/spec.md` vira ao menos um teste.
- Bug corrigido ganha teste que falha antes da correção. Sem exceção.
- Teste não acessa rede nem serviço externo real — use dublê.
- Teste não depende de ordem de execução nem de estado de outro teste.
- Nome do teste descreve o comportamento esperado, não o método chamado.

## Dados de teste
<<PREENCHER: fixtures, factories, banco de teste, política de dados sensíveis (nunca reais).>>

## Frontend
<<PREENCHER: o que se testa por comportamento visível ao usuário, política de teste de
componente vs teste de rota, e se há teste de regressão visual.>>

## Comandos
<<PREENCHER: comandos exatos, incluindo como rodar um teste isolado.>>

## Cobertura
<<PREENCHER: meta, o que é excluído da métrica, e se o CI bloqueia abaixo do limite.>>
