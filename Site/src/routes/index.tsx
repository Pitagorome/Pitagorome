import { createFileRoute, Link } from "@tanstack/react-router";
import { ArrowRight, Check, Github } from "lucide-react";
import heroEscola from "@/assets/hero-escola.jpg";
import { Button } from "@/components/ui/button";
import { Prop, Sprite, TileFill } from "@/components/site/Pixel";
import { DialogueBox } from "@/components/site/DialogueBox";
import { CommitList } from "@/components/site/CommitList";
import { SectionTitle } from "@/components/site/PageHero";
import { Reveal } from "@/components/site/Reveal";
import { Lousa } from "@/components/site/Lousa";
import { CharacterCarousel } from "@/components/site/CharacterCarousel";
import {
  FEATURES,
  GALLERY,
  INTRO_DIALOGUE,
  MATH_TOPICS,
  REPO_URL,
  STATS,
  sprites,
  tiles,
} from "@/lib/game-content";
import { getRepoActivity } from "@/lib/github.functions";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "Pitagorome · Aprenda matemática administrando sua escola" },
      {
        name: "description",
        content:
          "Você é o novo diretor da Escola Pitagorome. Explore a escola, converse com os personagens e resolva cada problema com matemática.",
      },
      { property: "og:title", content: "Pitagorome · Aprenda matemática administrando sua escola" },
      {
        property: "og:description",
        content:
          "Jogo educativo em pixel art feito no IFSP: organize a escola e resolva desafios de matemática.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  loader: () => getRepoActivity({ data: { limit: 3 } }),
  staleTime: 5 * 60_000,
  component: Index,
});

function Index() {
  return (
    <>
      <Hero />
      <Stats />
      <Intro />
      <Features />
      <Showcase />
      <Characters />
      <Topics />
      <Devlog />
      <Cta />
    </>
  );
}

function Hero() {
  return (
    <section className="relative flex min-h-[92vh] items-center overflow-hidden">
      <img
        src={heroEscola}
        alt="A Escola Pitagorome em pixel art, com alunos chegando pelo portão"
        className="pixelated absolute inset-0 h-full w-full object-cover object-[70%_50%]"
        width={1920}
        height={1080}
      />
      <div
        className="absolute inset-0 hidden md:block"
        style={{ background: "var(--gradient-hero)" }}
      />
      <div
        className="absolute inset-0 md:hidden"
        style={{ background: "var(--gradient-hero-mobile)" }}
      />

      <div className="relative mx-auto w-full max-w-6xl px-6 pt-28">
        <div className="max-w-2xl">
          <p className="hud inline-flex items-center gap-2 px-3 py-1.5 text-sm">
            <span className="h-2 w-2 rounded-full bg-grass" /> Fase 1 jogável · feito no IFSP
          </p>
          <h1 className="mt-6 text-4xl leading-[1.05] sm:text-5xl text-primary-foreground [text-shadow:0_3px_0_var(--sky-deep)] md:text-6xl">
            Um dia de cada vez. Um problema por vez.
          </h1>
          <p className="mt-6 max-w-md text-lg text-primary-foreground/90">
            Você é o novo diretor da Escola Pitagorome. Organize a rotina, ouça os conflitos e
            resolva tudo com matemática.
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Button asChild variant="game" size="lg">
              <Link to="/o-jogo">
                Conhecer o jogo <ArrowRight />
              </Link>
            </Button>
            <Button asChild variant="glass" size="lg">
              <a href={REPO_URL} target="_blank" rel="noreferrer">
                <Github /> Ver no GitHub
              </a>
            </Button>
          </div>
        </div>
      </div>

      {/* Floating HUD chips, like the in-game task tracker */}
      <div className="pointer-events-none absolute right-[8%] top-[30%] hidden lg:block">
        <div className="hud animate-bob px-4 py-2.5 shadow-float">
          <p className="text-xs text-ink-foreground/70">Fase 1 · Tarefa 2</p>
          <p className="flex items-center gap-2 font-semibold">
            <Check className="h-4 w-4 text-grass" /> Conflito no Horário
          </p>
        </div>
      </div>
      <div
        className="pointer-events-none absolute bottom-[26%] right-[30%] hidden lg:block"
        style={{ animationDelay: "1.2s" }}
      >
        <div className="hud animate-bob px-4 py-2.5 shadow-float [animation-delay:1.5s]">
          <p className="font-semibold text-accent">Diretor: você</p>
        </div>
      </div>

      {/* The director runs past the school */}
      <div className="pointer-events-none absolute bottom-2 left-0 animate-walk-across">
        <Sprite sheet={sprites.adamRun} scale={3} mode="run" />
      </div>
    </section>
  );
}

function Stats() {
  return (
    <section className="border-b-4 border-panel-border bg-card py-11">
      <Reveal className="mx-auto max-w-6xl px-6">
        <div className="stagger flex justify-center gap-[clamp(24px,7vw,90px)] text-center text-muted-foreground">
          {STATS.map((s) => (
            <div key={s.label}>
              <b className="block font-display text-5xl leading-none text-foreground">{s.value}</b>
              {s.label}
            </div>
          ))}
        </div>
        <div className="stagger mt-7 flex flex-wrap items-center justify-center gap-2">
          <span className="mr-2 text-xs font-bold uppercase tracking-widest text-muted-foreground">
            Conteúdos de matemática
          </span>
          {MATH_TOPICS.map((t) => (
            <span
              key={t}
              className="rounded-full border-2 border-panel-border/30 bg-secondary px-3.5 py-1.5 text-sm font-medium text-secondary-foreground transition-[background-color,transform] hover:-translate-y-0.5 hover:bg-accent"
            >
              {t}
            </span>
          ))}
        </div>
      </Reveal>
    </section>
  );
}

function Intro() {
  return (
    <section className="relative overflow-hidden">
      <TileFill src={tiles.pisosMadeiraClara} w={16} h={16} scale={4} className="py-20 md:py-28">
        <div className="mx-auto grid max-w-6xl items-end gap-8 px-6 md:grid-cols-[auto_1fr]">
          <div className="flex items-end justify-center gap-2">
            <Sprite sheet={sprites.ameliaIdle} scale={6} label="Coordenadora" />
            <Sprite
              sheet={sprites.bobIdle}
              scale={5}
              label="Professor de Matemática"
              className="hidden sm:block"
            />
          </div>
          <div>
            <p className="hud mb-4 inline-block px-3 py-1.5 font-display text-sm">
              Primeiro dia na diretoria
            </p>
            <DialogueBox lines={INTRO_DIALOGUE} />
          </div>
        </div>
      </TileFill>
    </section>
  );
}

function Features() {
  return (
    <section className="mx-auto max-w-6xl px-6 py-24">
      <Reveal>
        <SectionTitle eyebrow="Como funciona" title="Matemática que acontece na diretoria">
          A matemática não vem em lista de exercícios. Ela aparece como problema real: um horário
          duplicado, um cadeado sem senha, uma excursão para organizar.
        </SectionTitle>
      </Reveal>
      <Reveal className="stagger mt-12 grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
        {FEATURES.map((f) => (
          <article key={f.title} className="panel flex flex-col p-6">
            <div className="flex h-24 items-end">
              <Prop name={f.prop} scale={4} />
            </div>
            <h3 className="mt-5 text-xl text-card-foreground">{f.title}</h3>
            <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{f.text}</p>
          </article>
        ))}
      </Reveal>
    </section>
  );
}

function Showcase() {
  const [first, ...rest] = GALLERY;
  const main = GALLERY.find((g) => g.title === "Primeira conversa") ?? first;
  const side = rest.filter((g) => g !== main && g.title !== "Elenco").slice(0, 2);
  if (!main) return null;
  return (
    <section className="bg-ink py-24 text-ink-foreground">
      <div className="mx-auto max-w-6xl px-6">
        <div className="flex flex-wrap items-end justify-between gap-6">
          <div className="max-w-xl">
            <p className="font-display text-sm uppercase tracking-[0.2em] text-accent">
              Direto do jogo
            </p>
            <h2 className="mt-2 text-3xl md:text-5xl">Cada sala esconde um problema</h2>
          </div>
          <Button asChild variant="game">
            <Link to="/galeria">Ver galeria</Link>
          </Button>
        </div>
        <Reveal className="mt-12 grid items-start gap-6 lg:grid-cols-[1.6fr_1fr]">
          <figure className="overflow-hidden rounded-2xl border-4 border-panel-border shadow-pixel-lg">
            <img
              src={main.src}
              alt={main.text}
              className="pixelated w-full"
              loading="lazy"
              width={1227}
              height={679}
            />
          </figure>
          <div className="grid gap-6">
            {side.map((g) => (
              <figure
                key={g.title}
                className="overflow-hidden rounded-2xl border-4 border-panel-border"
              >
                <img
                  src={g.src}
                  alt={g.text}
                  className="pixelated w-full"
                  loading="lazy"
                  width={1229}
                  height={676}
                />
              </figure>
            ))}
          </div>
        </Reveal>
      </div>
    </section>
  );
}

function Characters() {
  return (
    <section className="relative">
      <TileFill src={tiles.pisosTaco} w={48} h={32} scale={3} className="py-24">
        <div className="mx-auto max-w-6xl px-6">
          <Reveal className="panel inline-block max-w-2xl p-6 md:p-8">
            <p className="font-display text-sm uppercase tracking-[0.2em] text-highlight">
              A Escola Pitagorome
            </p>
            <h2 className="mt-2 text-3xl text-card-foreground md:text-4xl">
              Conheça quem trabalha (e quem estuda) por aqui
            </h2>
            <p className="mt-3 text-muted-foreground">
              O diretor nunca parou em um emprego. Aceitou o cargo pelo café grátis, e o antigo
              diretor havia desistido após três dias.
            </p>
            <Button asChild variant="panel" className="mt-5">
              <Link to="/personagens">
                Todos os personagens <ArrowRight />
              </Link>
            </Button>
          </Reveal>
          <Reveal className="mt-8">
            <CharacterCarousel />
          </Reveal>
        </div>
      </TileFill>
    </section>
  );
}

function Topics() {
  return (
    <section className="bg-card py-24">
      <div className="mx-auto max-w-6xl px-6 text-center">
        <Reveal as="h2" className="mx-auto max-w-2xl text-3xl text-card-foreground md:text-5xl">
          Matemática em toda parte
        </Reveal>
        <Reveal as="p" className="mx-auto mt-4 max-w-2xl text-lg text-muted-foreground">
          Das salas de aula ao refeitório, cada canto da escola esconde um problema. Escolha um
          conteúdo e veja onde ele aparece no jogo.
        </Reveal>
        <Reveal>
          <Lousa />
        </Reveal>
      </div>
    </section>
  );
}

function Devlog() {
  return (
    <section className="mx-auto max-w-6xl px-6 py-24">
      <Reveal className="grid gap-10 md:grid-cols-[1fr_1.4fr]">
        <div>
          <SectionTitle eyebrow="Diário de desenvolvimento" title="Fresquinho do repositório">
            As últimas mudanças da equipe, direto do GitHub do Pitagorome.
          </SectionTitle>
          <Button asChild variant="panel" className="mt-8">
            <Link to="/novidades">
              Todas as novidades <ArrowRight />
            </Link>
          </Button>
        </div>
        <LatestCommits />
      </Reveal>
    </section>
  );
}

function LatestCommits() {
  const data = Route.useLoaderData();
  if (data.error || data.commits.length === 0) {
    return (
      <p className="panel p-6 text-muted-foreground">{data.error ?? "Nenhuma novidade ainda."}</p>
    );
  }
  return <CommitList commits={data.commits} />;
}

function Cta() {
  return (
    <Reveal as="section" className="mx-auto max-w-6xl px-6">
      <div className="panel relative overflow-hidden bg-accent p-10 md:p-14">
        <div className="relative z-10 max-w-xl">
          <h2 className="text-3xl text-accent-foreground md:text-5xl">
            A escola precisa de um diretor.
          </h2>
          <p className="mt-4 text-lg text-accent-foreground/80">
            O último desistiu depois de três dias. Será que você aguenta um trimestre inteiro?
          </p>
          <div className="mt-8 flex flex-wrap gap-3">
            <Button asChild variant="panel" size="lg">
              <Link to="/o-jogo">Ver as fases</Link>
            </Button>
            <Button asChild variant="cream" size="lg">
              <a href={REPO_URL} target="_blank" rel="noreferrer">
                <Github /> Baixar no GitHub
              </a>
            </Button>
          </div>
        </div>
        <div className="pointer-events-none absolute -bottom-2 right-6 hidden items-end gap-3 md:flex">
          <Prop name="teacherDesk" scale={4} />
          <Sprite sheet={sprites.adamIdle} scale={6} />
          <Prop name="plantPalm" scale={5} />
        </div>
      </div>
    </Reveal>
  );
}
