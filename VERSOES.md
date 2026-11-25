# Versões do Pitagorome

## Links

| O quê | Onde |
|---|---|
| Jogar no navegador (última versão de **teste**) | https://pitagorome.github.io/Pitagorome/teste/ |
| Jogar no navegador (versão **final**) | https://pitagorome.github.io/Pitagorome/jogo/ (só a partir da v1.0.0) |
| Página com todas as versões | https://pitagorome.github.io/Pitagorome/ |
| Download para Windows (.zip com o executável) | botão **Baixar para Windows** em https://pitagorome.github.io/Pitagorome/ (arquivo em `/downloads/` do site) |
| Releases no GitHub (opcional) | https://github.com/Pitagorome/Pitagorome/releases |

## TESTE x FINAL

O que diferencia as duas **não é o nome do arquivo**, é o **preset de exportação** usado:

| | Build de TESTE | Build FINAL |
|---|---|---|
| Presets (Projeto → Exportar) | `Windows - TESTE`, `Web - TESTE` | `Windows - FINAL`, `Web - FINAL` |
| Feature tag `teste` | sim | não |
| Botões "Pular p/ Fase 2/3 (TESTE)" | aparecem | **não existem** |
| Marca "VERSÃO DE TESTE vX" no canto | aparece | não |
| Nome | `v0.3.0-teste` | `v1.0.0` |
| Tag no git | `v0.3.0-teste` | `v1.0.0` |
| Release no GitHub | marcada como **Pre-release** | Release normal (*Latest*) |
| No site | `/teste/` | `/jogo/` |
| Pode gerar com alterações não commitadas? | pode | **não** (o script recusa) |

Quem decide isso dentro do jogo é `scripts/versao.gd` (autoload `Versao`):
`Versao.eh_teste()` é verdadeiro na build de teste **e** quando roda pelo editor do Godot
(para os botões de pular continuarem servindo durante o desenvolvimento).

## Número da versão: `MAIOR.MENOR.CORRECAO`

Fica em **Projeto → Configurações do Projeto → Aplicação → Config → Versão**
(`config/version` no `project.godot`).

- **MAIOR**: `0` enquanto o jogo está em desenvolvimento/teste. Vira **`1`** na entrega oficial (`v1.0.0`).
- **MENOR**: quantas fases do roteiro estão prontas. `0.1` = Fase 1, `0.2` = Fase 2, `0.3` = Fase 3 + historinha + encerramento.
- **CORRECAO**: sobe a cada nova build publicada com correções/ajustes, sem fase nova (`0.3.0` → `0.3.1` → `0.3.2`…). Volta a 0 quando MENOR ou MAIOR sobe.

Regra de ouro: **um número publicado nunca é reaproveitado.** Se já existe a tag `v0.3.0-teste`
e vocês mudaram algo, a próxima build é `v0.3.1-teste`. O script avisa e recusa se a tag já existir.

## Como gerar e publicar uma versão

1. Atualizar o número em `project.godot` (se mudou algo desde a última publicada) e anotar no **Histórico** abaixo.
2. Rodar os testes (o T2.14 pega símbolo que vira quadradinho na web; `python tools/checar_glifos.py` confere também os diálogos): `Godot --headless --path . res://tests/test_runner.tscn` (tem que dar *TODOS PASSARAM*).
3. Commitar (`versão: v0.3.1-teste ...`).
4. Gerar as builds (precisa dos templates de exportação do Godot 4.6.2 instalados):
   ```
   python tools/exportar.py teste      # ou: final
   ```
   Saem em `builds/<versão>/` (pasta ignorada pelo git):
   `Pitagorome_<versão>_windows.zip` e `Pitagorome_<versão>_web.zip`.
5. Criar a tag e mandar: `git tag -a v0.3.1-teste -m "..." && git push origin v0.3.1-teste`.
6. **Download Windows:** copiar o `builds/<versão>/Pitagorome_<versão>_windows.zip` para a pasta
   `downloads/` do branch `gh-pages` (deixar só o da versão atual, para o repositório não crescer à toa)
   e apontar o botão **Baixar para Windows** do `index.html` para ele. Assim o botão baixa o executável,
   e não o código do projeto (a página da tag no GitHub só oferece o código-fonte).
   Opcional: GitHub → Releases → *Draft a new release* → tag → anexar o mesmo .zip → **Set as a pre-release**.
7. **Navegador:** copiar o conteúdo de `builds/<versão>/web/` para a pasta `teste/` (ou `jogo/` na final)
   do branch `gh-pages`, atualizar a tabela do `index.html` desse branch e dar push.
   O GitHub Pages publica sozinho em ~1 minuto.

### Testar a versão web no próprio PC

Abrir o `index.html` com dois cliques **não funciona** (o navegador bloqueia). Use:
```
python -m http.server 8000 --directory builds/v0.3.0-teste/web
```
e abra http://localhost:8000. Ou, no editor do Godot, o botão *Executar no navegador* (ícone ao lado do Play).

## Histórico

| Versão | Data | Canal | O que mudou |
|---|---|---|---|
| v0.3.4-teste | 24/11/2026 | teste | **Som no navegador consertado** (os buses Musica/Efeitos eram criados por código e o Godot desligava o som da saída na web; agora vêm do `default_bus_layout.tres`). Menu inicial com Jogar, Volume e Sair. "Baixar para Windows" do site baixa o executável. |
| v0.3.3-teste | 24/11/2026 | teste | Botão de volume do mesmo tamanho e cor do botão de pular (ícone em pixel art). No navegador, aviso "Clique ou aperte uma tecla para ligar o som" até o navegador liberar o áudio. |
| v0.3.2-teste | 24/11/2026 | teste | Botão de volume sempre no canto superior direito (na historinha, ao lado do botão de pular). |
| v0.3.1-teste | 24/11/2026 | teste | Sons e música (trilha da escola no estilo 8-bit clássico). Botão de volume embaixo do minimapa (Geral, Música e Interações, salvo entre partidas). "[E] Conversar" não fica mais escondido atrás dos móveis nem duplicado perto de dois NPCs. |
| v0.3.0-teste | 22/11/2026 | teste | Primeira build publicada. Jogo completo: historinha do começo, Fases 1, 2 e 3 e encerramento. Correção dos alunos que sumiam do corredor (conflito de merge no `npc_aluno.tscn`) e botão de pular a historinha com ícone. Símbolos que viravam quadradinho no navegador (►, ✎, ⏭, emojis) trocados. |
