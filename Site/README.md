# Site do Pitagorome

Site de divulgação do **Pitagorome**, jogo educativo de matemática e administração escolar feito no Instituto Federal de São Paulo (IFSP), Campus São Paulo.

No jogo, você é o novo diretor da Escola Pitagorome e resolve os problemas do dia a dia da escola usando matemática. O site apresenta o jogo, as fases, os personagens, a galeria de imagens e as novidades do desenvolvimento.

## Como abrir

O site é feito só com **HTML, CSS e JavaScript**. Não precisa instalar nada nem rodar comandos.

- **Jeito mais simples:** abra o arquivo `index.html` no navegador (dois cliques).
- **Com servidor local (opcional):** dentro da pasta `Site`, rode `python -m http.server 8000` e acesse `http://localhost:8000`. No VS Code, a extensão *Live Server* faz o mesmo.

Para publicar, basta enviar a pasta `Site` para qualquer hospedagem de site estático (GitHub Pages, Netlify, Vercel etc.).

## Páginas

| Arquivo | O que tem |
| --- | --- |
| `index.html` | Início: apresentação, números do jogo, diálogo da Coordenadora, carrossel de personagens, lousa interativa e últimas novidades |
| `o-jogo.html` | Como se joga, controles, as 3 fases com suas tarefas, um desafio jogável por fase, os ambientes e o Cofre da Escola |
| `personagens.html` | Quem é quem na escola e as aparências do diretor |
| `galeria.html` | Capturas de tela do jogo, com ampliação (setas e Esc funcionam) |
| `novidades.html` | Últimos commits do repositório do jogo, carregados do GitHub |
| `downloads.html` | Versões do jogo (por enquanto com o aviso "Em breve") |
| `equipe.html` | Integrantes, objetivos, tecnologias e estrutura do repositório |

## Recursos

- **Lousa interativa:** escolha um conteúdo e a fórmula é "escrita" no quadro, com as tarefas do jogo em que ele aparece. Troca sozinha até o visitante clicar.
- **Desafios jogáveis:**
  - Fase 1: O Cofre da Escola (senha de 3 dígitos com pistas).
  - Fase 2: O Troféu Desaparecido (uma equação).
  - Fase 3: A Máquina de Refrigerante (uma função afim).
- **Diálogo animado:** a fala da Coordenadora aparece letra por letra, como no jogo.
- **Personagens animados** com os sprites do próprio jogo.
- **Animações ao rolar**, barra de progresso da leitura e cabeçalho que fica compacto ao descer.
- **Celular:** o menu vira um botão ☰ em telas pequenas.
- **Acessibilidade:** funciona pelo teclado, e quem pede menos movimento no sistema vê as animações desligadas.

## Estrutura de pastas

```
Site/
├── index.html, o-jogo.html, ...   uma página por arquivo
├── css/
│   └── style.css                  cores, fontes e todo o visual
├── js/
│   ├── dados.js                   textos e listas (personagens, fases, lousa, galeria, downloads)
│   └── main.js                    cabeçalho, rodapé, animações, lousa, desafios, galeria e novidades
├── assets/
│   ├── img/                       logo, imagem do topo e capturas de tela
│   ├── sprites/                   personagens animados (folhas de 16x32 do LimeZu)
│   ├── tiles/                     pisos e paredes do jogo
│   ├── props/                     móveis e objetos do jogo
│   └── personagens/               aparências do diretor
└── downloads/                     coloque aqui os arquivos do jogo para baixar
```

O cabeçalho e o rodapé são montados pelo `js/main.js`, então ficam iguais em todas as páginas. Para mudar um link do menu, mude a lista `PAGINAS` nesse arquivo.

## Como editar

- **Textos de personagens, fases, lousa, galeria e downloads:** `js/dados.js`.
- **Textos fixos das páginas:** direto no arquivo `.html` de cada página.
- **Logo:** troque `assets/img/logo.png` mantendo o nome do arquivo.
- **Cores e fontes:** variáveis no começo de `css/style.css`.
- **Liberar os downloads:**
  1. Coloque os arquivos na pasta `downloads/`.
  2. Preencha o campo `link` de cada item da lista `DOWNLOADS` em `js/dados.js` (por exemplo, `"downloads/pitagorome-windows.zip"`).
  3. Mude `DOWNLOADS_EM_BREVE` para `false`.

## Fontes

- **Bricolage Grotesque:** títulos e botões.
- **Inter:** texto.
- **Pixelify Sans:** só a letra de giz da lousa.

As fontes vêm do Google Fonts. Sem internet, o navegador usa fontes parecidas do sistema.

## Novidades

As páginas Início e Novidades buscam os últimos commits na API pública do GitHub. Não precisa de chave. Sem internet, ou se o limite de consultas do GitHub for atingido, aparece um aviso com o link para ver os commits direto no GitHub.

## Créditos

Desenvolvido por Ana Julia, Eduardo, Guilherme e João Paulo, no IFSP, em 2026.

Tiles e personagens: Modern Interiors e Modern Exteriors, por [LimeZu](https://limezu.itch.io), em uso não comercial.
