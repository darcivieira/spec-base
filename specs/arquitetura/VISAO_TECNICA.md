# Visão técnica

Dono do fato: topologia, camadas e fluxo de execução. Decisões e seus porquês ficam em `adr/`.

## Stack

| Camada | Tecnologia | Versão | Observação |
|---|---|---|---|
| Backend | <<PREENCHER>> | | |
| Frontend | <<PREENCHER>> | | |
| Banco | <<PREENCHER>> | | |
| Fila / async | <<PREENCHER>> | | |
| Infra / deploy | <<PREENCHER>> | | |

## Topologia
<<PREENCHER: quais processos existem, como se comunicam, o que é síncrono e o que é assíncrono.>>

## Camadas e regras de dependência
<<PREENCHER: quem pode importar quem. Esta é a regra mais violada por agentes —
seja explícito e cite caminhos.>>

## Fronteira backend ↔ frontend
<<PREENCHER: como o contrato é definido e mantido em sincronia (OpenAPI gerado, tipos
compartilhados, codegen). Se for manual, diga que é manual e onde mora a fonte.>>

## Fluxos críticos
<<PREENCHER: 2 a 4 fluxos ponta a ponta (ex.: autenticação, operação principal, job noturno)
descritos passo a passo com os módulos envolvidos.>>

## Ambientes
<<PREENCHER: local, homologação, produção — o que difere entre eles.>>

## Riscos técnicos conhecidos
<<PREENCHER: dívidas assumidas conscientemente, com link para o ADR que as aceitou.>>
