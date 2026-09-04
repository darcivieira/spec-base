# Convenções

## Propriedade de fatos (regra anti-divergência)

Cada fato tem **exatamente um dono**. Os demais arquivos referenciam por nome, nunca copiam.

| Fato | Dono | Os outros fazem |
|---|---|---|
| Campos, tipos e constraints de entidade | `dados/entidades/<mod>.md` | citam o nome da entidade |
| Endpoints, regras de negócio, contratos de API | `modulos/<mod>.md` | linkam o módulo |
| Rota, estados e dados de uma tela | `ui/telas/<tela>.md` | linkam a tela |
| API de componente (props, variantes) | `ui/COMPONENTES.md` | citam o componente |
| Tokens visuais (cor, espaço, tipografia) | `ui/DESIGN_SYSTEM.md` | usam o token, nunca valor cru |
| Decisão técnica e seu trade-off | `arquitetura/adr/NNNN-*.md` | linkam o ADR |
| Topologia, camadas e fluxo de execução | `arquitetura/VISAO_TECNICA.md` | linkam a seção |
| Termo de domínio | `visao/GLOSSARIO.md` | usam o termo |

Se você precisou copiar um fato para outro arquivo, a estrutura está errada — divida ou linke.

## Nomenclatura

- Specs em português; **identificadores de código em inglês**.
- Arquivo de módulo = nome do módulo em `kebab-case`: `modulos/risk-score.md`.
- Arquivo de tela = rota em `kebab-case`: `ui/telas/dashboard-cliente.md`.
- ADR: `NNNN-slug-curto.md`, numeração sequencial que nunca é reaproveitada.
- Mudança: `mudancas/<id>/` — o formato do `<id>` vem de `identificador.esquema` em
  [`.spec-base.json`](../../.spec-base.json). Ver abaixo.

### Identificador de mudança

Dono do fato: o formato vem de `identificador.esquema` em
[`.spec-base.json`](../../.spec-base.json), e é cobrado por `python3 scripts/spec_check.py`.

| Esquema | Formato | Exemplo | Quando serve |
|---|---|---|---|
| `sequencial` | `NNN-<slug>` | `001-login-por-email` | Trabalho solo. Um contador local basta |
| `rastreador` | `<chave>-<slug>` | `PROJ-42-login-por-email` | Duas ou mais pessoas |
| `multiplo` | `<chave do primário>-<slug>` + espelho no frontmatter | `PROJ-42-login-por-email` | Controle em dois sistemas |

Com `fatiamento` ligado, um card partido vira `<chave>-<fatia>-<slug>` — `PROJ-42-1-...`,
`PROJ-42-2-...`. O número é o da **fatia**, não a chave da subtarefa: a chave vem do contador
global do rastreador e não diz nada sobre ordem. E como o número só aparece quando houve
fatiamento, **a presença dele já informa** que o card foi partido.

**Por que o sequencial não escala além de uma pessoa:** o número é escolhido por quem cria o
diretório, olhando o próprio checkout. Dois trabalhos iniciados em paralelo escolhem `004` cada
um, e a colisão não aparece na criação — aparece **no merge**, quando os dois já têm spec, plano,
tarefas e commits amarrados ao nome. Nos outros dois esquemas ninguém escolhe o número, então
ninguém colide.

**O que se paga nos esquemas com rastreador:**

- O nome depende de um sistema externo. Se o projeto sair dele, os diretórios referenciam um
  sistema morto — conserto mecânico, `git mv`, mas conserto
- `ls` deixa de mostrar a ordem cronológica: `PROJ-2` pode ter sido feito depois de `PROJ-20`.
  A ordem fica com o campo `criada:` e com o git
- Numa fatia, `grep -r <chave da subtarefa>` **não acha o diretório** — o nome carrega
  `PROJ-42-2`, não a chave da subtarefa. Quem tropeçar nisso vai achar que é bug; não é.
  O campo de espelho no frontmatter cobre a busca

**Frontmatter.** No esquema `rastreador`, a spec declara o card. No `multiplo`, declara também
cada espelho listado em `espelho_obrigatorio` — sem isso o `spec_check` reprova:

```yaml
card: PROJ-42
subtarefa: PROJ-58     # só quando houve fatiamento
issue: GH-340          # espelho, no esquema multiplo
```

`python3 scripts/spec_check.py --relacionar` imprime a tabela mudança ↔ card ↔ issue. É o
inventário que um projeto com controle em dois sistemas normalmente não tem em lugar nenhum.

> **A numeração de ADR não segue esta regra** e é sempre sequencial, em qualquer esquema: um ADR
> nasce de uma decisão, e uma decisão atravessa cards. Alguém vai querer uniformizar as duas —
> `spec_check` reprova quem tentar.

### Convenções de código

<<PREENCHER: convenções de código do projeto — casing por linguagem, ordem de imports,
formato de commit, padrão de branch, sufixos obrigatórios (Service, Repository, Hook, etc.)>>

## Layout de diretórios

<<PREENCHER: mapa "onde-vai-o-X" com caminhos reais. Exemplos do formato:
- Novo endpoint → `src/modules/<mod>/api/routes.py`
- Nova regra de negócio → `src/modules/<mod>/domain/services.py`
- Nova tela → `src/app/<rota>/page.tsx`
- Novo componente compartilhado → `src/components/ui/<Nome>.tsx`
- Novo hook de dados → `src/hooks/use<Recurso>.ts`
>>

## Comandos do projeto

<<PREENCHER: comandos reais. O agente vai usar exatamente estes.
- Instalar:
- Rodar (dev):
- Testes:
- Lint:
- Type-check:
- Build:
- Migrations:
>>

## Idioma de artefatos

| Artefato | Idioma |
|---|---|
| Specs, ADRs, comentários de decisão | Português |
| Código, nomes, mensagens de erro internas | Inglês |
| Mensagens visíveis ao usuário final | <<PREENCHER>> |
| Mensagens de commit | <<PREENCHER>> |
