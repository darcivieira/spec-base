# Definition of Done

Uma tarefa só está pronta quando **todos** os itens aplicáveis estão marcados.
Declarar concluído com item pendente é violação — sinalize o que falta.

> **Este checklist é reutilizável e nunca é marcado aqui.** Marcá-lo faria a próxima mudança
> herdar as caixas da anterior — e a partir daí ele deixa de dizer qualquer coisa.

Onde a verificação é registrada depende de `guardas.dod_por_mudanca` em `.spec-base.json`:

| `dod_por_mudanca` | Onde a verificação fica registrada |
|---|---|
| **Ligado** | Em `mudancas/<id>/dod.md`, a partir de `_templates/MUDANCA-dod.md` |
| **Desligado** | Na conversa, durante o `spec-fechar` — sem artefato |

Com o artefato, valem três estados e só três: `[x]` **com o como** na mesma linha — "passa" sem
o comando não é verificação —, `[ ]` não atendido **com o motivo**, `[n/a]` **com a razão**.

## Sempre

- [ ] Comportamento bate com o que está em `mudancas/<id>/spec.md`
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

## Gates específicos do projeto

<<PREENCHER: cobertura mínima, budget de bundle, verificação visual, verificação de segurança.

Escreva cada gate como algo **checável por comando**, não como intenção. O teste: dá para colar
o comando no CI? Se não dá, o gate vai ser marcado de memória.

Se a governança tiver 06 e 07, os gates que eles impõem entram aqui — por exemplo:
- [ ] Mudança na superfície pública tem ADR escrito, e quem precisa foi avisado antes do merge
- [ ] Campo novo de dado pessoal tem justificativa de uso registrada no PR
- [ ] Nenhum dado pessoal em log, URL ou query string
- [ ] Nenhum arquivo já publicado foi editado; a alteração veio em arquivo novo
>>
