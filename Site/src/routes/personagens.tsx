import { createFileRoute } from "@tanstack/react-router";
import { PageHero, SectionTitle } from "@/components/site/PageHero";
import { Sprite, TileFill } from "@/components/site/Pixel";
import { Reveal } from "@/components/site/Reveal";
import { CHARACTERS, DIRECTOR_LOOKS, shots, tiles } from "@/lib/game-content";

export const Route = createFileRoute("/personagens")({
  head: () => ({
    meta: [
      { title: "Personagens · Pitagorome" },
      {
        name: "description",
        content:
          "Conheça a Coordenadora, o Zelador, o Professor de Matemática e quem mais você encontra na Escola Pitagorome.",
      },
      { property: "og:title", content: "Personagens da Escola Pitagorome" },
      {
        property: "og:description",
        content: "A Coordenadora, o Zelador, o Professor de Matemática e os alunos.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: CharactersPage,
});

function CharactersPage() {
  return (
    <>
      <PageHero eyebrow="Personagens" title="Quem você encontra na escola">
        O diretor nunca parou em um emprego. Foi vendedor, monitor de museu e animador de festa
        vestido de triângulo, até que uma carta chegou: a Escola Pitagorome procurava um novo
        diretor.
      </PageHero>

      <section className="mx-auto grid max-w-6xl items-center gap-12 px-6 py-24 lg:grid-cols-[1fr_1.2fr]">
        <div>
          <SectionTitle eyebrow="A história" title="O anterior desistiu após três dias">
            Ele aceitou pelo café grátis. No portão, dois alunos se acusavam de colar na prova de
            matemática. Foi quando percebeu que talvez o antigo diretor tivesse um ponto.
          </SectionTitle>
        </div>
        <figure className="overflow-hidden rounded-2xl border-4 border-panel-border shadow-pixel-lg">
          <img
            src={shots.escolaConceito}
            alt="A Coordenadora recebe o novo diretor no gabinete"
            className="pixelated w-full"
            width={1227}
            height={679}
          />
        </figure>
      </section>

      <section className="relative">
        <TileFill src={tiles.pisosAzulejoAzul} w={48} h={32} scale={3} className="py-24">
          <div className="mx-auto max-w-6xl px-6">
            <Reveal className="stagger grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {CHARACTERS.map((c) => (
                <article key={c.name} className="panel flex flex-col p-6">
                  <div className="flex h-36 items-end justify-center rounded-lg bg-secondary/60">
                    {c.sheet ? (
                      <Sprite sheet={c.sheet} scale={4} label={c.name} />
                    ) : (
                      <span className="mb-10 font-display text-5xl text-secondary-foreground/40">
                        ?
                      </span>
                    )}
                  </div>
                  <p className="mt-5 text-xs font-bold uppercase tracking-widest text-highlight">
                    {c.role}
                  </p>
                  <h3 className="mt-1 text-2xl text-card-foreground">{c.name}</h3>
                  <p className="mt-2 text-sm leading-relaxed text-muted-foreground">{c.text}</p>
                  {c.quote && (
                    <blockquote className="mt-4 border-l-4 border-accent pl-3 text-sm italic text-card-foreground/80">
                      “{c.quote}”
                    </blockquote>
                  )}
                </article>
              ))}
            </Reveal>
          </div>
        </TileFill>
      </section>

      <section className="mx-auto max-w-6xl px-6 py-24">
        <SectionTitle eyebrow="Você" title="Escolha sua aparência">
          Antes do tour, escolha nome, se é diretor ou diretora e um dos visuais.
        </SectionTitle>
        <Reveal className="stagger mt-12 grid grid-cols-3 gap-4 md:gap-8">
          {DIRECTOR_LOOKS.map((l) => (
            <figure key={l.label} className="panel flex flex-col items-center p-4 md:p-8">
              <img
                src={l.src}
                alt={`Aparência do diretor: ${l.label}`}
                className="pixelated h-32 w-auto md:h-56"
                loading="lazy"
              />
              <figcaption className="mt-4 font-display text-highlight">{l.label}</figcaption>
            </figure>
          ))}
        </Reveal>
      </section>
    </>
  );
}
