/* PITAGOROME - interações: menu, abas, entrada ao rolar, galeria e desafio de exemplo */
const $=(s,c=document)=>c.querySelector(s), $$=(s,c=document)=>[...c.querySelectorAll(s)];

// Menu mobile + fundo do cabeçalho ao rolar
const nav=$('.nav'), btn=$('.nav__btn'), menu=$('#menu');
btn.addEventListener('click',()=>{const o=menu.classList.toggle('open');btn.setAttribute('aria-expanded',o)});
menu.addEventListener('click',e=>{if(e.target.tagName==='A'){menu.classList.remove('open');btn.setAttribute('aria-expanded',false)}});
const onScroll=()=>nav.classList.toggle('solid',scrollY>40);onScroll();addEventListener('scroll',onScroll,{passive:true});

// Entrada ao rolar
const io=new IntersectionObserver(es=>es.forEach(e=>{if(e.isIntersecting){e.target.classList.add('in');io.unobserve(e.target)}}),{threshold:.12});
$$('.rv').forEach(el=>io.observe(el));

// Abas das fases (setas do teclado funcionam)
const tabs=$$('[role=tab]');
function pick(t){tabs.forEach(x=>{const on=x===t;x.setAttribute('aria-selected',on);x.tabIndex=on?0:-1;$('#'+x.getAttribute('aria-controls')).hidden=!on});t.focus()}
tabs.forEach((t,i)=>{t.addEventListener('click',()=>pick(t));t.addEventListener('keydown',e=>{
  if(e.key==='ArrowRight')pick(tabs[(i+1)%3]);if(e.key==='ArrowLeft')pick(tabs[(i+2)%3])})});

// Galeria: amplia a imagem; sem imagem, mostra o espaço reservado
const lb=$('#lb'), body=$('#lb-body');
$$('.slot').forEach(s=>s.addEventListener('click',()=>{
  const img=$('img',s);
  body.innerHTML=img?`<img src="${img.src}" alt="${img.alt}">`:`<p>${$('.ph-label',s).textContent}: a imagem ainda não foi adicionada.</p>`;
  lb.showModal()}));
lb.addEventListener('click',e=>{if(e.target===lb)lb.close()});

// Desafio de exemplo (Task 6): 2x + 6 = 36 -> x = 15 -> 15 - 3 = 12
$('#try').addEventListener('submit',e=>{
  e.preventDefault();const v=+$('#arm').value,o=$('#try-out');
  o.textContent=v===12?'Armário 12 aberto. Achou o troféu! (2x + 6 = 36, x = 15, 15 − 3 = 12)':'O armário '+v+' está vazio. Tente resolver a equação primeiro.';
});
