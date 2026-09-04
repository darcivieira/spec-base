# Migrar o identificador de mudança

De `001-slug` para `PROJ-42-slug`, ou entre rastreadores. Uma renomeação de diretório mais o
frontmatter — mecânica, mas com uma armadilha que já mordeu.

**Faça numa branch.** O passo 4 mexe em texto de dezenas de arquivos.

## Antes de começar

Decida **o que fazer com as mudanças já concluídas**. Há duas saídas legítimas:

| Saída | Quando | Custo |
|---|---|---|
| **Renomear todas** | Poucas mudanças, ou você quer uma convenção só | O deste roteiro |
| **Conviver com os dois formatos** | Muitas mudanças fechadas, e o histórico não vale a mexida | Todo leitor futuro paga por saber duas convenções |

Não existe terceira. "Aplicar o novo só daqui pra frente" **é** a segunda, dita de outro jeito —
e ela precisa ficar escrita em `02-convencoes.md`, ou vira folclore.

Se escolher conviver, o `spec_check` vai reprovar os diretórios antigos. Ou você lista as exceções
em `identificador.rastreadores` como um padrão alternativo, ou aceita o vermelho — e aí a guarda
deixa de servir para qualquer coisa. Recomendação: **renomeie**, enquanto são poucas.

## 1. Criar os cards que faltam

No esquema `rastreador`, **cada mudança existente precisa de um card**. Trabalho já feito também:
o card é o que dá o nome.

Anote o mapa antes de renomear qualquer coisa:

```
001-esqueleto          -> PROJ-7
002-core-types         -> PROJ-8, fatia 1
003-core-infra         -> PROJ-8, fatia 2
```

Se duas mudanças antigas foram fatias do mesmo trabalho, este é o momento de reconhecê-lo: elas
viram `PROJ-8-1-...` e `PROJ-8-2-...`.

## 2. Configurar

```bash
python3 scripts/spec_check.py --explicar
```

Edite `.spec-base.json`. **Ainda não rode o `--ci`** — ele vai reprovar tudo, e isso é esperado.

## 3. Renomear os diretórios

```bash
git mv specs/mudancas/001-esqueleto  specs/mudancas/PROJ-7-esqueleto
git mv specs/mudancas/002-core-types specs/mudancas/PROJ-8-1-core-types
git mv specs/mudancas/003-core-infra specs/mudancas/PROJ-8-2-core-infra
```

`git mv` preserva o histórico. `mv` seguido de `git add` também, na prática, mas o `git mv` deixa
a intenção clara no diff.

## 4. Atualizar o conteúdo — o passo perigoso

Cada `spec.md` precisa de `id:` novo, `card:`, e o título. Cada `plan.md` e `tasks.md`, do título.

> ⚠️ **A armadilha.** Substituição em massa dos ids antigos **corrompe os trechos que citam o
> nome velho de propósito** — um critério de aceite que diz *"quando eu procuro por
> `001-esqueleto`"*, uma tarefa que descreve o teste falhando nos três nomes antigos, um ADR que
> registra o que se sabia na época.
>
> Um `grep` no fim ficaria **limpo**, e o sentido, errado.

Por isso: substitua, e depois **leia o `git diff` inteiro**. Não confie no grep.

```bash
# 4a. os campos estruturais, um diretório por vez
python3 - <<'PY'
from pathlib import Path
MAPA = {
    "001-esqueleto":  ("PROJ-7-esqueleto",       "PROJ-7", ""),
    "002-core-types": ("PROJ-8-1-core-types",    "PROJ-8", "PROJ-31"),
    "003-core-infra": ("PROJ-8-2-core-infra",    "PROJ-8", "PROJ-32"),
}
for velho, (novo, card, sub) in MAPA.items():
    spec = Path("specs/mudancas") / novo / "spec.md"
    t = spec.read_text(encoding="utf-8")
    t = t.replace(f"id: {velho}", f"id: {novo}")
    if "card:" not in t:
        t = t.replace(f"id: {novo}", f"id: {novo}\ncard: {card}" + (f"\nsubtarefa: {sub}" if sub else ""))
    spec.write_text(t, encoding="utf-8")
    print("ok", novo)
PY

# 4b. AGORA leia o diff inteiro, arquivo por arquivo
git diff
```

Restaure à mão qualquer trecho que citava o nome antigo **de propósito**.

## 5. O que NÃO se corrige

| Item | Por quê |
|---|---|
| **ADR já aceito** que cite um id antigo | ADR aceito é imutável. Editá-lo destrói o registro do que se sabia na época, que é a única razão de ele existir |
| **Mensagem de commit** já publicada | Reescrever histórico publicado é ⛔ SEM EXCEÇÃO |
| **Nome de branch** já publicado | Idem |
| **Comentário em card ou PR** | Fora do repositório |

Isso significa que `grep -r 001-esqueleto` vai continuar achando ocorrências legítimas depois da
migração. **Não é resíduo — é registro.**

## 6. Verificar

```bash
python3 scripts/spec_check.py --ci        # agora tem de sair 0
python3 scripts/spec_check.py --relacionar
```

Depois **crie um diretório errado de propósito** e confirme que a guarda reprova:

```bash
mkdir -p specs/mudancas/004-teste-da-guarda
python3 scripts/spec_check.py --ci ; echo "exit=$?"   # esperado: 1, nomeando o diretório
rm -rf specs/mudancas/004-teste-da-guarda
```

Guarda que nunca foi vista vermelha não foi demonstrada — ela pode estar passando por engano.

## 7. Fechar

Atualize `02-convencoes.md` com o formato vigente, e **escreva o ADR**: contexto (o que doía),
decisão, trade-off (o acoplamento ao rastreador, a perda da ordem cronológica no `ls`).

Sem o ADR, daqui a um ano alguém propõe voltar para numeração sequencial sem saber o que a
motivou a sair.
