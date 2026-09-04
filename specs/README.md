# Specs — <<PREENCHER: nome do projeto>>

Base de especificações declarativas para desenvolvimento assistido por agentes.
Este diretório é **autoritativo**: quando código e spec divergem, um dos dois está errado
e a divergência precisa ser resolvida explicitamente, nunca ignorada.

## Os dois tipos de spec

| Tipo | Onde | Responde | Vida |
|---|---|---|---|
| **Estado** | `modulos/`, `ui/`, `dados/`, `arquitetura/` | "o que o sistema **é** hoje" | permanente, evolui |
| **Mudança** | `mudancas/<id>/` | "o que estou fazendo **agora** e por quê" | temporária, é absorvida no estado ao concluir |

Confundir os dois é o erro mais comum. Spec de estado não tem tarefas; spec de mudança não
descreve o sistema inteiro.

## Estrutura

```
specs/
├── ACTIVE.md                 # ponteiro para a mudança em curso (fonte da verdade do "onde estou")
├── governanca/               # REGRAS PARA O AGENTE — ler antes de qualquer código
│   ├── 00-indice.md
│   ├── 01-constituicao.md    # invariantes inegociáveis
│   ├── 02-convencoes.md      # naming, layout, propriedade de fatos
│   ├── 03-limites-agente.md  # classificação GREEN / YELLOW / RED
│   ├── 04-definition-of-done.md
│   ├── 05-anatomia.md        # skeletons copiáveis (backend e frontend)
│   ├── 06-decisao-e-registro.md  # quem decide, onde registra, quem avisa   (opcional)
│   ├── 07-protecao-de-dados.md   # dado pessoal como requisito              (opcional)
│   ├── 08-guardas.md             # o que os hooks bloqueiam                 (opcional)
│   ├── 09-fluxo-de-trabalho.md   # da demanda ao merge                      (opcional)
│   └── 10-voz.md                 # como o agente escreve com o seu nome     (opcional)
├── visao/                    # PRODUTO.md · ROADMAP.md · GLOSSARIO.md
├── arquitetura/
│   ├── VISAO_TECNICA.md      # topologia, camadas, fluxos de execução
│   └── adr/                  # um arquivo por decisão, imutável (ver adr/README.md)
├── dados/
│   ├── INDICE.md             # uma linha por entidade — carregado sempre
│   └── entidades/<mod>.md    # schema detalhado por contexto — carregado sob demanda
├── modulos/<mod>.md          # comportamento: endpoints, regras, contratos
├── ui/
│   ├── DESIGN_SYSTEM.md      # tokens, tipografia, espaçamento, tema
│   ├── COMPONENTES.md        # inventário de componentes e suas APIs
│   └── telas/<tela>.md       # rota, estados, dados, permissões, a11y
├── testes/ESTRATEGIA.md
├── mudancas/<id>/            # spec.md · plan.md · tasks.md · dod.md · followups.md
└── _templates/               # modelos para tudo acima
```

## Convenções

- **Idioma:** specs em português; identificadores de código em inglês.
- **Declarativo:** descreve *o quê* e *por quê*. O *como* de implementação fica no código;
  o *como* de desenho fica em `mudancas/<id>/plan.md`.
- **Contratos são spec, não implementação.** Schemas de request/response, props de componente
  e formatos de evento **devem** estar aqui. Só o corpo das funções fica fora.
- **Sem status textual.** Nada de "parcial". Use checklists — cada item marcável é verificável:
  ```markdown
  ### POST /recurso
  - [x] validação de payload
  - [ ] rate limit — bloqueado por <motivo>
  ```
- **Um dono por fato.** Ver `governanca/02-convencoes.md`. Nunca duplique um fato entre arquivos;
  referencie por nome.
- **Tamanho:** 200–400 linhas por arquivo. Acima de 500, divida.
- **Marcador de pendência:** duplo sinal de menor + `PREENCHER` + dois-pontos + descrição + duplo
  sinal de maior. Rode `python3 scripts/spec_status.py` para listar todos os que ainda existem.
- **Configuração:** `.spec-base.json`, na raiz do projeto, define o formato do `<id>` de mudança,
  as branches protegidas e quais guardas estão ligadas. `python3 scripts/spec_check.py --explicar`
  descreve cada chave; `--ci` reprova quando a convenção é violada.

## Como o agente deve carregar contexto

| Tarefa | Carregar |
|---|---|
| Qualquer mudança (sempre) | `governanca/03-limites-agente.md` + `ACTIVE.md` |
| Implementar módulo backend | `modulos/<mod>.md` + `dados/entidades/<mod>.md` + `governanca/05-anatomia.md` |
| Implementar tela/componente | `ui/telas/<tela>.md` + `ui/DESIGN_SYSTEM.md` + `ui/COMPONENTES.md` |
| Escrever testes | `modulos/<mod>.md` (seção Testes) + `testes/ESTRATEGIA.md` |
| Decisão técnica não-óbvia | `arquitetura/VISAO_TECNICA.md` + `arquitetura/adr/` |
| Texto que sai do repositório | `governanca/10-voz.md` |
| Onboarding | este README + `visao/PRODUTO.md` + `visao/GLOSSARIO.md` |

Carregue o **mínimo suficiente**. Puxar `dados/` inteiro para mexer num módulo é desperdício
de contexto e aumenta a chance de alucinação por ruído.

## Ciclo de trabalho

0. **Olhar o que está disponível.** As skills `spec-*` cobrem o processo, não o domínio. Em
   qualquer etapa — especificar, desenhar, implementar, testar, depurar — use a skill ou o
   agente que servir à necessidade e chegue ao resultado com mais eficiência. Criar capacidade
   nova, não: isso é RED.
1. **Classificar** a mudança (`governanca/03-limites-agente.md`) → GREEN, YELLOW ou RED.
2. **GREEN:** implementar direto.
3. **YELLOW/RED:** `spec-nova` → `spec-plano` → aprovação humana → implementar.
4. **Achou algo fora de escopo?** `spec-followup` — registra e **não conserta**. Também é onde
   entra a entrega parcial de um card que sai por partes.
5. **Concluir:** `spec-fechar` — absorve a mudança nos specs de estado, atualiza checklists,
   roteia os follow-ups, registra ADR se houve decisão não-óbvia, e limpa `ACTIVE.md`.
