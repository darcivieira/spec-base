# Componentes

Inventário de componentes compartilhados. Dono do fato: **API pública de cada componente**.

Antes de criar componente novo: procure aqui. Criar duplicata é violação da constituição.
Componente usado por 2+ telas mora aqui; usado por 1 tela fica local à rota.

## Regras

- Componente de apresentação **não busca dados**. Recebe por props.
- Toda prop é tipada e documentada. Sem `any` / `object` solto.
- Todo componente interativo declara: estado de foco, estado desabilitado, estado de erro.
- Variantes são enumeradas, não booleanos empilhados (`variant="danger"`, não `isDanger`).
- Mudar assinatura de componente exportado é 🔴 **RED**.

## Inventário

### <<PREENCHER: NomeDoComponente>>
- **Papel:** <<PREENCHER>>
- **Arquivo:** <<PREENCHER: caminho real>>
- **Props:**

  | Prop | Tipo | Obrigatória | Padrão | Descrição |
  |---|---|---|---|---|
  | | | | | |

- **Variantes:** <<PREENCHER>>
- **Estados:** padrão · hover · foco · desabilitado · carregando · erro
- **Acessibilidade:** <<PREENCHER: papel ARIA, rótulo, navegação por teclado>>
- **Não faz:** <<PREENCHER: limites explícitos, para o agente não estender por conta>>
