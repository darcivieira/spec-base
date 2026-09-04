# Proteção de dados

Dono do fato: a postura de privacidade do projeto e as obrigações que ela impõe ao código.

> Privacidade é **requisito de produto**, não cuidado operacional. A diferença é prática: requisito
> tem critério de aceite e teste; cuidado operacional tem boa intenção e nada mais.

**Se este projeto não processa dado pessoal, apague este arquivo** e remova a linha dele do
[00-indice](00-indice.md). Seção vazia é ruído que compete por contexto com o que importa.

## Que dado pessoal existe aqui

<<PREENCHER: liste as categorias que o sistema processa, e para cada uma diga por que ela é
necessária. Categoria sem uso declarado é categoria a não coletar.

| Dado | Onde vive | Para que o sistema usa | Base legal / justificativa |
|---|---|---|---|
| | | | |
>>

## As exigências

Ajuste à legislação aplicável (LGPD, GDPR, ou o regime do seu mercado). As sete linhas abaixo são
o mínimo que praticamente todo regime exige.

| Exigência | Como se materializa neste projeto | Estado |
|---|---|---|
| **Base legal** | <<PREENCHER>> | - [ ] |
| **Minimização** | Não coletar dado que o sistema não usa. Campo "por precaução" é violação | - [ ] |
| **Direito de exclusão** | <<PREENCHER: o que é apagado, em que unidade, e em que prazo>> | - [ ] |
| **Portabilidade** | <<PREENCHER: formato aberto de exportação>> | - [ ] |
| **Retenção** | <<PREENCHER: prazo por tipo de dado, incluindo logs e derivados>> | - [ ] |
| **Segurança** | <<PREENCHER: isolamento, criptografia em trânsito e repouso>>. **Sem dado pessoal em log, URL ou query string** | - [ ] |
| **Registro de tratamento** | <<PREENCHER: como acesso e alteração de dado pessoal são auditados>> | - [ ] |

## A tensão entre imutabilidade e exclusão

Quase todo sistema com trilha de auditoria, event sourcing ou registro append-only encontra este
conflito: uma regra diz "nada é apagado", a lei diz "o titular pode exigir a exclusão".

**Não são incompatíveis:** imutabilidade vale **durante o ciclo de vida do dado**; a exclusão
encerra esse ciclo. O registro é imutável, não eterno.

O que precisa estar decidido e escrito:

| Questão | Decisão |
|---|---|
| Apaga de fato ou anonimiza? | <<PREENCHER>> |
| Qual é a unidade de exclusão? | <<PREENCHER: conta, espaço, organização>> |
| O que é derivado e morre junto? | <<PREENCHER>> |
| Prazo para confirmar e para purgar | <<PREENCHER>> |
| **Como isso é garantido?** | <<PREENCHER: o teste que cria o registro em todas as tabelas, apaga, e afirma zero linha remanescente>> |

> ⚠️ **O modo de falha a evitar:** reforçar a imutabilidade no banco — revogar `DELETE`, criar
> constraint que impeça a remoção — torna a exclusão **impossível de cumprir**. A imutabilidade é
> regra da aplicação; o caminho de exclusão é a exceção nomeada, testada, e a única autorizada a
> apagar. Se este projeto tiver essa restrição, ela entra em [03-limites-agente](03-limites-agente.md)
> como item que o agente nunca cria.

## O que isso obriga em toda mudança

Estes itens estão em [04-definition-of-done](04-definition-of-done.md) e são verificados lá:

- Campo novo de dado pessoal tem justificativa de uso registrada — minimização é requisito
- Nenhum dado pessoal em log, mensagem de erro, URL ou query string
- Tabela ou coleção nova está coberta pelo caminho de exclusão e pelo seu teste
- Dado real de pessoa não entra em fixture, seed, nem em ambiente de desenvolvimento
