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

## ⛔ SEM EXCEÇÃO — nenhuma autorização em conversa libera

O nível acima do RED, e a diferença é exatamente uma: **RED espera um "pode ir" literal; isto não
espera nada.** Se for pedido na conversa, a resposta não é executar com ressalva — é apontar a
regra e oferecer o caminho alternativo.

Existe porque algumas ações não têm desfazer barato, e "o humano autorizou" não reconstrói o que
foi perdido. Uma autorização dada em dez segundos não é proporcional a um estrago que leva dias.

- **Commitar, empurrar ou fazer merge direto em branch protegida.** A saída é criar a branch.
  Com `guard_branch` ligado, o hook bloqueia o comando de qualquer forma
- **Editar arquivo já publicado que outros ambientes já aplicaram** — migration é o caso típico.
  A saída é criar um arquivo novo. Nem a exceção `GREEN:` libera
- **Apagar arquivo versionado de migration, ou reescrever histórico já publicado**
  (`git push --force`, `rebase` de branch compartilhada, `reset --hard` sobre trabalho de outro)

<<PREENCHER: itens ⛔ específicos deste projeto. O teste para saber se algo pertence aqui e não
ao RED: **se o humano autorizasse agora, e desse errado, dava para desfazer?** Se a resposta é
não, ou "só refazendo o trabalho de outra pessoa", é ⛔.

Candidatos frequentes: rodapé de co-autoria de ferramenta em commit ou PR — corrigir depois de
publicado é caro, porque PR fechado no GitHub congela a lista de commits e não pode ser apagado;
tocar em fixture com dado real; desativar verificação de segurança do CI.>>

> Estes itens **não vivem só aqui**. Regra que depende de o agente ter lido este arquivo é regra
> que falha em sessão longa. O que couber em mecanismo vira hook ([08-guardas](08-guardas.md));
> o que não couber, vira linha no `CLAUDE.md` e no `AGENTS.md`, onde é lido sempre.

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

Para item ⛔ o formato é outro, porque não há próximo passo negociável:

```
CLASSIFICAÇÃO: ⛔ SEM EXCEÇÃO
MOTIVO: commit direto em `main`
NÃO VOU FAZER, mesmo autorizado. Alternativa: git checkout -b <tipo>/<id>-<slug>
```

Se o humano insistir, repita a alternativa uma vez e pare. Insistência não converte ⛔ em RED —
mas o humano sempre pode executar o comando ele mesmo, e isso é decisão dele, não sua.
