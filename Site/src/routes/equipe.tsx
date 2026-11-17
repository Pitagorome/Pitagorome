import { createFileRoute } from "@tanstack/react-router";
import { Github } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PageHero, SectionTitle } from "@/components/site/PageHero";
import { Prop, Sprite, TileFill } from "@/components/site/Pixel";
import { Reveal } from "@/components/site/Reveal";
import { REPO_TREE, REPO_URL, TEAM, TECH, tiles } from "@/lib/game-content";

export const Route = createFileRoute("/equipe")({
  head: () => ({
    meta: [
      { title: "Equipe · Pitagorome" },
      {
        name: "description",
        content:
          "Quem fez o Pitagorome: estudantes do Instituto Federal de São Paulo, Campus São Paulo.",
      },
      { property: "og:title", content: "A equipe do Pitagorome" },
      {
        property: "og:description",
        content: "Projeto Interdisciplinar do IFSP feito com Godot Engine 4.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: TeamPage,
});

const OBJECTIVES = [
  "Criar um jogo educativo voltado ao Ensino Médio.",
  "Integrar conteúdos matemáticos a situações contextualizadas.",
  "Usar elementos de gamificação para estimular o interesse.",
  "Incentivar o raciocínio lógico e a resolução de problemas.",
  "Aprender por exploração, interação e progressão.",
];

function TeamPage() {
  return (
    <>
      <PageHero eyebrow="Equipe" title="Feito no Instituto Federal de São Paulo">
        Projeto Interdisciplinar do Técnico em Desenvolvimento de Sistemas integrado ao Ensino
        Médio, IFSP Campus São Paulo, 2026.
      </PageHero>

      <section className="relative">
        <TileFill src={tiles.pisosTaco} w={48} h={32} scale={3} className="py-24">
          <Reveal className="stagger mx-auto grid max-w-6xl gap-6 px-6 sm:grid-cols-2 lg:grid-cols-4">
            {TEAM.map((m) => (
              <article key={m.name} className="panel flex flex-col items-center p-6 text-center">
                <div className="flex h-36 items-end">
                  <Sprite sheet={m.sheet} scale={4} />
                </div>
                <h2 className="mt-4 text-lg leading-snug text-card-foreground">{m.name}</h2>
              </article>
            ))}
          </Reveal>
        </TileFill>
      </section>

      <Reveal as="section" className="mx-auto grid max-w-6xl gap-12 px-6 py-24 lg:grid-cols-2">
        <div>
          <SectionTitle eyebrow="Objetivos" title="Por que o Pitagorome existe" />
          <ul className="mt-8 space-y-3">
            {OBJECTIVES.map((o) => (
              <li key={o} className="flex gap-3">
                <span className="mt-1 grid h-5 w-5 shrink-0 place-items-center rounded bg-success text-xs text-primary-foreground">
                  ✓
                </span>
                <span>{o}</span>
              </li>
            ))}
          </ul>
          <p className="mt-10 font-display text-sm uppercase tracking-[0.2em] text-highlight">
            Estrutura do repositório
          </p>
          <pre className="tree mt-3" tabIndex={0}>
            {REPO_TREE}
          </pre>
        </div>
        <div className="panel p-6 md:p-8">
          <div className="flex items-end justify-between">
            <h2 className="text-2xl text-card-foreground">Como é feito</h2>
            <Prop name="bookRow" scale={4} />
          </div>
          <dl className="mt-6 divide-y divide-border">
            {TECH.map((t) => (
              <div key={t.label} className="flex justify-between py-3 text-sm">
                <dt className="text-muted-foreground">{t.label}</dt>
                <dd className="font-semibold">{t.value}</dd>
              </div>
            ))}
          </dl>
          <p className="mt-4 text-sm text-muted-foreground">
            Cena principal: <code className="font-mono">scenes/intro/intro_scene.tscn</code>. Abra o
            projeto pelo Godot Engine 4.
          </p>
          <Button asChild variant="game" className="mt-6">
            <a href={REPO_URL} target="_blank" rel="noreferrer">
              <Github /> Ver código no GitHub
            </a>
          </Button>
        </div>
      </Reveal>
    </>
  );
}
