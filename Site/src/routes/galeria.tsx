import { useState } from "react";
import { createFileRoute } from "@tanstack/react-router";
import { Dialog, DialogContent, DialogDescription, DialogTitle } from "@/components/ui/dialog";
import { PageHero } from "@/components/site/PageHero";
import { Reveal } from "@/components/site/Reveal";
import { GALLERY } from "@/lib/game-content";

export const Route = createFileRoute("/galeria")({
  head: () => ({
    meta: [
      { title: "Galeria · Pitagorome" },
      {
        name: "description",
        content:
          "Capturas de tela do Pitagorome: o corredor, a diretoria, a criação de personagem e os desafios.",
      },
      { property: "og:title", content: "Galeria do Pitagorome" },
      {
        property: "og:description",
        content: "Veja a Escola Pitagorome em pixel art, direto do jogo.",
      },
      { property: "og:type", content: "website" },
      { name: "twitter:card", content: "summary_large_image" },
    ],
  }),
  component: GalleryPage,
});

function GalleryPage() {
  const [open, setOpen] = useState<number | null>(null);
  const item = open === null ? null : GALLERY[open];
  return (
    <>
      <PageHero eyebrow="Galeria" title="A escola, quadro a quadro">
        Capturas reais do jogo em desenvolvimento. Clique em uma imagem para ampliar.
      </PageHero>
      <section className="mx-auto max-w-6xl px-6 py-24">
        <Reveal className="stagger grid gap-8 md:grid-cols-2">
          {GALLERY.map((g, i) => (
            <button
              key={g.title}
              type="button"
              onClick={() => setOpen(i)}
              className={`group text-left ${i === 0 ? "md:col-span-2" : ""}`}
            >
              <figure className="overflow-hidden rounded-2xl border-4 border-panel-border shadow-pixel transition-transform group-hover:-translate-y-1">
                <img src={g.src} alt={g.text} className="pixelated w-full" loading="lazy" />
              </figure>
              <p className="mt-4 font-display text-xl">{g.title}</p>
              <p className="text-sm text-muted-foreground">{g.text}</p>
            </button>
          ))}
        </Reveal>
      </section>
      <Dialog open={item !== null} onOpenChange={(o) => !o && setOpen(null)}>
        <DialogContent className="max-w-5xl border-4 border-panel-border bg-card p-3">
          {item && (
            <>
              <DialogTitle className="px-2 pt-1 font-display">{item.title}</DialogTitle>
              <DialogDescription className="px-2">{item.text}</DialogDescription>
              <img src={item.src} alt={item.text} className="pixelated w-full rounded-lg" />
            </>
          )}
        </DialogContent>
      </Dialog>
    </>
  );
}
