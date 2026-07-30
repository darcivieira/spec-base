# Anatomia — skeletons copiáveis

Estruturas canônicas deste projeto. Copie e adapte; não invente layout novo.
Se um skeleton não serve para o caso, isso é um sinal de mudança **YELLOW** — especifique antes.

## Módulo de backend

<<PREENCHER: árvore de diretórios de um módulo real deste projeto, com o papel de cada arquivo.
Formato esperado:

src/modules/<mod>/
├── api/           # rotas, serialização, códigos HTTP — sem regra de negócio
├── domain/        # entidades, regras, serviços — sem framework, sem I/O
├── infra/         # repositórios, clientes externos, ORM
└── tests/

Regras de dependência: api → domain ← infra. domain não importa nada das outras.
>>

## Endpoint

<<PREENCHER: exemplo mínimo de um endpoint real — assinatura, validação, autorização,
tratamento de erro, formato de resposta.>>

## Tela / rota de frontend

<<PREENCHER: árvore e exemplo de uma rota real. Formato esperado:

src/app/<rota>/
├── page.tsx        # composição; sem lógica de dados
├── loading.tsx
├── error.tsx
└── _components/    # componentes locais desta rota apenas

Regra: componente usado por 2+ rotas sobe para `src/components/`.
>>

## Componente

<<PREENCHER: exemplo de componente com props tipadas, variantes, e uso de tokens.
Deixe claro: componente de apresentação não busca dados.>>

## Hook / camada de dados do frontend

<<PREENCHER: padrão de acesso a dados — cliente HTTP, cache, invalidação,
tratamento de erro, tipos compartilhados com o backend.>>

## Teste

<<PREENCHER: um teste de unidade e um de integração reais, mostrando o padrão de
arrange/act/assert, uso de fixtures e nomeação.>>
