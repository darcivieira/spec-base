---
name: spec-bootstrap
description: Entrevista o desenvolvedor e preenche a base de specs (specs/) de um projeto novo ou já existente, depois conecta tudo ao CLAUDE.md. Use sempre que o usuário pedir para inicializar, configurar, adotar ou "ligar" o sistema de specs, quando mencionar preencher a governança/constituição do projeto, quando houver marcadores <<PREENCHER>> em specs/, ou quando pedir para o Claude Code passar a seguir as specs do projeto. Use também quando o usuário acabar de descompactar ou copiar a pasta specs/ para um repositório.
---

# spec-bootstrap

Preenche a base de specs por **entrevista**, nunca por suposição.

## Princípio inegociável

Você **não inventa** conteúdo de spec. Cada fato preenchido vem de (a) resposta do humano,
ou (b) leitura direta do código, apresentada ao humano e **confirmada** por ele.

Se você não tem o fato, deixa `<<PREENCHER: ...>>` e diz explicitamente o que ficou pendente.
Spec inventada é pior que spec vazia: o agente futuro vai confiar nela.

## Fase 0 — Reconhecimento

1. Verifique se `specs/` existe. Se não existir, avise que a base precisa ser copiada antes.
2. Determine o tipo de projeto:
   - **Existente:** há código-fonte além de config.
   - **Novo:** repositório vazio ou só scaffolding.
3. Se **existente**, delegue a varredura para um subagente de exploração (read-only) e peça:
   - linguagens, frameworks e versões (a partir de arquivos de manifesto)
   - layout de diretórios de topo e o padrão que ele sugere
   - módulos / bounded contexts aparentes
   - rotas de API e rotas de frontend existentes
   - entidades / modelos de dados
   - biblioteca de componentes e origem dos tokens visuais
   - comandos reais (scripts de package manager, Makefile, CI)
   - o que já existe de doc (README, ADRs, comentários de arquitetura)

   Subagente evita que a varredura consuma o contexto principal.

4. Apresente o resultado como **proposta**, em tabela, e peça confirmação:
   > "Detectei isto. Confirma, corrige ou completa?"

   Nunca escreva em `specs/` antes desta confirmação.

## Fase 1 — Entrevista

Regras da entrevista:
- **Um bloco por vez.** Espere a resposta antes do próximo.
- Ofereça o que você detectou como resposta padrão — o humano só corrige.
- Aceite "não sei" e "depois": vira `<<PREENCHER>>`, não vira invenção.
- No máximo 5 perguntas por bloco.
- **Escreva os arquivos de cada bloco antes de passar ao próximo.** Se a conversa for
  interrompida, o que já foi respondido está salvo.

### Bloco A — Produto → `visao/PRODUTO.md`, `visao/GLOSSARIO.md`
1. O que o sistema faz, em uma frase?
2. Que problema resolve, para quem, e qual é a alternativa que as pessoas usam hoje?
3. O que ele explicitamente **não** faz? (não-objetivos)
4. Quais termos de domínio um dev novo entenderia errado?
5. Alguma restrição dura — prazo, regulatório, integração obrigatória, legado intocável?

### Bloco B — Escopo técnico → `arquitetura/VISAO_TECNICA.md`
1. O projeto tem backend, frontend, ambos, mobile? Monorepo ou repos separados?
2. Stack e versões por camada (confirme o detectado).
3. Como backend e frontend mantêm o contrato em sincronia — codegen, tipos compartilhados, manual?
4. Quais processos existem além do servidor web (workers, cron, filas)?
5. Quais ambientes existem e o que difere entre eles?

Se **não houver frontend**, remova `specs/ui/` e as linhas de UI do DoD. Não deixe seção
vazia — seção vazia vira ruído de contexto.
Se **não houver backend**, remova `dados/` e as linhas de backend do DoD.

### Bloco C — Convenções → `governanca/02-convencoes.md`
1. Onde vai cada tipo de coisa? (peça 5 a 8 linhas de "onde-vai-o-X" com caminhos reais)
2. Convenções de nomeação e sufixos obrigatórios.
3. Comandos exatos: instalar, rodar, testar, lint, type-check, build, migration.
4. Padrão de commit e de branch.
5. Idioma de mensagem ao usuário final e de commit.

### Bloco D — Constituição → `governanca/01-constituicao.md`
1. Quais regras de dependência entre camadas nunca podem ser violadas?
2. O que um code review reprovaria automaticamente neste projeto?
3. Que padrão o projeto segue hoje que um agente provavelmente quebraria por não saber?
4. Que dívida existe hoje que **não** deve ser "consertada de surpresa"?

Pergunta 4 é a mais importante e a mais esquecida: agente que "melhora" código legado
sem pedir causa mais dano que ausência de spec.

### Bloco E — Limites → `governanca/03-limites-agente.md`
1. O que o agente **nunca** pode fazer sem seu "pode ir" literal? (além da lista padrão RED)
2. Quais diretórios ou arquivos são intocáveis?
3. Existe dado real, produção ou integração com terceiro no ambiente local?

### Bloco F — Qualidade → `governanca/04-definition-of-done.md`, `testes/ESTRATEGIA.md`
1. O que se testa e o que deliberadamente não se testa?
2. Ferramentas de teste por nível e comandos.
3. Meta de cobertura e se o CI bloqueia.
4. Gates extras: bundle, performance, verificação visual, segurança.

### Bloco G — Frontend → `ui/DESIGN_SYSTEM.md`, `ui/COMPONENTES.md`
*(pule inteiro se não houver frontend)*
1. Design system próprio, biblioteca de terceiros, ou híbrido? Qual e versão?
2. Como os tokens são definidos e consumidos hoje?
3. Meta de acessibilidade (nível, contraste, suporte a leitor de tela)?
4. Breakpoints e comportamento em cada um.
5. Quais componentes compartilhados já existem? (confirme o detectado)

### Bloco H — Dados → `dados/INDICE.md`
*(pule se não houver persistência)*
1. Banco, ORM, ferramenta de migration.
2. Multi-tenancy? Qual estratégia?
3. Convenções universais: chave primária, timestamps, soft delete, auditoria.
4. Confirme a lista de entidades detectada e a que contexto cada uma pertence.

### Bloco I — Rastreamento → `.spec-base.json`, `governanca/09-fluxo-de-trabalho.md`

Este bloco decide **de onde vem o nome de uma mudança**. Apresente os três cenários e pergunte
qual descreve o projeto:

> 1. **Sequencial** — `001-slug`, contador local. Serve para trabalho solo.
> 2. **Rastreador** — o id vem do card: `PROJ-42-slug`. Duas pessoas não escolhem o mesmo,
>    porque nenhuma escolhe. E "sem card, crie o card antes" deixa de depender de memória:
>    não existe nome de diretório válido sem card.
> 3. **Múltiplo** — igual ao 2, e ainda exige que a mudança declare o id nos outros sistemas
>    em que é acompanhada (ex.: Jira **e** GitHub Issues), como espelho no frontmatter.

**O custo do 2 e do 3, dito antes da escolha:** o nome passa a depender de um sistema externo.
Se o projeto sair dele, os diretórios referenciam um sistema morto — conserto mecânico, `git mv`,
mas conserto. E `ls` deixa de mostrar a ordem cronológica do trabalho, porque `PROJ-2` pode ter
sido feito depois de `PROJ-20`.

Se escolher 2 ou 3, pergunte também:
1. Qual o padrão da chave? (ex.: `PROJ-\d+`, `GH-\d+`)
2. Um card pode ser **fatiado** em mudanças com risco diferente? Se sim, ligue `fatiamento`.
3. No múltiplo: qual sistema é o **primário**, isto é, dá o nome do diretório? Só um — o nome
   precisa de um dono, ou volta a colidir.

Grave em `.spec-base.json` e confirme com `python3 scripts/spec_check.py`.

Se escolher 1, **não escreva `governanca/09-fluxo-de-trabalho.md`** com os pontos do rastreador:
apague as colunas do card e deixe só as cadeias de specs e de git.

### Bloco J — Voz → `governanca/10-voz.md`

Só se aplica se o agente vai escrever algo que sai do repositório — comentário de card, descrição
de issue ou de PR, entrada de documento. Se nada sai, **apague o arquivo** e a linha dele no
índice.

**Não peça amostras como dever de casa.** O default é `conversa`: a amostra é como a pessoa
escreve para o agente, e ela é contínua e atual. Explique isso, e depois pergunte só o que a
conversa não entrega:

1. O registro do **destino** é diferente do da conversa? (alguém pode instruir de forma
   telegráfica aqui e escrever comentários longos no card). Se for, ofereça `amostras` — e aí
   sim peça 2 ou 3 trechos reais. Se a pessoa não quiser fixar nada, siga com `conversa`.
2. Existe convenção do **projeto** para o que sai? Idioma, formalidade mínima do destino, o que
   um comentário de entrega precisa ter, formato de título de card ou PR. Isso é do projeto e
   sobrevive à troca de quem escreve — o resto vem da pessoa.
3. Quem publica:

> - **`rascunho`** *(default)* — o agente redige e mostra; você publica. Desfazer comentário já
>   lido não desfaz a leitura
> - **`confirmar`** — o agente publica depois que você aprova o texto exato
> - **`automatica`** — o agente publica direto. Só em fluxo já rodado muitas vezes

Grave em `.spec-base.json` → `integracoes.voz` e `integracoes.publicacao_externa`.

Deixe vazio o que não estiver decidido. Registro de projeto inventado é pior que registro vazio.

### Bloco K — Guardas → hooks, `.spec-base.json`, `governanca/08-guardas.md`

Três guardas independentes. Pergunte **uma por vez**, com a consequência de ligar dita antes.

**K1 — `require-spec`: código exige mudança aprovada?**

> - **Ligado (modo estrito):** um hook bloqueia `Edit`/`Write` em código quando não há mudança
>   especificada e aprovada em `ACTIVE.md`. Garantia real, atrito real. Para trabalho trivial
>   existe a saída `echo "GREEN: <motivo>" > specs/ACTIVE.md`, que fica visível no diff.
> - **Desligado (consultivo):** as skills orientam, nada bloqueia. Sem atrito, e depende de
>   disciplina — em sessão longa a regra pode ser despriorizada.

Se ligado: instale o hook, registre em `.claude/settings.json` e **ajuste `caminhos.protegidos`**
aos diretórios reais. **Não ligue antes de a governança estar preenchida** — o hook bloqueia
contra uma spec vazia e a pessoa se tranca fora do próprio projeto.

**K2 — `guard-branch`: agente pode commitar na branch principal?**

> - **Ligado:** o hook bloqueia `git commit`, `push` e `merge` quando a branch atual — ou o
>   destino do push — está protegida. **Não tem exceção**: nem autorização na conversa libera.
>   Se for pedido, a resposta é criar a branch.
> - **O que muda no dia a dia:** todo trabalho começa com `git checkout -b`. Um agente que hoje
>   commita direto vai passar a parar e pedir a branch. É o atrito que se está comprando.
> - **Desligado:** nada muda. A proteção fica com a branch protection do servidor, se houver.

Vale ligar **mesmo com branch protection configurada**: lá a proteção só age no `push`, e a essa
altura o commit já está na branch errada, com histórico local a desfazer.

Pergunte os nomes reais: branch principal, branch de integração (pode não haver), e o padrão de
nome da branch de tarefa. Grave em `.spec-base.json` → `branches`.

**K3 — `dod_por_mudanca`: toda mudança escreve o seu próprio DoD?**

> - **Ligado:** ao fechar, cada mudança ganha um `dod.md` que percorre o Definition of Done
>   **item a item**, com três estados — `[x]` com *como* foi verificado, `[ ]` não atendido com
>   o motivo, `[n/a]` com a razão. Mais uma tabela requisito por requisito e uma seção de escopo
>   extra. `spec_check.py` reprova mudança concluída sem ele.
> - **O que isso resolve:** DoD marcado em bloco. Um checklist reutilizável marcado no fim, de
>   memória, vira ritual — e o item que ninguém verificou fica indistinguível do verificado.
>   O `dod.md` obriga a escrever a evidência ao lado da caixa, e torna visível o que **não** foi
>   atendido em vez de deixá-lo desaparecer.
> - **O que custa:** de 15 a 40 minutos por mudança, e uma tabela a mais para manter. Em mudança
>   pequena, é a parte mais longa do trabalho.
> - **Desligado:** o DoD de governança continua valendo e é verificado na conversa, sem artefato.

Recomende **ligado** quando houver revisão por terceiro, auditoria, ou mais de uma pessoa no
repositório; **desligado** para trabalho solo em ritmo alto.

Ao final do bloco, escreva `governanca/08-guardas.md` marcando o que ficou ligado, e diga que
qualquer uma pode ser ligada depois — desligar é que exige ADR.

## Fase 2 — Estado atual (só projeto existente)

Para cada módulo e tela detectados, crie o arquivo a partir do template com os checklists
**marcados conforme o código real**. Não invente requisito: descreva o que existe.

Ordem: comece pelos 2 ou 3 módulos mais movimentados. Os demais ficam com stub e
`<<PREENCHER>>`. Cobertura parcial honesta vale mais que cobertura total fabricada.

Se encontrar decisão arquitetural evidente e não registrada, proponha um ADR retroativo com
status `aceito` e data estimada — mas **só escreva depois de o humano confirmar o "porquê"**.
O porquê não está no código.

## Fase 3 — Conectar ao CLAUDE.md

1. Se `CLAUDE.md` não existe, crie.
2. Insira o bloco de `.claude/CLAUDE.md.bloco` entre os marcadores
   `<!-- SPEC-BASE:INICIO -->` e `<!-- SPEC-BASE:FIM -->`.
3. Se os marcadores já existem, **substitua só o conteúdo entre eles**. Nunca sobrescreva
   o resto do arquivo.
4. Preencha os placeholders do bloco com os caminhos reais deste projeto.
5. O bloco tem três seções entre `<!-- OPCIONAL -->` e `<!-- FIM OPCIONAL -->`: branches
   protegidas, fluxo do card, e DoD por mudança. **Apague inteira a seção cujo recurso ficou
   desligado** nos blocos I, J e K, e remova os comentários `OPCIONAL` das que ficarem. Regra que
   descreve um mecanismo desligado ensina o agente a não confiar no arquivo.
6. Se alguma regra ⛔ SEM EXCEÇÃO do bloco E não estiver coberta por hook, escreva-a **fora**
   dos marcadores, no corpo do `CLAUDE.md`, e também no `AGENTS.md` se ele existir. Regra que
   depende de o agente ter lido um arquivo de governança falha em sessão longa.

## Fase 4 — Fechamento

Rode `python3 scripts/spec_status.py` e `python3 scripts/spec_check.py` e apresente:

- tabela do que foi preenchido, por arquivo
- lista dos `<<PREENCHER>>` restantes, ordenada por impacto
- esquema de identificador escolhido, e as guardas ligadas — o que cada uma bloqueia na prática
- **os 3 próximos passos**, concretos

Termine com uma pergunta única: qual pendência atacar primeiro.

## Erros a evitar

| Erro | Em vez disso |
|---|---|
| Fazer todas as perguntas de uma vez | Um bloco por vez, escrevendo entre eles |
| Preencher com genérico plausível | Deixar `<<PREENCHER>>` e nomear a lacuna |
| Escrever antes de confirmar a detecção | Propor em tabela, esperar o "confirma" |
| Manter seções que não se aplicam | Remover `ui/` ou `dados/` se não houver |
| Escrever ADR retroativo pelo código | Perguntar o porquê ao humano primeiro |
| Sobrescrever o CLAUDE.md existente | Editar só entre os marcadores |
