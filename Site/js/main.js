/* =========================================================
   Comportamento do site (JavaScript puro, sem bibliotecas).
   Cada parte só roda se o elemento dela existir na página.
   ========================================================= */
(function () {
  "use strict";

  var semMovimento = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var ICONE_GITHUB = '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M12 .5C5.7.5.5 5.7.5 12c0 5.1 3.3 9.4 7.9 10.9.6.1.8-.3.8-.6v-2c-3.2.7-3.9-1.5-3.9-1.5-.5-1.3-1.3-1.7-1.3-1.7-1-.7.1-.7.1-.7 1.2.1 1.8 1.2 1.8 1.2 1 1.8 2.8 1.3 3.5 1 .1-.8.4-1.3.7-1.6-2.6-.3-5.3-1.3-5.3-5.7 0-1.3.5-2.3 1.2-3.1-.1-.3-.5-1.5.1-3.2 0 0 1-.3 3.3 1.2a11.5 11.5 0 0 1 6 0c2.3-1.5 3.3-1.2 3.3-1.2.6 1.7.2 2.9.1 3.2.8.8 1.2 1.8 1.2 3.1 0 4.4-2.7 5.4-5.3 5.7.4.4.8 1.1.8 2.2v3.3c0 .3.2.7.8.6A11.5 11.5 0 0 0 23.5 12C23.5 5.7 18.3.5 12 .5Z"/></svg>';

  function $(sel, raiz) { return (raiz || document).querySelector(sel); }
  function $$(sel, raiz) { return Array.prototype.slice.call((raiz || document).querySelectorAll(sel)); }
  function esc(t) { return String(t).replace(/[&<>"]/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]; }); }
  function sprite(nome, escala, classe) {
    return '<div class="sprite ' + (classe || "parado") + '" style="--s:' + escala + ';background-image:url(assets/sprites/' + nome + '.png)" role="img" aria-label=""></div>';
  }

  /* ---------- Cabeçalho e rodapé (iguais em todas as páginas) ---------- */
  var PAGINAS = [
    ["o-jogo.html", "O Jogo"], ["personagens.html", "Personagens"], ["galeria.html", "Galeria"],
    ["novidades.html", "Novidades"], ["downloads.html", "Downloads"], ["equipe.html", "Equipe"]
  ];
  var atual = location.pathname.split("/").pop() || "index.html";
  function links() {
    return PAGINAS.map(function (p) {
      return '<a href="' + p[0] + '"' + (p[0] === atual ? ' class="atual" aria-current="page"' : "") + ">" + p[1] + "</a>";
    }).join("");
  }

  var lugarCabecalho = $("[data-cabecalho]");
  if (lugarCabecalho) {
    lugarCabecalho.outerHTML =
      '<div class="barra-progresso" id="barra" aria-hidden="true"></div>' +
      '<header class="cabecalho" id="cabecalho">' +
      '<div class="cabecalho-linha">' +
      '<a href="index.html" aria-label="Pitagorome, página inicial"><img class="logo" src="assets/img/logo.png" alt="Pitagorome" width="520" height="84"></a>' +
      '<nav class="menu vidro" aria-label="Principal">' + links() + "</nav>" +
      '<div><a class="botao botao-creme botao-p botao-github" href="' + REPO_URL + '" target="_blank" rel="noreferrer">' + ICONE_GITHUB + " GitHub</a>" +
      '<button class="botao botao-vidro vidro botao-icone botao-menu" id="botao-menu" aria-label="Abrir menu" aria-expanded="false">☰</button></div>' +
      "</div>" +
      '<nav class="menu-celular vidro" aria-label="Menu">' + '<a href="index.html"' + (atual === "index.html" ? ' class="atual"' : "") + ">Início</a>" + links() + "</nav>" +
      "</header>";

    var cabecalho = $("#cabecalho"), barra = $("#barra"), botaoMenu = $("#botao-menu");
    botaoMenu.addEventListener("click", function () {
      var aberto = cabecalho.classList.toggle("aberto");
      botaoMenu.setAttribute("aria-expanded", aberto);
      botaoMenu.textContent = aberto ? "✕" : "☰";
    });
    var pedido = 0;
    function aoRolar() {
      cancelAnimationFrame(pedido);
      pedido = requestAnimationFrame(function () {
        var h = document.documentElement;
        var max = Math.max(1, h.scrollHeight - window.innerHeight);
        barra.style.transform = "scaleX(" + Math.min(1, h.scrollTop / max) + ")";
        cabecalho.classList.toggle("compacto", h.scrollTop > 40);
      });
    }
    window.addEventListener("scroll", aoRolar, { passive: true });
    window.addEventListener("resize", aoRolar);
    aoRolar();
  }

  var lugarRodape = $("[data-rodape]");
  if (lugarRodape) {
    lugarRodape.outerHTML =
      '<footer class="rodape">' +
      '<div class="gramado piso" style="background-image:url(assets/tiles/grama.png)"><div class="gramado-objetos">' +
      '<img class="pixel" src="assets/props/plant_palm.png" width="112" height="160" alt="">' +
      '<img class="pixel" src="assets/props/student_desk.png" width="80" height="128" alt="">' +
      sprite("adam-parado", 4) +
      '<img class="pixel" src="assets/props/lockers_metal.png" width="80" height="120" alt="">' +
      '<img class="pixel" src="assets/props/plant_ficus.png" width="96" height="160" alt="">' +
      "</div></div>" +
      '<div class="calcada piso" style="background-image:url(assets/tiles/calcada.png)"></div>' +
      '<div class="escuro"><div class="conteudo rodape-grade">' +
      '<div><img src="assets/img/logo.png" alt="Pitagorome" width="520" height="84" style="height:2.5rem;width:auto"><p>Jogo educativo de matemática e administração escolar. Projeto do Instituto Federal de São Paulo, Campus São Paulo.</p></div>' +
      '<div><b>O jogo</b><ul><li><a href="o-jogo.html">Como se joga</a></li><li><a href="personagens.html">Personagens</a></li><li><a href="galeria.html">Galeria</a></li><li><a href="downloads.html">Downloads</a></li></ul></div>' +
      '<div><b>Projeto</b><ul><li><a href="novidades.html">Novidades</a></li><li><a href="equipe.html">Equipe</a></li><li><a href="' + REPO_URL + '" target="_blank" rel="noreferrer">GitHub</a></li></ul></div>' +
      "</div>" +
      '<div class="rodape-fim"><p class="conteudo">Desenvolvido por Ana Julia, Eduardo, Guilherme e João Paulo · IFSP, 2026 · Tiles e personagens: Modern Interiors/Exteriors por LimeZu (uso não comercial).</p></div>' +
      "</div></footer>";
  }

  /* Botões "GitHub" escritos nas páginas recebem o ícone */
  $$("[data-icone-github]").forEach(function (el) { el.insertAdjacentHTML("afterbegin", ICONE_GITHUB + " "); });

  /* ---------- Entrada ao rolar ---------- */
  var blocos = $$(".surgir");
  if ("IntersectionObserver" in window) {
    var observador = new IntersectionObserver(function (itens) {
      itens.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add("visivel"); observador.unobserve(e.target); }
      });
    }, { threshold: 0.12 });
    blocos.forEach(function (el) { observador.observe(el); });
  } else {
    blocos.forEach(function (el) { el.classList.add("visivel"); });
  }

  /* ---------- Caixa de diálogo (texto aparecendo letra por letra) ---------- */
  var dialogo = $("#dialogo");
  if (dialogo) {
    var linha = 0, mostrado = 0, temporizador;
    var quem = $(".dialogo-quem", dialogo), fala = $(".dialogo-fala", dialogo), dica = $(".dialogo-dica", dialogo);
    var desenhar = function () {
      var texto = DIALOGO[linha][1], pronto = mostrado >= texto.length;
      quem.textContent = DIALOGO[linha][0];
      fala.innerHTML = esc(texto.slice(0, mostrado)) + (pronto ? "" : '<span class="cursor">▌</span>');
      dica.textContent = "▾ Clique para continuar · " + (linha + 1) + "/" + DIALOGO.length;
      if (!pronto) temporizador = setTimeout(function () { mostrado += 2; desenhar(); }, 22);
    };
    dialogo.addEventListener("click", function () {
      clearTimeout(temporizador);
      if (mostrado < DIALOGO[linha][1].length) mostrado = DIALOGO[linha][1].length;
      else { linha = (linha + 1) % DIALOGO.length; mostrado = semMovimento ? 9999 : 0; }
      desenhar();
    });
    if (semMovimento) mostrado = 9999;
    desenhar();
  }

  /* ---------- Cartões de personagem (carrossel e página Personagens) ---------- */
  function cartaoPersonagem(p, i, comFala) {
    return '<article class="painel cartao-personagem">' +
      '<div class="retrato">' + (p.sprite ? sprite(p.sprite, 4) : "<span>?</span>") + "</div>" +
      '<small class="cargo">' + (comFala ? "" : "Personagem " + String(i + 1).padStart(2, "0") + " · ") + esc(p.cargo) + "</small>" +
      "<h3>" + esc(p.nome) + "</h3><p>" + esc(p.texto) + "</p>" +
      (comFala && p.fala ? "<blockquote>“" + esc(p.fala) + "”</blockquote>" : "") +
      "</article>";
  }
  var trilho = $("#trilho");
  if (trilho) {
    trilho.innerHTML = PERSONAGENS.map(function (p, i) { return "<li>" + cartaoPersonagem(p, i, false) + "</li>"; }).join("");
    $$("[data-carrossel]").forEach(function (b) {
      b.addEventListener("click", function () {
        trilho.scrollBy({ left: Number(b.getAttribute("data-carrossel")) * 300, behavior: semMovimento ? "auto" : "smooth" });
      });
    });
  }
  var gradePersonagens = $("#grade-personagens");
  if (gradePersonagens) {
    gradePersonagens.innerHTML = PERSONAGENS.map(function (p, i) { return cartaoPersonagem(p, i, true); }).join("");
  }

  /* ---------- Lousa ---------- */
  var lousa = $("#lousa");
  if (lousa) {
    var abas = $(".lousa-abas", lousa), quadro = $(".lousa-quadro", lousa);
    var item = 0, automatico = !semMovimento, pausado = false, relogio;
    var desenharAbas = function () {
      abas.innerHTML = LOUSA.map(function (q, n) {
        return '<button type="button" role="tab" class="lousa-aba' + (n === item ? " ativa" : "") + '" aria-selected="' + (n === item) + '" data-n="' + n + '">' +
          esc(q.topico) + (n === item && automatico && !pausado ? '<span class="lousa-tempo"></span>' : "") + "</button>";
      }).join("");
      clearTimeout(relogio);
      if (automatico && !pausado) relogio = setTimeout(function () { item = (item + 1) % LOUSA.length; desenharQuadro(); }, 5500);
    };
    var desenharQuadro = function () {
      var q = LOUSA[item];
      quadro.innerHTML = "<small>" + esc(q.topico) + '</small><div class="giz" style="--n:' + q.formula.length + '">' + esc(q.formula) + "</div>" +
        "<p>" + esc(q.desc) + "</p><ul>" + q.tarefas.map(function (t) { return "<li>" + esc(t) + "</li>"; }).join("") + "</ul>";
      desenharAbas();
    };
    abas.addEventListener("click", function (e) {
      var b = e.target.closest("[data-n]");
      if (!b) return;
      item = Number(b.getAttribute("data-n"));
      automatico = false;
      desenharQuadro();
      var nova = $('[data-n="' + item + '"]', abas);
      if (nova) nova.focus();
    });
    lousa.addEventListener("mouseenter", function () { pausado = true; desenharAbas(); });
    lousa.addEventListener("mouseleave", function () { pausado = false; desenharAbas(); });
    desenharQuadro();
  }

  /* ---------- Fases (O Jogo) ---------- */
  var fases = $("#fases");
  if (fases) {
    var abasFases = $(".abas-fases", fases), painelFase = $("#painel-fase", fases);
    var desafios = { "fase-1": $("#desafio-fase-1"), "fase-2": $("#desafio-fase-2"), "fase-3": $("#desafio-fase-3") };
    var mostrarFase = function (id) {
      var f = FASES.filter(function (x) { return x.id === id; })[0];
      abasFases.innerHTML = FASES.map(function (x) {
        return '<button type="button" role="tab" class="aba-fase' + (x.id === id ? " ativa" : "") + '" aria-selected="' + (x.id === id) + '" data-fase="' + x.id + '"><small>' + esc(x.rotulo) + "</small><b>" + esc(x.titulo) + "</b></button>";
      }).join("");
      var inicio = FASES.indexOf(f) * 5;
      painelFase.innerHTML =
        '<div class="fase-cabecalho"><h3>' + esc(f.titulo) + '</h3><span class="situacao ' + (f.jogavel ? "jogavel" : "desenvolvimento") + '">' + (f.jogavel ? "Jogável" : "Em desenvolvimento") + "</span></div>" +
        '<ol class="tarefas">' + f.tarefas.map(function (t, i) {
          return '<li class="hud"><small>Tarefa ' + (inicio + i + 1) + "</small><h4>" + esc(t.titulo) + '</h4><p class="tema">' + esc(t.tema) + "</p>" + (t.texto ? "<p>" + esc(t.texto) + "</p>" : "") + "</li>";
        }).join("") + "</ol>";
      Object.keys(desafios).forEach(function (k) { if (desafios[k]) desafios[k].hidden = k !== id; });
    };
    abasFases.addEventListener("click", function (e) {
      var b = e.target.closest("[data-fase]");
      if (b) mostrarFase(b.getAttribute("data-fase"));
    });
    mostrarFase("fase-1");
  }

  /* ---------- Desafio: O Cofre da Escola (Fase 1) ---------- */
  var cofre = $("#cofre-form");
  if (cofre) {
    cofre.addEventListener("submit", function (e) {
      e.preventDefault();
      var campos = $$(".digito", cofre).map(function (c) { return c.value; });
      var saida = $("#cofre-resultado");
      if (campos.some(function (v) { return v === "" || !/^\d$/.test(v); })) {
        saida.className = "resultado errado";
        saida.textContent = "O cadeado tem exatamente 3 dígitos (de 0 a 9).";
        return;
      }
      var d = campos.map(Number), a = d[0], b = d[1], c = d[2], erros = [];
      if (a % 2 !== 0) erros.push("O primeiro número precisa ser par.");
      if (a + b + c !== 12) erros.push("A soma dos três precisa dar 12 (deu " + (a + b + c) + ").");
      if (a === b || b === c || a === c) erros.push("Nenhum dígito pode se repetir.");
      if (!(a < b && b < c)) erros.push("Os dígitos precisam estar em ordem crescente.");
      if (d.some(function (x) { return x % 2 !== 0; })) erros.push("Todos os dígitos eram pares.");
      if (d.indexOf(0) !== -1) erros.push("Nenhum dígito era zero.");
      if (erros.length === 0) {
        saida.className = "resultado certo";
        saida.textContent = "Clique! O cadeado abriu: " + d.join("") + ". O almoxarifado está liberado.";
      } else {
        saida.className = "resultado errado";
        saida.innerHTML = "O cadeado não abriu:<ul>" + erros.map(function (x) { return "<li>" + esc(x) + "</li>"; }).join("") + "</ul>";
      }
    });
    $$(".digito", cofre).forEach(function (campo, i, todos) {
      campo.addEventListener("input", function () {
        campo.value = campo.value.replace(/\D/g, "").slice(-1);
        if (campo.value && todos[i + 1]) todos[i + 1].focus();
      });
    });
  }

  /* ---------- Desafio: O Troféu Desaparecido (Fase 2) ---------- */
  var armario = $("#armario-form");
  if (armario) {
    armario.addEventListener("submit", function (e) {
      e.preventDefault();
      var v = $("#armario").value, saida = $("#armario-resultado");
      if (v === "") { saida.className = "resultado errado"; saida.textContent = "Digite o número de um armário."; return; }
      var n = Number(v), certo = (36 - 6) / 2 - 3; // 2x + 6 = 36 → x = 15 → 15 − 3 = 12
      if (n === certo) {
        saida.className = "resultado certo";
        saida.textContent = "Armário " + n + " aberto. Achou o troféu! (2x + 6 = 36, x = 15, 15 − 3 = 12)";
      } else {
        saida.className = "resultado errado";
        saida.textContent = "O armário " + n + " está vazio. Tente resolver a equação primeiro.";
      }
    });
  }

  /* ---------- Desafio: A Máquina de Refrigerante (Fase 3) ---------- */
  var maquina = $("#maquina-botao");
  if (maquina) {
    maquina.addEventListener("click", function () {
      var aberto = maquina.getAttribute("aria-expanded") !== "true";
      maquina.setAttribute("aria-expanded", aberto);
      maquina.textContent = aberto ? "Esconder resposta" : "Descobrir o preço de 6";
      $("#maquina-preco").textContent = aberto ? "R$ 21" : "?";
      $("#maquina-resultado").textContent = aberto ? "A função é y = 3x + 3." : "";
    });
  }

  /* ---------- Galeria com ampliação ---------- */
  var galeria = $("#galeria");
  if (galeria) {
    galeria.innerHTML = GALERIA.map(function (g, i) {
      return '<button type="button" data-foto="' + i + '"><figure><div class="moldura"><img class="pixel" src="' + g.img + '" alt="' + esc(g.titulo) + '" loading="lazy"></div>' +
        "<figcaption><b>" + esc(g.titulo) + "</b><span>" + esc(g.texto) + "</span></figcaption></figure></button>";
    }).join("");
    var amp = $("#ampliada"), ampImg = $("img", amp), ampTxt = $("p", amp), foto = 0, ultimoFoco = null;
    var abrir = function (i) {
      foto = (i + GALERIA.length) % GALERIA.length;
      ampImg.src = GALERIA[foto].img;
      ampImg.alt = GALERIA[foto].titulo;
      ampTxt.textContent = GALERIA[foto].titulo + " · " + GALERIA[foto].texto;
      if (!amp.classList.contains("aberta")) { ultimoFoco = document.activeElement; amp.classList.add("aberta"); $(".fechar", amp).focus(); }
    };
    var fechar = function () { amp.classList.remove("aberta"); if (ultimoFoco) ultimoFoco.focus(); };
    galeria.addEventListener("click", function (e) { var b = e.target.closest("[data-foto]"); if (b) abrir(Number(b.getAttribute("data-foto"))); });
    $(".fechar", amp).addEventListener("click", fechar);
    $(".anterior", amp).addEventListener("click", function () { abrir(foto - 1); });
    $(".proxima", amp).addEventListener("click", function () { abrir(foto + 1); });
    amp.addEventListener("click", function (e) { if (e.target === amp) fechar(); });
    document.addEventListener("keydown", function (e) {
      if (!amp.classList.contains("aberta")) return;
      if (e.key === "Escape") fechar();
      if (e.key === "ArrowLeft") abrir(foto - 1);
      if (e.key === "ArrowRight") abrir(foto + 1);
    });
  }

  /* ---------- Downloads ---------- */
  var downloads = $("#downloads");
  if (downloads) {
    var grade = $(".grade-downloads", downloads);
    grade.innerHTML = DOWNLOADS.map(function (d) {
      var rotulo = (d.acao || "Baixar");
      var botao = (!DOWNLOADS_EM_BREVE && d.link)
        ? '<a class="botao botao-verde botao-p" href="' + esc(d.link) + '"' + (d.externo ? ' target="_blank" rel="noreferrer"' : " download") + ">" + (d.externo ? "▶ " : "⬇ ") + rotulo + "</a>"
        : '<button class="botao botao-verde botao-p" disabled>' + (d.externo ? "▶ " : "⬇ ") + rotulo + "</button>";
      return '<article class="painel"><div class="arte"><img class="pixel" src="assets/props/' + d.arte + '" width="' + d.largura + '" alt=""></div>' +
        "<small>" + esc(d.tipo) + "</small><h3>" + esc(d.nome) + "</h3><p>" + esc(d.texto) + "</p>" + botao + "</article>";
    }).join("");
    if (DOWNLOADS_EM_BREVE) {
      grade.setAttribute("inert", "");
      grade.setAttribute("aria-hidden", "true");
      downloads.insertAdjacentHTML("beforeend",
        '<div class="em-breve" role="status"><span class="em-breve-selo">Em breve</span>' +
        "<p>Os downloads serão liberados quando o jogo for lançado. Acompanhe o desenvolvimento no GitHub.</p>" +
        '<a class="botao botao-creme" href="' + REPO_URL + '" target="_blank" rel="noreferrer">' + ICONE_GITHUB + " Acompanhar no GitHub</a></div>");
    }
  }

  /* ---------- Novidades: últimos commits do repositório do jogo ---------- */
  var listaCommits = $("[data-commits]");
  if (listaCommits) {
    var quantos = Number(listaCommits.getAttribute("data-commits")) || 3;
    var TIPOS = [[/^(feat|add|adiciona|cria|novo|nova)/i, "Novidade"], [/^(fix|corrige|conserta|ajusta)/i, "Correção"], [/^(test|teste)/i, "Teste"], [/^(docs?|readme)/i, "Documentação"], [/^(refactor|refatora|melhora)/i, "Melhoria"]];
    var tipo = function (msg) {
      for (var i = 0; i < TIPOS.length; i++) if (TIPOS[i][0].test(msg)) return TIPOS[i][1];
      return "Atualização";
    };
    var semPrefixo = function (msg) { return msg.replace(/^\w+(\([^)]*\))?!?:\s*/, ""); };
    listaCommits.innerHTML = '<li class="painel aviso">Carregando as novidades do GitHub...</li>';
    fetch(REPO_API + "?per_page=" + quantos)
      .then(function (r) { if (!r.ok) throw new Error(r.status); return r.json(); })
      .then(function (lista) {
        listaCommits.innerHTML = lista.map(function (c) {
          var msg = (c.commit.message || "").split("\n")[0];
          var nome = (c.author && c.author.login) || c.commit.author.name;
          var data = new Date(c.commit.author.date).toLocaleDateString("pt-BR", { day: "numeric", month: "short", year: "numeric" });
          var foto = c.author && c.author.avatar_url
            ? '<img class="avatar" src="' + c.author.avatar_url + '&s=88" alt="" loading="lazy">'
            : '<span class="avatar"></span>';
          return '<li><a class="painel" href="' + c.html_url + '" target="_blank" rel="noreferrer">' + foto +
            '<div><span class="tipo-commit">' + tipo(msg) + '</span><span class="data-commit">' + data + "</span>" +
            '<p class="texto-commit">' + esc(semPrefixo(msg)) + '</p><p class="autor-commit">por ' + esc(nome) + " · <code>" + c.sha.slice(0, 7) + "</code></p></div></a></li>";
        }).join("");
      })
      .catch(function () {
        listaCommits.innerHTML = '<li class="painel aviso">Não foi possível carregar as novidades agora. <a href="' + REPO_URL + '/commits" target="_blank" rel="noreferrer"><u>Veja direto no GitHub</u></a>.</li>';
      });
  }
})();
