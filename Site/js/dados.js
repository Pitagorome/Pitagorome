/* =========================================================
   Textos e dados do site. Para mudar um texto, mude aqui.
   ========================================================= */

var REPO_URL = "https://github.com/Pitagorome/Pitagorome";
var REPO_API = "https://api.github.com/repos/Pitagorome/Pitagorome/commits";

/* Falas da abertura (data/dialogues/intro_dialogues.gd) */
var DIALOGO = [
  ["Coordenadora", "Ah, você chegou! Eu sou a Coordenadora da Escola Pitagorome, estávamos realmente precisando de um novo diretor desde que o último foi embora."],
  ["Coordenadora", "Aqui na Escola Pitagorome nós vivemos um dia de cada vez. Seu papel como diretor será organizar a escola e solucionar problemas."],
  ["Coordenadora", "Mas não se preocupe! Sempre que se sentir perdido ou precisar de ajuda, é só me procurar!"],
  ["Professor de Matemática", "Se precisar da minha ajuda, pode pedir... mas terá um preço... muahaha."]
];

/* Lousa da página inicial: conteúdo, fórmula escrita no quadro, descrição e tarefas do jogo */
var LOUSA = [
  { topico: "Lógica", formula: "se P, então Q", desc: "Horários sem conflito, senhas com pistas e depoimentos que não batem.", tarefas: ["Conflito no Horário", "O Cofre da Escola", "Quem Está Matando Aula?"] },
  { topico: "Equações", formula: "ax + b = c", desc: "Um bilhete do zelador esconde o número do armário certo.", tarefas: ["O Troféu Desaparecido", "O Gerador de Emergência", "As Mesas do Refeitório"] },
  { topico: "Proporções", formula: "a : b = c : d", desc: "Figurinhas e cartazes precisam manter a mesma proporção.", tarefas: ["Figurinhas", "O Cartaz da Feira"] },
  { topico: "Funções", formula: "y = ax + b", desc: "Uma máquina de refrigerante cobra seguindo um padrão que ninguém entendeu.", tarefas: ["A Máquina de Refrigerante"] },
  { topico: "Combinatória", formula: "C(n, p)", desc: "Quantas equipes, fotos e murais diferentes são possíveis?", tarefas: ["As Equipes da Gincana", "O Lugar da Foto Oficial", "A Decoração do Pátio"] },
  { topico: "Raciocínio algébrico", formula: "x + (x + k) = total", desc: "Montar a equação certa para descobrir o que cada interruptor controla.", tarefas: ["As Luzes do Corredor"] }
];

/* Personagens. "sprite" é a folha em assets/sprites (vazio = ainda não tem arte) */
var PERSONAGENS = [
  { nome: "Coordenadora", cargo: "Sua guia", texto: "Apresenta a escola, acompanha o tour e está sempre por perto quando você se sentir perdido.", sprite: "amelia-parado", fala: "Sempre que se sentir perdido ou precisar de ajuda, é só me procurar!" },
  { nome: "Zelador", cargo: "Guardião das chaves", texto: "Guarda tudo em segurança, e depois esquece onde. Mas sempre deixa pistas.", sprite: "alex-parado", fala: "Não sei como conseguem sujar o chão sem sair da cadeira." },
  { nome: "Professor de Matemática", cargo: "Ajuda com um preço", texto: "Responsável pela parte matemática da escola. Oferece ajuda, mas avisa que vai cobrar.", sprite: "bob-parado", fala: "Lembre-se, diretor: minha ajuda tem um preço... muahaha." },
  { nome: "João, Pedro e Lucas", cargo: "Alunos", texto: "Um deles matou aula. Ouça os três depoimentos e descubra quem está mentindo.", sprite: "adam-parado", fala: "Eu estava na aula o tempo todo!" },
  { nome: "Cantineira", cargo: "Em breve", texto: "Dona da cantina e do refeitório, garante que contou tudo direitinho." },
  { nome: "Secretária", cargo: "Em breve", texto: "Lida com formulários e documentos da escola." },
  { nome: "Inspetor", cargo: "Em breve", texto: "Vigia os corredores e confisca o que voa." }
];

/* Fases e tarefas do roteiro */
var FASES = [
  {
    id: "fase-1", rotulo: "Fase 1 · 1º trimestre", titulo: "Lógica e Organização", jogavel: true,
    tarefas: [
      { titulo: "Tour na Escola", tema: "conhecer os ambientes", texto: "A Coordenadora apresenta o corredor, o Zelador e a Sala de Matemática." },
      { titulo: "Conflito no Horário", tema: "lógica organizacional", texto: "Duas aulas marcadas no mesmo horário e na mesma sala. Reorganize a grade sem quebrar nenhuma regra." },
      { titulo: "O Cofre da Escola", tema: "lógica e combinatória", texto: "O Zelador esqueceu a senha do cadeado do almoxarifado, mas lembra de algumas pistas." },
      { titulo: "Quem Está Matando Aula?", tema: "raciocínio lógico", texto: "João, Pedro e Lucas deram depoimentos. Apenas um deles está mentindo." },
      { titulo: "O Ônibus da Excursão", tema: "distribuição com restrições", texto: "Duas vans, no máximo 4 passageiros cada e exatamente 1 monitor por van." }
    ]
  },
  {
    id: "fase-2", rotulo: "Fase 2 · 2º trimestre", titulo: "Equações, Proporções e Probabilidade", jogavel: false,
    tarefas: [
      { titulo: "O Troféu Desaparecido", tema: "equação de 1º grau" },
      { titulo: "Figurinhas", tema: "proporções" },
      { titulo: "O Gerador de Emergência", tema: "equações" },
      { titulo: "As Mesas do Refeitório", tema: "equação simples" },
      { titulo: "O Cartaz da Feira", tema: "proporção" }
    ]
  },
  {
    id: "fase-3", rotulo: "Fase 3 · 3º trimestre", titulo: "Funções, Combinatória e Raciocínio Algébrico", jogavel: false,
    tarefas: [
      { titulo: "A Máquina de Refrigerante", tema: "função afim" },
      { titulo: "As Equipes da Gincana", tema: "combinatória" },
      { titulo: "As Luzes do Corredor", tema: "raciocínio algébrico" },
      { titulo: "O Lugar da Foto Oficial", tema: "combinatória" },
      { titulo: "A Decoração do Pátio", tema: "combinatória" }
    ]
  }
];

/* Galeria */
var GALERIA = [
  { img: "assets/img/ambientes.png", titulo: "Corredor da escola", texto: "Fase 1 · Tarefa 1: o tour começa no corredor, com placas para cada sala." },
  { img: "assets/img/escola-conceito.png", titulo: "Primeira conversa", texto: "A Coordenadora recebe o novo diretor no gabinete." },
  { img: "assets/img/criacao-personagem.png", titulo: "Crie seu personagem", texto: "Escolha nome, se é diretor ou diretora e a aparência." },
  { img: "assets/img/fase-jogo.png", titulo: "Conflito no Horário", texto: "Tarefa 2: reorganize a grade sem quebrar nenhuma regra." },
  { img: "assets/img/personagens.png", titulo: "Elenco", texto: "As aparências do diretor e o Professor de Matemática." }
];

/* DOWNLOADS
   Enquanto DOWNLOADS_EM_BREVE for true, a página mostra o aviso "Em breve".
   Para liberar: coloque os arquivos na pasta downloads/, preencha o "link" de cada item
   (ex.: "downloads/pitagorome-windows.zip") e mude DOWNLOADS_EM_BREVE para false. */
var DOWNLOADS_EM_BREVE = true;
var DOWNLOADS = [
  { tipo: "HTML5", nome: "Versão para navegador", texto: "Jogue direto no navegador, sem instalar nada.", acao: "Jogar", externo: true, link: "", arte: "globe.png", largura: 64 },
  { tipo: "Computador", nome: "Windows", texto: "Pacote para computadores com Windows.", link: "", arte: "student_desk.png", largura: 60 },
  { tipo: "Computador", nome: "macOS", texto: "Pacote para computadores com macOS.", link: "", arte: "teacher_desk.png", largura: 128 },
  { tipo: "Computador", nome: "Linux", texto: "Pacote para computadores com Linux.", link: "", arte: "bookshelf_wood.png", largura: 64 }
];
