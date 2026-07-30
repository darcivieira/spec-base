# Definition of Done

Uma tarefa só está pronta quando **todos** os itens aplicáveis estão marcados.
Declarar concluído com item pendente é violação — sinalize o que falta.

## Sempre

- [ ] Comportamento bate com o que está em `mudancas/NNN/spec.md`
- [ ] Nenhum requisito da spec ficou sem implementação nem sem justificativa registrada
- [ ] Spec de estado atualizada (`modulos/`, `ui/`, `dados/`) — checklists marcados
- [ ] Lint e type-check passam
- [ ] Testes passam; testes novos cobrem os critérios de aceite da spec
- [ ] Sem `TODO`, código morto ou comentado deixado para trás
- [ ] Sem segredo, credencial ou dado real em código, teste ou log
- [ ] Erros tratados com contexto; nada de falha silenciosa
- [ ] Decisão não-óbvia registrada como ADR

## Backend (quando aplicável)

- [ ] Entrada e saída validadas por schema declarado; nada de tipo solto
- [ ] Autorização verificada na camada correta, não na borda apenas
- [ ] Migration reversível e testada em base com dados
- [ ] Consultas novas sem N+1; índice existe para o filtro usado
- [ ] Log estruturado nos pontos de decisão e falha
- [ ] Operação idempotente onde o contrato exige (retry, webhook, fila)

## Frontend (quando aplicável)

- [ ] Os quatro estados implementados: **carregando, vazio, erro, sucesso**
- [ ] Erro de rede tratado com mensagem acionável — não tela branca
- [ ] Tokens do design system usados; zero valor cru de cor/espaçamento
- [ ] Navegável por teclado; foco visível; ordem de foco correta
- [ ] Rótulos acessíveis em controles; contraste conforme meta de a11y
- [ ] Layout verificado nos breakpoints declarados em `ui/DESIGN_SYSTEM.md`
- [ ] Nenhum dado sensível em `localStorage` ou em log de console
- [ ] Sem regressão perceptível de performance de render em lista longa

<<PREENCHER: gates específicos do projeto — cobertura mínima, budget de bundle,
verificação visual, etc.>>
