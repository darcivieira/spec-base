#!/usr/bin/env python3
"""Cobra a convenção de `specs/` declarada em `.spec-base.json`. Sem dependências externas.

Documentar uma convenção não a faz valer. Este script é o que a cobra — e por ser um
comando, e não um teste em pytest ou vitest, ele roda igual em projeto Python, Node ou Go.

Uso:
    python3 scripts/spec_check.py              # relatório
    python3 scripts/spec_check.py --ci         # exit 1 na primeira violação
    python3 scripts/spec_check.py --relacionar # tabela mudança ↔ rastreadores
    python3 scripts/spec_check.py --explicar   # o que cada chave de .spec-base.json faz
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SPECS = RAIZ / "specs"
CONFIG = RAIZ / ".spec-base.json"

SLUG = r"[a-z0-9]+(?:-[a-z0-9]+)*"

# Arquivos que instruem como nomear uma mudança. Quando o esquema não é sequencial,
# nenhum deles pode continuar mandando numerar — e `NNN` é a marca de que alguém voltou
# a mandar, provavelmente ao copiar de uma versão anterior da base.
INSTRUEM_NOME_DE_MUDANCA = [
    ".claude/skills/spec-nova/SKILL.md",
    ".claude/skills/spec-plano/SKILL.md",
    ".claude/skills/spec-fechar/SKILL.md",
    "specs/_templates/MUDANCA-spec.md",
    "specs/_templates/MUDANCA-plan.md",
    "specs/_templates/MUDANCA-tasks.md",
]

# O contrário, e igualmente deliberado: ADR **não** segue a regra das mudanças. Um ADR
# nasce de uma decisão, e uma decisão atravessa cards. Alguém vai querer uniformizar.
INSTRUEM_NOME_DE_ADR = [
    ".claude/skills/spec-adr/SKILL.md",
    "specs/_templates/ADR.md",
]

PADRAO_ADR = re.compile(r"^(\d{4})-" + SLUG + r"\.md$")


# --------------------------------------------------------------------------- config


def carregar_config() -> dict:
    if not CONFIG.exists():
        sys.exit(
            f"erro: {CONFIG.name} não encontrado na raiz do projeto.\n"
            "Copie-o da base de specs, ou rode a skill spec-bootstrap."
        )
    try:
        return json.loads(CONFIG.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        sys.exit(f"erro: {CONFIG.name} não é JSON válido — linha {e.lineno}: {e.msg}")


def padrao_de_mudanca(cfg: dict) -> re.Pattern[str]:
    """Monta a regex do nome de diretório a partir do esquema configurado."""
    ident = cfg.get("identificador", {})
    esquema = ident.get("esquema", "sequencial")

    if esquema == "sequencial":
        return re.compile(rf"^\d{{3}}-{SLUG}$")

    primario = ident.get("primario")
    rastreadores = ident.get("rastreadores", {})
    if not primario or primario not in rastreadores:
        sys.exit(
            "erro: esquema '"
            + esquema
            + "' exige `identificador.primario` apontando para um rastreador declarado."
        )

    chave = rastreadores[primario].get("padrao")
    if not chave:
        sys.exit(f"erro: o rastreador '{primario}' não declara `padrao`.")

    fatia = r"(?:-\d+)?" if ident.get("fatiamento") else ""
    return re.compile(rf"^(?:{chave}){fatia}-{SLUG}$")


def campos_obrigatorios(cfg: dict) -> list[str]:
    """Campos de frontmatter que toda spec de mudança precisa declarar."""
    ident = cfg.get("identificador", {})
    if ident.get("esquema", "sequencial") == "sequencial":
        return []
    rastreadores = ident.get("rastreadores", {})
    nomes = [ident.get("primario"), *ident.get("espelho_obrigatorio", [])]
    return [rastreadores[n]["campo"] for n in nomes if n in rastreadores]


# ----------------------------------------------------------------------- utilitários


def diretorios_de_mudanca() -> list[Path]:
    dir_mudancas = SPECS / "mudancas"
    if not dir_mudancas.exists():
        return []
    return sorted(p for p in dir_mudancas.iterdir() if p.is_dir())


def frontmatter(arquivo: Path) -> dict[str, str]:
    """Parser deliberadamente burro: só pares `chave: valor` no topo, entre `---`."""
    if not arquivo.exists():
        return {}
    linhas = arquivo.read_text(encoding="utf-8", errors="replace").splitlines()
    if not linhas or linhas[0].strip() != "---":
        return {}
    campos: dict[str, str] = {}
    for linha in linhas[1:]:
        if linha.strip() == "---":
            break
        if ":" in linha and not linha.startswith((" ", "\t", "#")):
            chave, _, valor = linha.partition(":")
            campos[chave.strip()] = valor.split("#")[0].strip()
    return campos


def texto(caminho: str) -> str | None:
    p = RAIZ / caminho
    return p.read_text(encoding="utf-8", errors="replace") if p.exists() else None


# ------------------------------------------------------------------------ checagens


class Relatorio:
    def __init__(self) -> None:
        self.erros: list[str] = []
        self.avisos: list[str] = []

    def erro(self, msg: str) -> None:
        self.erros.append(msg)

    def aviso(self, msg: str) -> None:
        self.avisos.append(msg)


def checar_nomes(cfg: dict, r: Relatorio) -> None:
    padrao = padrao_de_mudanca(cfg)
    esquema = cfg["identificador"].get("esquema", "sequencial")
    fora = [p.name for p in diretorios_de_mudanca() if not padrao.match(p.name)]
    if fora:
        exemplo = (
            "NNN-<slug>"
            if esquema == "sequencial"
            else "<chave do rastreador>-<slug>, com número de fatia quando o card foi fatiado"
        )
        r.erro(
            "diretório de mudança fora do formato: "
            + ", ".join(fora)
            + f"\n    esperado: {exemplo}"
            + f"\n    regex vigente: {padrao.pattern}"
        )


def checar_frontmatter(cfg: dict, r: Relatorio) -> None:
    obrigatorios = campos_obrigatorios(cfg)
    if not obrigatorios:
        return
    for d in diretorios_de_mudanca():
        spec = d / "spec.md"
        if not spec.exists():
            r.aviso(f"{d.name}/ não tem spec.md")
            continue
        campos = frontmatter(spec)
        faltando = [c for c in obrigatorios if not campos.get(c) or campos[c] in {"—", "-"}]
        if faltando:
            r.erro(
                f"{d.name}/spec.md não declara: {', '.join(faltando)}"
                "\n    sem o campo, o nome do diretório vira a única pista de origem"
            )


def checar_instrucoes(cfg: dict, r: Relatorio) -> None:
    esquema = cfg["identificador"].get("esquema", "sequencial")

    if esquema != "sequencial":
        for caminho in INSTRUEM_NOME_DE_MUDANCA:
            t = texto(caminho)
            if t is not None and "NNN" in t:
                r.erro(
                    f"{caminho} voltou a instruir numeração sequencial de mudança, "
                    f"mas o esquema vigente é '{esquema}'"
                )

    # Vale nos dois esquemas: ADR é sempre sequencial.
    for caminho in INSTRUEM_NOME_DE_ADR:
        t = texto(caminho)
        if t is not None and "NNNN" not in t:
            r.erro(
                f"{caminho} perdeu a numeração sequencial de ADR — "
                "ela não segue a regra das mudanças, porque decisão atravessa card"
            )


def checar_adrs(r: Relatorio) -> None:
    dir_adr = SPECS / "arquitetura" / "adr"
    if not dir_adr.exists():
        return
    vistos: dict[str, str] = {}
    for p in sorted(dir_adr.glob("*.md")):
        if p.name == "README.md":
            continue
        m = PADRAO_ADR.match(p.name)
        if not m:
            r.erro(f"ADR fora do formato NNNN-slug.md: {p.name}")
            continue
        numero = m.group(1)
        if numero in vistos:
            r.erro(f"número de ADR duplicado: {numero} em {vistos[numero]} e {p.name}")
        vistos[numero] = p.name


def checar_active(cfg: dict, r: Relatorio) -> None:
    ativo = SPECS / "ACTIVE.md"
    if not ativo.exists():
        r.erro("specs/ACTIVE.md não existe. Rode a skill spec-bootstrap.")
        return

    linhas = ativo.read_text(encoding="utf-8").strip().splitlines()
    id_ativo = linhas[0].strip() if linhas else ""

    if not id_ativo or id_ativo == "nenhuma" or id_ativo.startswith("GREEN:"):
        return

    d = SPECS / "mudancas" / id_ativo
    if not d.is_dir():
        r.erro(f"ACTIVE.md aponta para '{id_ativo}', que não existe em specs/mudancas/")
        return
    if not (d / "plan.md").exists():
        r.erro(f"a mudança ativa '{id_ativo}' não tem plan.md. Rode a skill spec-plano.")


RE_FOLLOWUP = re.compile(r"^###\s+(F-\d+)\s*(?:—|-)?\s*(.*)$", re.M)
RE_CAMPO = re.compile(r"^\s*[-*]\s*\*\*(Destino|Estado):\*\*\s*(.*)$", re.M)

# Um campo ainda no formato do template não é um campo preenchido.
VAZIOS = {"", "—", "-", "n/a"}


def _preenchido(valor: str) -> bool:
    v = valor.strip().lower()
    return bool(v) and v not in VAZIOS and not v.startswith("<")


def checar_followups(r: Relatorio) -> None:
    """Achado sem destino é uma nota que morre — que é o que o arquivo existe para impedir."""
    for d in diretorios_de_mudanca():
        arquivo = d / "followups.md"
        if not arquivo.exists():
            continue

        texto = arquivo.read_text(encoding="utf-8", errors="replace")
        blocos = list(RE_FOLLOWUP.finditer(texto))
        if not blocos:
            continue

        concluida = frontmatter(d / "spec.md").get("status") == "concluida"

        for i, m in enumerate(blocos):
            fim = blocos[i + 1].start() if i + 1 < len(blocos) else len(texto)
            corpo = texto[m.start():fim]
            campos = {c.group(1): c.group(2) for c in RE_CAMPO.finditer(corpo)}

            if not _preenchido(campos.get("Destino", "")):
                r.erro(
                    f"{d.name}/followups.md · {m.group(1)} sem destino"
                    "\n    achado sem destino é uma nota que morre — decida agora, "
                    "não 'depois'"
                )
            elif concluida and campos.get("Estado", "").strip().lower().startswith("pendente"):
                r.erro(
                    f"{d.name}/followups.md · {m.group(1)} ainda pendente numa mudança concluída"
                    "\n    ou virou registro em algum lugar, ou foi descartado com motivo escrito"
                )


def checar_dod(cfg: dict, r: Relatorio) -> None:
    if not cfg.get("guardas", {}).get("dod_por_mudanca"):
        return
    for d in diretorios_de_mudanca():
        campos = frontmatter(d / "spec.md")
        if campos.get("status") == "concluida" and not (d / "dod.md").exists():
            r.erro(
                f"{d.name}/ está concluída e não tem dod.md"
                "\n    `dod_por_mudanca` está ligado: fechar sem a verificação item a item"
                "\n    devolve o problema que ela existe para impedir"
            )


# -------------------------------------------------------------------------- saídas


def relacionar(cfg: dict) -> None:
    """A tabela que um projeto com controle em dois sistemas não tem em lugar nenhum."""
    ident = cfg.get("identificador", {})
    rastreadores = ident.get("rastreadores", {})
    if not rastreadores:
        print("Esquema sequencial: não há rastreador para relacionar.")
        return

    nomes = list(rastreadores)
    campos = [rastreadores[n]["campo"] for n in nomes]
    larguras = [max(len(n), 12) for n in nomes]

    cabecalho = f"{'mudança':<42}  {'status':<16}  " + "  ".join(
        f"{n:<{w}}" for n, w in zip(nomes, larguras)
    )
    print(cabecalho)
    print("-" * len(cabecalho))

    for d in diretorios_de_mudanca():
        fm = frontmatter(d / "spec.md")
        valores = "  ".join(f"{fm.get(c, '—'):<{w}}" for c, w in zip(campos, larguras))
        print(f"{d.name:<42}  {fm.get('status', '—'):<16}  {valores}")

    for nome in ident.get("espelho_obrigatorio", []):
        campo = rastreadores.get(nome, {}).get("campo")
        if not campo:
            continue
        sem = [d.name for d in diretorios_de_mudanca() if not frontmatter(d / "spec.md").get(campo)]
        if sem:
            print(f"\n⚠ sem espelho em '{nome}': {', '.join(sem)}")


def explicar() -> None:
    print(EXPLICACAO.strip())


EXPLICACAO = """
.spec-base.json — configuração da base de specs

identificador.esquema
    "sequencial"  NNN-slug. Um contador local. Serve para trabalho solo.
    "rastreador"  o id vem de um sistema de cards. Duas pessoas não escolhem o mesmo,
                  porque nenhuma das duas escolhe.
    "multiplo"    igual a "rastreador", e ainda exige que a mudança declare o id dos
                  outros sistemas em que ela é acompanhada.

identificador.primario
    Qual rastreador dá o nome do diretório. Um só — o nome precisa de um dono, ou volta
    a colidir. Os demais viram espelho no frontmatter.

identificador.fatiamento
    Permite <chave>-<fatia>-<slug>, para card partido em mudanças com risco diferente.

identificador.rastreadores
    { "<nome>": { "padrao": <regex da chave>, "campo": <campo do frontmatter>,
                  "url": <link, com {id}> } }

identificador.espelho_obrigatorio
    Lista de rastreadores cujo campo toda spec precisa preencher. Vazio = nenhum.

guardas.require_spec       hook que bloqueia código sem mudança aprovada
guardas.guard_branch       hook que bloqueia commit/push/merge em branch protegida
guardas.dod_por_mudanca    exige dod.md preenchido antes de fechar a mudança

integracoes.voz
    De onde o agente tira o estilo do texto que sai com o seu nome.
    "conversa"  da sessão em curso — como esta pessoa escreve  (default)
    "amostras"  dos trechos fixados em specs/governanca/10-voz.md
    "neutro"    de lugar nenhum; escreve direto, sem imitar

integracoes.publicacao_externa
    Quem publica o texto que sai do repositório — comentário de card, issue, documento.
    "rascunho"   o agente redige e mostra; quem publica é o humano  (default)
    "confirmar"  o agente publica após você aprovar o texto exato
    "automatica" o agente publica direto
    O texto sai com o nome de uma pessoa: ver specs/governanca/10-voz.md.

branches.principal / integracao / protegidas / tarefa
    Fluxo de branch. `integracao` pode ser null em fluxo de duas pontas.

caminhos.protegidos              regex de código que o require-spec cobre
caminhos.livres                  regex sempre liberada (testes, specs, docs)
caminhos.imutaveis_apos_publicacao
    Regex de arquivos que, uma vez presentes em `caminhos.ref_principal`, não podem mais
    ser editados — migrations são o caso típico. Criar é livre; editar o que já rodou não.
caminhos.ref_principal           de onde saem os deploys. Default: origin/main
"""


def main() -> int:
    args = set(sys.argv[1:])

    if "--explicar" in args:
        explicar()
        return 0

    cfg = carregar_config()

    if "--relacionar" in args:
        relacionar(cfg)
        return 0

    r = Relatorio()
    checar_nomes(cfg, r)
    checar_frontmatter(cfg, r)
    checar_instrucoes(cfg, r)
    checar_adrs(r)
    checar_active(cfg, r)
    checar_dod(cfg, r)
    checar_followups(r)

    esquema = cfg["identificador"].get("esquema", "sequencial")
    guardas = cfg.get("guardas", {})
    ligadas = [n for n, v in guardas.items() if v] or ["nenhuma"]
    print(f"esquema de identificador: {esquema}")
    print(f"guardas ligadas: {', '.join(ligadas)}")
    print(f"mudanças: {len(diretorios_de_mudanca())}")

    for msg in r.avisos:
        print(f"\n⚠ {msg}")
    for msg in r.erros:
        print(f"\n✗ {msg}")

    if not r.erros:
        print("\n✓ convenção de specs íntegra.")
        return 0

    print(f"\n{len(r.erros)} violação(ões).")
    return 1 if "--ci" in args else 0


if __name__ == "__main__":
    raise SystemExit(main())
