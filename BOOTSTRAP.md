# Prompt de inicialização

Instale a base na raiz do repositório:

```bash
curl -fsSL https://raw.githubusercontent.com/darcivieira/spec-base/master/install.sh | sh
```

Depois abra o Claude Code e cole **exatamente** isto:

---

```
Quero inicializar a base de especificações deste projeto.

Rode a skill `spec-bootstrap`. Antes de escrever qualquer arquivo:

1. Descubra se este é um projeto novo ou já existente.
2. Se for existente, varra o código com um subagente de exploração (read-only) e me
   apresente em tabela o que você detectou: stack e versões, layout de diretórios,
   módulos, rotas de API, rotas de frontend, entidades, componentes compartilhados,
   comandos reais (instalar/rodar/testar/lint/build/migration) e docs existentes.
   Espere eu confirmar ou corrigir antes de escrever.
3. Depois conduza a entrevista bloco a bloco — um bloco por vez, esperando minha
   resposta, e gravando os arquivos de cada bloco antes de passar ao próximo.

Regras que valem para tudo:
- Não invente nada. O que você não souber vira marcador de pendência, e você me diz
  o que ficou pendente.
- Se não houver frontend, remova specs/ui/ e as linhas de UI do Definition of Done.
  Se não houver backend, remova specs/dados/ e as linhas de backend.
- No bloco de rigor, me explique o trade-off entre modo estrito (hook bloqueia edição
  sem spec aprovada) e consultivo (skills orientam, nada bloqueia) antes de eu escolher.
- Ao final, insira o bloco de .claude/CLAUDE.md.bloco no CLAUDE.md entre os marcadores
  SPEC-BASE:INICIO e SPEC-BASE:FIM, com os caminhos reais deste projeto, sem
  sobrescrever o resto do arquivo.
- Termine rodando `python3 scripts/spec_status.py` e me mostrando o que falta,
  ordenado por impacto, com os 3 próximos passos.

Comece pelo reconhecimento.
```

---

## Variante — projeto novo, sem código ainda

Troque o passo 2 por:

```
2. Este projeto ainda não tem código. Pule a varredura e vá direto para a entrevista.
   No bloco de convenções, me proponha um layout de diretórios coerente com a stack
   que eu escolher e me peça para aprovar antes de gravar.
```

## Variante — adoção parcial (repositório grande)

Acrescente ao final:

```
Este repositório é grande. Na Fase 2, documente apenas os módulos <A>, <B> e <C>.
Os demais ficam como stub com pendência declarada. Prefiro cobertura parcial honesta
a cobertura total inventada.
```

## Depois do bootstrap

| Momento | O que fazer |
|---|---|
| Feature nova ou alteração de comportamento | "rode `spec-nova`" (ou descreva o pedido — a skill deve disparar sozinha) |
| Spec aprovada | "rode `spec-plano`" |
| Implementação concluída | "rode `spec-fechar`" |
| Decisão técnica relevante | "rode `spec-adr`" |
| Checar saúde | `python3 scripts/spec_status.py` |
