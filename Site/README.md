# Site do Pitagorome

Site de divulgação do **Pitagorome**, jogo educativo de matemática e administração escolar feito no Instituto Federal de São Paulo (IFSP), Campus São Paulo.

No jogo, você é o novo diretor da Escola Pitagorome e resolve os problemas do dia a dia da escola usando matemática. O site apresenta o jogo, as fases, os personagens, a galeria de imagens e as novidades do desenvolvimento.

## Páginas

| Página | Endereço | O que tem |
| --- | --- | --- |
| Início | `/` | Apresentação, números do jogo, diálogo da Coordenadora, carrossel de personagens, lousa interativa e últimas novidades |
| O Jogo | `/o-jogo` | Como se joga, as 3 fases com suas tarefas, um desafio jogável por fase e os ambientes da escola |
| Personagens | `/personagens` | Quem é quem na escola e as opções de visual do diretor |
| Galeria | `/galeria` | Capturas de tela do jogo, com ampliação |
| Novidades | `/novidades` | Últimos commits do repositório do jogo, carregados do GitHub |
| Downloads | `/downloads` | Versões do jogo (por enquanto com o aviso "Em breve") |
| Equipe | `/equipe` | Integrantes, tecnologias e estrutura do repositório |

## Recursos

- **Lousa interativa:** escolha um conteúdo (Lógica, Equações, Proporções, Funções, Combinatória ou Raciocínio algébrico) e a fórmula é "escrita" no quadro, com as tarefas do jogo em que ele aparece. Troca sozinha até o visitante clicar.
- **Desafios jogáveis:**
  - Fase 1: O Cofre da Escola.
  - Fase 2: O Troféu Desaparecido (uma equação).
  - Fase 3: A Máquina de Refrigerante (uma função afim).
- **Diálogo animado:** a fala da Coordenadora aparece letra por letra, como no jogo.
- **Carrossel de personagens** com os sprites animados do próprio jogo.
- **Animações de entrada ao rolar** a página, barra de progresso da leitura e cabeçalho que fica compacto ao descer.
- **Acessibilidade:** navegação por teclado e textos alternativos. Quem pede menos movimento no sistema vê as animações desligadas.

## Tecnologias

- [React 19](https://react.dev) com [TanStack Start](https://tanstack.com/start) e TanStack Router (rotas por arquivo)
- [Vite](https://vite.dev) para desenvolvimento e build
- [Tailwind CSS 4](https://tailwindcss.com) e componentes [shadcn/ui](https://ui.shadcn.com)
- [Vitest](https://vitest.dev) para testes
- Fontes: Bricolage Grotesque (títulos), Inter (texto) e Pixelify Sans (só na letra de giz da lousa)

## Como rodar

É preciso ter o [Node.js](https://nodejs.org) **22.12 ou mais novo** (ou 20.19+). Com versões mais antigas o `npm run dev` falha com "Cannot find native binding".

O `npm i` do npm 10 (que vem com o Node 20 e 22) quebra com o erro `Cannot read properties of null (reading 'edgesOut')`, então instale as dependências com o npm 11:

```sh
cd Site
npx npm@11 i
npm run dev
```

> O site não tem `index.html`: as páginas são montadas pelo servidor. Não adianta abrir a pasta com Live Server nem clicar duas vezes em arquivo, tem que rodar pelo terminal.

O site abre em `http://localhost:8080` (ou na porta que aparecer no terminal).

> As páginas Início e Novidades buscam os commits direto na API pública do GitHub, sem precisar de chave. Sem chave o GitHub libera 60 pedidos por hora, então o site guarda a resposta por 5 minutos. Se quiser aumentar esse limite, defina a variável `GITHUB_TOKEN` com um token do GitHub.

### Comandos

| Comando | O que faz |
| --- | --- |
| `npm run dev` | Inicia o site em modo de desenvolvimento |
| `npm run build` | Gera a versão final para publicar |
| `npm run preview` | Abre a versão gerada pelo build |
| `npm test` | Roda os testes |
| `npm run lint` | Verifica o código com o ESLint |
| `npm run format` | Formata o código com o Prettier |

## Estrutura de pastas

```
Site/
├── public/              arquivos servidos como estão (coloque aqui os downloads do jogo)
└── src/
    ├── routes/          uma página por arquivo (index, o-jogo, personagens, galeria, novidades, downloads, equipe)
    ├── components/site/ partes do site (cabeçalho, rodapé, lousa, desafios, carrossel, downloads...)
    ├── components/ui/   componentes de interface (shadcn/ui)
    ├── lib/             textos e dados do site (game-content.ts) e lógica dos desafios (puzzles.ts)
    ├── assets/          logo, imagem do topo e arte do jogo
    └── styles.css       cores, fontes e estilos gerais
```

## Como editar

- **Textos, fases, personagens e equipe:** quase tudo fica em `src/lib/game-content.ts`.
- **Conteúdos da lousa:** lista `QUADRO`, no mesmo arquivo.
- **Logo:** troque `src/assets/logo.png` mantendo o nome do arquivo.
- **Cores e fontes:** variáveis no começo de `src/styles.css`.
- **Liberar os downloads:**
  1. Coloque os arquivos em `public/downloads/`.
  2. Preencha o campo `href` de cada item da lista `DOWNLOADS` em `src/lib/game-content.ts` (por exemplo, `"/downloads/pitagorome-windows.zip"`).
  3. Mude `DOWNLOADS_SOON` para `false`.

## Créditos

Desenvolvido por Ana Julia, Eduardo, Guilherme e João Paulo, no IFSP, em 2026.

Tiles e personagens: Modern Interiors e Modern Exteriors, por [LimeZu](https://limezu.itch.io), em uso não comercial.
