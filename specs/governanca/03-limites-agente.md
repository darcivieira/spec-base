# Limites do agente — GREEN / YELLOW / RED

**Classifique toda mudança antes de tocar em qualquer arquivo.** Em caso de dúvida entre
dois níveis, assuma o mais alto. Declare a classificação em voz alta antes de agir.

---

## 🟢 GREEN — pode executar direto

Sem spec, sem aprovação. Reversível e de escopo local.

- Correção de typo, comentário, texto de log
- Formatação, lint, organização de imports
- Teste novo que não altera comportamento de produção
- Refactor local que **não muda assinatura pública nem comportamento observável**
- Correção de bug com causa evidente, em um arquivo, com teste que a comprova
- Preencher `<<PREENCHER>>` em spec a partir de informação que o humano acabou de dar

**Regra de corte:** se você não consegue descrever a mudança em uma frase sem "e",
não é GREEN.

---

## 🟡 YELLOW — exige spec de mudança antes de codar

Fluxo obrigatório: `spec-nova` → `spec-plano` → aprovação humana → implementar.

- Endpoint, rota, tela ou componente compartilhado novo
- Mudança de comportamento visível ao usuário
- Alteração aditiva de schema (coluna nova nullable, campo opcional)
- Mudança que toca **3 ou mais módulos/arquivos**
- Qualquer requisito com ambiguidade real (você precisaria supor algo para prosseguir)
- Alteração em regra de negócio existente
- Mudança de estado/fluxo de dados no frontend que afeta mais de uma tela

---

## 🔴 RED — exige spec + ADR + aprovação humana explícita

Nunca execute sem um "pode ir" literal do humano nesta conversa.

- Migration destrutiva ou de perda de dados (drop, rename, mudança de tipo, backfill)
- Quebra de contrato público (API, evento, formato de arquivo, props de componente exportado)
- Dependência nova, remoção de dependência, ou upgrade de versão maior
- Autenticação, autorização, criptografia, gestão de segredos, multi-tenancy
- Alteração em `specs/governanca/01-constituicao.md`
- Exclusão de arquivos, `git reset`, `git push --force`, reescrita de histórico
- Mudança em CI/CD, infraestrutura, ou qualquer coisa que toque produção
- Introduzir camada, padrão arquitetural ou biblioteca de estado novos
- Manipular dados reais de usuário
<<PREENCHER: itens RED específicos deste projeto>>

---

## Protocolo de bloqueio

Ao identificar YELLOW ou RED, **pare antes de editar** e responda no formato:

```
CLASSIFICAÇÃO: 🟡 YELLOW
MOTIVO: cria endpoint novo e toca 4 arquivos
PRÓXIMO PASSO: rodar a skill `spec-nova` para especificar antes de implementar
```

Se o humano pedir para pular a spec, isso é permitido — mas registre no commit
`[spec-skip]` e o motivo. Nunca pule silenciosamente.
