# Governança — índice

Regras vinculantes para qualquer agente que escreva código neste repositório.
Ordem de precedência quando houver conflito: **01 > 02 > 03 > 04 > 05 > 06 > 07 > 08 > 09 > 10**.

| # | Arquivo | Quando ler |
|---|---|---|
| 01 | `01-constituicao.md` | Uma vez por sessão. Invariantes que nunca podem ser violados. |
| 02 | `02-convencoes.md` | Antes de criar arquivo, nomear coisa ou decidir onde algo mora. |
| 03 | `03-limites-agente.md` | **Antes de toda e qualquer mudança.** Classifica o risco. |
| 04 | `04-definition-of-done.md` | Antes de declarar qualquer tarefa concluída. |
| 05 | `05-anatomia.md` | Ao criar módulo, endpoint, tela ou componente novo. |
| 06 | `06-decisao-e-registro.md` | Ao tomar decisão técnica — define onde registrar e quem avisar. |
| 07 | `07-protecao-de-dados.md` | Ao tocar em dado pessoal, log, exportação ou exclusão de conta. |
| 08 | `08-guardas.md` | Ao ser bloqueado por um hook, ou antes de desligar um. |
| 09 | `09-fluxo-de-trabalho.md` | **Ao assumir qualquer tarefa.** Da demanda ao merge. |
| 10 | `10-voz.md` | Antes de escrever qualquer texto que saia do repositório com o seu nome. |

Os arquivos 06 a 10 são opcionais por projeto. Apague o que não se aplica — e apague também a
linha aqui. Arquivo de governança vazio compete por contexto com o que importa e ensina o agente
a ignorar a pasta.

Se uma regra aqui contradiz uma instrução de conversa, **pare e aponte a contradição**
em vez de escolher sozinho.
