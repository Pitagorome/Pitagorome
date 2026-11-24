# Pitagorome

## Sobre o Projeto

O **Pitagorome** é um jogo educativo de matemática e administração escolar, desenvolvido como projeto do **Instituto Federal de Educação, Ciência e Tecnologia de São Paulo – Campus São Paulo**.

O projeto utiliza elementos de jogos para apresentar conteúdos matemáticos de forma contextualizada e interativa. O jogador assume o papel de diretor(a) de uma escola e participa de situações relacionadas à administração escolar, exploração do ambiente, interação com personagens e resolução de desafios matemáticos.

A proposta é integrar o aprendizado de matemática à experiência de jogo, utilizando progressão, desafios e situações práticas para estimular o raciocínio lógico e o envolvimento do jogador.

---

## Objetivos

* Desenvolver um jogo educativo voltado para estudantes do Ensino Médio.
* Integrar conteúdos matemáticos a situações contextualizadas dentro do jogo.
* Utilizar elementos de gamificação para estimular o interesse e a participação do jogador.
* Incentivar o raciocínio lógico e a resolução de problemas.
* Criar uma experiência de aprendizagem baseada em exploração, interação e progressão.

---

## Tecnologias Utilizadas

* **Engine:** Godot Engine 4
* **Linguagem:** GDScript
* **Plataforma:** HTML5
* **Gráficos:** Pixel Art 2D
* **Perspectiva:** Top-down

---

## Funcionalidades

### Gameplay

* Movimentação do personagem pelo ambiente.
* Exploração de diferentes áreas da escola.
* Interação com NPCs.
* Sistema de diálogos e contextualização narrativa.
* Desafios matemáticos integrados à gameplay.
* Progressão por fases.
* Sistema de missões e objetivos.
* Salvamento do progresso.
* Música de fundo e efeitos sonoros (tecla **M** liga/desliga a música). Todos os sons são sintetizados por `tools/gerar_sons.py`, sem músicas de terceiros (sem copyright).

### Conteúdo Matemático

Os desafios do jogo abordam conteúdos matemáticos relacionados ao Ensino Médio, integrados às situações apresentadas durante a experiência de jogo.

Entre os conteúdos previstos estão:

* Porcentagem;
* Probabilidade;
* Análise combinatória;
* Funções;
* Equações;
* Raciocínio algébrico.

---

## Estrutura do Projeto

O projeto é organizado principalmente entre cenas, scripts, recursos gráficos e dados utilizados pelo jogo.

```text
pitagorome/
├── scenes/       # Cenas e ambientes do jogo
├── scripts/      # Scripts em GDScript
├── assets/       # Recursos gráficos e outros assets
├── aseprites/    # Arquivos-fonte dos sprites
├── data/         # Dados utilizados pelo jogo
└── TileMap-pronto/      # Tilesets e elementos dos ambientes
```

---

## Execução

O projeto pode ser aberto diretamente pelo **Godot Engine 4** através do arquivo de projeto disponível neste repositório.

A cena principal atualmente utilizada é:

```text
res://scenes/intro/intro_scene.tscn
```

A versão destinada à execução em navegador utiliza exportação para **HTML5**.

---

## Autores

**Ana Julia Cardoso Moser**
**Eduardo de Lazzari Oliveira**
**Guilherme Pereira de Oliveira**
**João Paulo Queiroz Costa**

Instituto Federal de Educação, Ciência e Tecnologia de São Paulo – Campus São Paulo
