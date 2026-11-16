import { useState } from "react";
import { createFileRoute } from "@tanstack/react-router";
import { PageHero, SectionTitle } from "@/components/site/PageHero";
import { Prop, TileFill } from "@/components/site/Pixel";
import { CofrePuzzle } from "@/components/site/CofrePuzzle";
import { ArmarioPuzzle, MaquinaPuzzle } from "@/components/site/Puzzles";
import { Reveal } from "@/components/site/Reveal";
import { CONTROLS, PHASES, ROOMS, shots, tiles } from "@/lib/game-content";
import { cn } from "@/lib/utils";

export const Route = createFileRoute("/o-jogo")({
  head: () => ({
    meta: [
      { title: "O Jogo · Pitagorome" },
      {
        name: "description",
        content:
          "Três fases, 15 tarefas e uma escola inteira para administrar. Veja como se joga o Pitagorome.",
      },
      { property: "og:title", content: "Como se joga o Pitagorome" },
      {
        property: "og:description",
        content: "Três trimestres, 15 tarefas e desafios de lógica, equações e funções.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: GamePage,
});

function GamePage() {
  return (
    <>
      <PageHero eyebrow="O jogo" title="Três trimestres para salvar a escola">
        Escolha nome e aparência, percorra a escola em visão de cima e converse com quem aparece.
        Quando surge um problema, ele vira um desafio.
      </PageHero>
      <HowTo />
      <Phases />
      <Rooms />
      <Puzzle />
    </>
  );
}

function HowTo() {
  return (
    <Reveal
      as="section"
      className="mx-auto grid max-w-6xl items-start gap-12 px-6 py-24 lg:grid-cols-2"
    >
      <div>
        <SectionTitle eyebrow="Primeiros passos" title="Crie seu diretor ou diretora">
          Antes do tour, a Coordenadora pergunta seu nome. Você escolhe se é diretor ou diretora e
          uma das aparências disponíveis.
        </SectionTitle>
        <div className="mt-10 space-y-3">
          <p className="font-display text-sm uppercase tracking-[0.2em] text-highlight">
            Controles
          </p>
          {CONTROLS.map((c) => (
            <div key={c.action} className="flex flex-wrap items-center gap-3">
              <div className="flex gap-1.5">
                {c.keys.map((k) => (
                  <kbd
                    key={k}
                    className="min-w-10 rounded-md border-[3px] border-b-[5px] border-panel-border bg-card px-2.5 py-1 text-center font-display text-sm text-card-foreground"
                  >
                    {k}
                  </kbd>
                ))}
              </div>
              {c.alt && <span className="text-sm text-muted-foreground">{c.alt}</span>}
              <span className="font-medium">{c.action}</span>
            </div>
          ))}
        </div>
      </div>
      <figure className="overflow-hidden rounded-2xl border-4 border-panel-border shadow-pixel-lg">
        <img
          src={shots.criacaoPersonagem}
          alt="Tela de criação de personagem com nome, diretor ou diretora e aparência"
          className="pixelated w-full"
          width={1228}
          height={675}
        />
      </figure>
    </Reveal>
  );
}

function Phases() {
  const [active, setActive] = useState("fase-1");
  const phase = PHASES.find((p) => p.id === active);
  if (!phase) return null;
  return (
    <section className="bg-ink py-24 text-ink-foreground">
      <div className="mx-auto max-w-6xl px-6">
        <p className="font-display text-sm uppercase tracking-[0.2em] text-accent">Roteiro</p>
        <h2 className="mt-2 text-3xl md:text-5xl">Quinze tarefas, três fases</h2>

        <div className="mt-10 flex flex-wrap gap-2" role="tablist" aria-label="Fases do jogo">
          {PHASES.map((p) => (
            <button
              key={p.id}
              role="tab"
              aria-selected={p.id === active}
              onClick={() => setActive(p.id)}
              className={cn(
                "rounded-lg border-[3px] px-4 py-2 font-display transition-all",
                p.id === active
                  ? "border-accent bg-accent text-accent-foreground shadow-pixel"
                  : "border-ink-foreground/20 text-ink-foreground/80 hover:border-ink-foreground/50",
              )}
            >
              {p.label}
            </button>
          ))}
        </div>

        <div className="mt-8 flex flex-wrap items-center gap-3" role="tabpanel">
          <h3 className="text-2xl text-accent">{phase.title}</h3>
          <span
            className={cn(
              "rounded-md px-2.5 py-1 text-xs font-bold uppercase tracking-wide",
              phase.status === "jogável"
                ? "bg-success text-primary-foreground"
                : "bg-ink-foreground/15 text-ink-foreground",
            )}
          >
            {phase.status}
          </span>
        </div>

        <ol key={phase.id} className="mt-8 grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {phase.tasks.map((t, i) => (
            <li key={t.title} className="hud p-5">
              <p className="text-xs text-ink-foreground/65">Tarefa {i + 1}</p>
              <p className="mt-1 text-lg font-semibold">{t.title}</p>
              <p className="mt-1 text-sm text-accent">{t.topic}</p>
              {t.text && (
                <p className="mt-3 text-sm leading-relaxed text-ink-foreground/80">{t.text}</p>
              )}
            </li>
          ))}
        </ol>

        {/* Um desafio jogável por fase (os da fase 2 e 3 vêm do site "cofounder") */}
        <div className="mt-12 max-w-2xl">
          {phase.id === "fase-1" && (
            <div className="panel flex flex-wrap items-center justify-between gap-4 p-6">
              <div>
                <p className="font-display text-sm uppercase tracking-[0.2em] text-highlight">
                  Teste um desafio
                </p>
                <p className="mt-1 text-xl font-semibold text-card-foreground">O Cofre da Escola</p>
              </div>
              <a
                href="#cofre"
                className="inline-flex items-center rounded-lg border-[3px] border-panel-border bg-accent px-4 py-2 font-display text-accent-foreground shadow-pixel transition-transform hover:-translate-y-0.5"
              >
                Abrir o cadeado ↓
              </a>
            </div>
          )}
          {phase.id === "fase-2" && <ArmarioPuzzle />}
          {phase.id === "fase-3" && <MaquinaPuzzle />}
        </div>
      </div>
    </section>
  );
}

function Rooms() {
  return (
    <section className="mx-auto max-w-6xl px-6 py-24">
      <SectionTitle eyebrow="Ambientes" title="Conheça a escola">
        Cada sala usa os pisos e paredes que você encontra no jogo.
      </SectionTitle>
      <Reveal className="stagger mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {ROOMS.map((r) => (
          <article key={r.name} className="panel overflow-hidden p-0">
            <div className="relative">
              <TileFill
                src={r.wall}
                w={r.wallSize[0]}
                h={r.wallSize[1]}
                scale={3}
                className="h-16"
              />
              <TileFill
                src={r.floor}
                w={r.floorSize[0]}
                h={r.floorSize[1]}
                scale={3}
                className="flex h-32 items-end justify-center pb-3"
              >
                <Prop name={r.prop} scale={3} />
              </TileFill>
            </div>
            <div className="p-5">
              <h3 className="text-xl text-card-foreground">{r.name}</h3>
              <p className="mt-1 text-sm text-muted-foreground">{r.text}</p>
            </div>
          </article>
        ))}
      </Reveal>
    </section>
  );
}

function Puzzle() {
  return (
    <section id="cofre" className="relative scroll-mt-20">
      <TileFill src={tiles.pisosTijolo} w={48} h={32} scale={3} className="py-24">
        <div className="mx-auto max-w-6xl px-6">
          <Reveal className="panel p-6 md:p-10">
            <div className="flex flex-wrap items-end justify-between gap-4">
              <div>
                <p className="font-display text-sm uppercase tracking-[0.2em] text-highlight">
                  Teste um desafio
                </p>
                <h2 className="mt-2 text-3xl text-card-foreground md:text-4xl">
                  O Cofre da Escola
                </h2>
                <p className="mt-2 max-w-xl text-muted-foreground">
                  Fase 1, Tarefa 3. O material novo está trancado no almoxarifado e o Zelador
                  esqueceu a senha. Use as pistas para abrir o cadeado.
                </p>
              </div>
              <Prop name="plantPalm" scale={3} />
            </div>
            <div className="mt-10">
              <CofrePuzzle />
            </div>
          </Reveal>
        </div>
      </TileFill>
    </section>
  );
}
