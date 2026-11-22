# Gera as builds do Pitagorome (Windows + Web) com nome e versão padronizados.
#
# Uso (na pasta Pitagorome):
#   python tools/exportar.py teste      -> builds/v0.3.0-teste/
#   python tools/exportar.py final      -> builds/v1.0.0/
#   opções: --godot=CAMINHO_DO_GODOT   --sobrescrever
#
# O número da versão vem de project.godot (application/config/version).
# Regras de versão e o que é TESTE x FINAL: VERSOES.md (na raiz do repositório).
#
# Saída:
#   builds/<versao>/windows/Pitagorome.exe
#   builds/<versao>/web/index.html (+ .js .wasm .pck ...)
#   builds/<versao>/Pitagorome_<versao>_windows.zip
#   builds/<versao>/Pitagorome_<versao>_web.zip
import os
import re
import shutil
import subprocess
import sys
import zipfile

RAIZ = os.path.normpath(os.path.join(os.path.dirname(__file__), ".."))
GODOT_PADRAO = r"D:\Engines\Godot_v4.6.2-stable_win64.exe"

PRESETS = {
    "teste": {"windows": "Windows - TESTE", "web": "Web - TESTE"},
    "final": {"windows": "Windows - FINAL", "web": "Web - FINAL"},
}


def erro(msg: str) -> None:
    print("ERRO:", msg)
    sys.exit(1)


def versao_do_projeto() -> str:
    with open(os.path.join(RAIZ, "project.godot"), encoding="utf-8") as f:
        m = re.search(r'^config/version="([^"]+)"', f.read(), re.M)
    if not m:
        erro('project.godot sem config/version (Projeto > Configurações > Aplicação > Config > Versão).')
    v = m.group(1)
    if not re.fullmatch(r"\d+\.\d+\.\d+", v):
        erro(f'versão "{v}" fora do padrão MAIOR.MENOR.CORRECAO (ex.: 0.3.0). Ver VERSOES.md.')
    return v


def git(*args: str) -> str:
    return subprocess.run(["git", *args], cwd=RAIZ, capture_output=True, text=True).stdout.strip()


def zipar(pasta: str, destino: str) -> None:
    with zipfile.ZipFile(destino, "w", zipfile.ZIP_DEFLATED) as z:
        for base, _, arquivos in os.walk(pasta):
            for a in arquivos:
                cheio = os.path.join(base, a)
                z.write(cheio, os.path.relpath(cheio, pasta))


def exportar(godot: str, preset: str, saida: str) -> None:
    os.makedirs(os.path.dirname(saida), exist_ok=True)
    print(f"  exportando '{preset}' -> {os.path.relpath(saida, RAIZ)}")
    r = subprocess.run([godot, "--headless", "--path", RAIZ, "--export-release", preset, saida],
                       capture_output=True, text=True)
    if not os.path.exists(saida):
        print(r.stdout[-3000:], r.stderr[-3000:])
        erro(f"o Godot não gerou {saida} (faltam os templates de exportação 4.6.2?)")


def main() -> None:
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    opcoes = {a.split("=")[0]: (a.split("=", 1)[1] if "=" in a else True) for a in sys.argv[1:] if a.startswith("--")}
    if len(args) != 1 or args[0] not in PRESETS:
        erro("uso: python tools/exportar.py teste|final [--godot=...] [--sobrescrever]")
    canal = args[0]
    godot = opcoes.get("--godot", GODOT_PADRAO)
    numero = versao_do_projeto()
    versao = f"v{numero}-teste" if canal == "teste" else f"v{numero}"

    if canal == "final":
        # Build final só sai de um estado salvo no git, para dar para refazer igual depois.
        sujos = [l for l in git("status", "--porcelain", "--untracked-files=no").splitlines()]
        if sujos:
            erro("a build FINAL precisa do projeto todo commitado. Alterados:\n  " + "\n  ".join(sujos))
        if int(numero.split(".")[0]) < 1:
            print(f"AVISO: versão final {versao} com MAIOR = 0. A entrega oficial deveria ser v1.0.0 (ver VERSOES.md).")

    if versao in git("tag", "--list", versao).split():
        print(f"AVISO: a tag {versao} já existe no git (essa versão já foi publicada).")
        if not opcoes.get("--sobrescrever"):
            erro("aumente o número em project.godot (ver VERSOES.md) ou use --sobrescrever.")

    destino = os.path.join(RAIZ, "builds", versao)
    if os.path.exists(destino):
        if not opcoes.get("--sobrescrever"):
            erro(f"builds/{versao} já existe. Use --sobrescrever para gerar de novo.")
        # ignore_errors: no Windows uma pasta aberta no Explorer/terminal não pode ser
        # apagada; os arquivos dentro somem e a exportação grava por cima.
        shutil.rmtree(destino, ignore_errors=True)

    print(f"Gerando {versao} ({canal.upper()}) no commit {git('rev-parse', '--short', 'HEAD')}")
    exportar(godot, PRESETS[canal]["windows"], os.path.join(destino, "windows", "Pitagorome.exe"))
    exportar(godot, PRESETS[canal]["web"], os.path.join(destino, "web", "index.html"))

    zip_win = os.path.join(destino, f"Pitagorome_{versao}_windows.zip")
    zip_web = os.path.join(destino, f"Pitagorome_{versao}_web.zip")
    zipar(os.path.join(destino, "windows"), zip_win)
    zipar(os.path.join(destino, "web"), zip_web)
    for z in (zip_win, zip_web):
        print(f"  {os.path.relpath(z, RAIZ)}  ({os.path.getsize(z) / 1e6:.1f} MB)")
    print("Pronto. Próximos passos (tag, Release, site): VERSOES.md")


if __name__ == "__main__":
    main()
