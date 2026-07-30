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
- Mudança: `mudancas/NNN-slug/`, `NNN` com 3 dígitos.

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
