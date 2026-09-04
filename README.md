# spec-base

Base de especificações para desenvolvimento assistido por agentes. Você instala num projeto,
responde a uma entrevista, e o agente passa a trabalhar com regras verificáveis em vez de boa
vontade.

```bash
curl -fsSL https://raw.githubusercontent.com/darcivieira/spec-base/master/install.sh | sh
```

Depois abra o Claude Code e rode a skill `spec-bootstrap`. Prompt pronto em
[BOOTSTRAP.md](BOOTSTRAP.md).

---

## O problema

Agente de código é bom em escrever e ruim em lembrar. Numa sessão longa, a regra que você deu no
começo compete com tudo o que veio depois — e perde. O resultado conhecido: a feature sai, e junto
sai um refactor que ninguém pediu, uma dependência nova, um schema alterado, e nenhum registro do
porquê de nada disso.

Documentar mais não resolve, porque o problema não é falta de documento: é que **documento não
bloqueia**. Uma regra que depende de alguém ter lido um arquivo falha exatamente quando mais
importa.

## O que esta base faz

Separa o que **é regra** do que **é lembrete**, e dá mecanismo ao primeiro.

| | Como funciona | Falha quando |
|---|---|---|
| **Skills** | Disparam pelo pedido e conduzem o processo | O pedido não casa com a descrição. É probabilístico |
| **Hooks** | Bloqueiam a ferramenta antes de ela rodar | Nunca. Ou bloqueia, ou não |
| **`spec_check.py`** | Reprova a convenção violada, no CI | Nunca |

Você escolhe quanto disso quer ligado. O default não bloqueia nada além do essencial.

## O que você recebe

```
specs/
├── ACTIVE.md                 # a mudança em curso — fonte da verdade do "onde estou"
├── governanca/               # regras vinculantes, lidas antes de qualquer código
│   ├── 01-constituicao.md    # invariantes, cada um dizendo onde é verificado
│   ├── 02-convencoes.md      # naming, layout, propriedade de fatos
│   ├── 03-limites-agente.md  # GREEN · YELLOW · RED · ⛔ SEM EXCEÇÃO
│   ├── 04-definition-of-done.md
│   ├── 05-anatomia.md        # skeletons copiáveis
│   └── 06 a 10               # decisão · dados · guardas · fluxo · voz   (opcionais)
├── visao/  arquitetura/  dados/  modulos/  ui/  testes/
├── mudancas/<id>/            # spec · plan · tasks · dod · followups
└── _templates/
```

Mais cinco skills, três agentes encadeados, dois hooks e um verificador.

### Os dois tipos de spec

| Tipo | Responde | Vida |
|---|---|---|
| **Estado** — `modulos/`, `ui/`, `dados/`, `arquitetura/` | "o que o sistema **é** hoje" | Permanente |
| **Mudança** — `mudancas/<id>/` | "o que estou fazendo **agora**, e por quê" | Absorvida no estado ao concluir |

Confundir os dois é o erro mais comum: spec de estado não tem tarefas, spec de mudança não
descreve o sistema inteiro.

## O ciclo

```
classificar → spec-nova → spec-plano → aprovação humana → executor → validador → spec-fechar
   🟢 GREEN ────────────────── implementa direto ──────────────────────────────────┘
```

O agente **classifica em voz alta** antes de tocar em arquivo. GREEN — typo, formatação, refactor
local — segue direto; burocracia em mudança trivial destrói a adesão ao processo. YELLOW e RED
param e passam por spec, plano e aprovação.

Acima do RED existe **⛔ SEM EXCEÇÃO**: commit em branch protegida, edição de migration já
publicada, reescrita de histórico. A diferença é que RED espera um "pode ir" literal e este não
espera nada — porque uma autorização dada em dez segundos não é proporcional a um estrago de dias.

## Os três agentes

| Agente | Faz | Escreve código? |
|---|---|---|
| `planejador` | Especifica e desenha | Não |
| `executor` | Implementa o plano aprovado | Sim |
| `validador` | Procura o que falta, de forma adversarial | **Não — read-only** |

O `validador` lê a spec **antes** do código, de propósito. Na ordem inversa ele validaria o que
foi construído em vez do que foi pedido — e o defeito passa.

## As três guardas — todas opcionais

| Guarda | Impede |
|---|---|
| `require-spec.sh` | Editar código sem mudança especificada e aprovada |
| `guard-branch.sh` | Commit, push ou merge direto em branch protegida |
| `dod_por_mudanca` | Fechar mudança sem verificar o Definition of Done item a item |

O bootstrap pergunta cada uma com o custo dito antes. Ligar depois é fácil; **desligar exige
ADR** — em silêncio, transforma um sistema verificado num que parece verificado.

## Identificador de mudança

O nome do diretório de uma mudança vem de `.spec-base.json`:

| Esquema | Diretório | Quando serve |
|---|---|---|
| `sequencial` | `001-slug` | Trabalho solo |
| `rastreador` | `PROJ-42-slug` | Duas ou mais pessoas — ninguém escolhe o número, ninguém colide |
| `multiplo` | `PROJ-42-slug` + espelho no frontmatter | Controle em dois sistemas (Jira **e** GitHub Issues) |

Nos dois últimos, **sem card não existe nome de diretório válido** — a regra deixa de depender de
memória. `python3 scripts/spec_check.py --relacionar` imprime a tabela mudança ↔ card ↔ issue.

Migração entre esquemas: [MIGRAR-IDENTIFICADOR.md](MIGRAR-IDENTIFICADOR.md).

## Follow-ups

Achado fora de escopo tem lugar próprio, e a regra é uma:

> **Quem acha, registra. Não conserta.**

Consertar o que se achou pelo caminho entrega ao revisor um diff que não bate com o plano
aprovado, e ele não consegue separar o decidido do improvisado. `followups.md` também cobre
entrega parcial de um card que sai por partes.

## Configuração

Tudo num arquivo na raiz, `.spec-base.json`:

```bash
python3 scripts/spec_check.py --explicar    # o que cada chave faz
python3 scripts/spec_check.py --ci          # exit 1 se a convenção foi violada
python3 scripts/spec_status.py              # o que ainda falta preencher
```

## Documentos

| Arquivo | Para quê |
|---|---|
| [INSTALAR.md](INSTALAR.md) | Instalação, guardas, e como testá-las antes de confiar |
| [BOOTSTRAP.md](BOOTSTRAP.md) | O prompt de inicialização, e as variantes |
| [ATUALIZAR.md](ATUALIZAR.md) | Atualizar uma base já em uso |
| [MIGRAR-IDENTIFICADOR.md](MIGRAR-IDENTIFICADOR.md) | Trocar o esquema de identificador |

## Limites honestos

Coisas que esta base **não** resolve, ditas aqui para você não descobrir depois:

- **Apagar arquivo não passa por hook.** Exclusão não usa `Edit` nem `Write`. A proteção contra
  apagar migration versionada vem da regra escrita e da revisão de PR, não do mecanismo.
- **Decisões conflitantes em paralelo continuam passando.** Duas pessoas alteram a superfície
  pública de módulos vizinhos na mesma semana, cada uma com o ADR correto, e a integração quebra.
  Os dois ADRs seguem certos, e o sistema errado. A mitigação é revisão conjunta periódica — não
  há mecanismo que cubra isso.
- **O disparo de skill é probabilístico.** Depende de o pedido casar com a descrição. Se a
  garantia importa, ligue as guardas ou invoque a skill pelo nome.
- **"Publicado" é um proxy.** O hook considera publicado o arquivo que já existe na branch
  principal remota. Migration aplicada só no ambiente local de alguém não é detectada.

## Licença

<<PREENCHER: escolha uma licença, ou declare que o repositório é privado.>>
