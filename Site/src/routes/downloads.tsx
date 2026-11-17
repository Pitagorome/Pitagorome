import { createFileRoute } from "@tanstack/react-router";
import { PageHero } from "@/components/site/PageHero";
import { Downloads } from "@/components/site/Downloads";
import { Reveal } from "@/components/site/Reveal";
import { TileFill } from "@/components/site/Pixel";
import { tiles } from "@/lib/game-content";

export const Route = createFileRoute("/downloads")({
  head: () => ({
    meta: [
      { title: "Downloads · Pitagorome" },
      {
        name: "description",
        content:
          "Versões do Pitagorome para jogar no navegador ou no computador (Windows, macOS e Linux).",
      },
      { property: "og:title", content: "Baixe o Pitagorome" },
      { property: "og:description", content: "Leve a Escola Pitagorome com você." },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: DownloadsPage,
});

function DownloadsPage() {
  return (
    <>
      <PageHero eyebrow="Downloads" title="Leve a escola com você">
        Versões do jogo para jogar no navegador ou no computador.
      </PageHero>
      <section className="relative">
        <TileFill src={tiles.pisosMadeiraClara} w={16} h={16} scale={4} className="py-24">
          <Reveal className="mx-auto max-w-6xl px-6">
            <Downloads />
          </Reveal>
        </TileFill>
      </section>
    </>
  );
}
