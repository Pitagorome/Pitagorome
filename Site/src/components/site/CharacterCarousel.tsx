import { useRef } from "react";
import { ChevronLeft, ChevronRight } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Sprite } from "@/components/site/Pixel";
import { CHARACTERS } from "@/lib/game-content";

/** Carrossel de personagens com rolagem e botões (do site "cofounder"), com os sprites do jogo. */
export function CharacterCarousel() {
  const rail = useRef<HTMLUListElement>(null);
  const move = (d: number) => rail.current?.scrollBy({ left: d * 300, behavior: "smooth" });

  return (
    <div>
      <div className="mb-4 flex justify-end gap-2">
        <Button variant="panel" size="icon" onClick={() => move(-1)} aria-label="Anterior">
          <ChevronLeft />
        </Button>
        <Button variant="panel" size="icon" onClick={() => move(1)} aria-label="Próximo">
          <ChevronRight />
        </Button>
      </div>
      <ul
        ref={rail}
        tabIndex={0}
        aria-label="Personagens"
        className="rail stagger -mx-2 flex gap-5 overflow-x-auto px-2 pb-6 pt-2"
      >
        {CHARACTERS.map((c, i) => (
          <li
            key={c.name}
            className="panel group flex w-[270px] shrink-0 flex-col p-4 transition-transform hover:-translate-y-1"
          >
            <div className="flex h-40 items-end justify-center rounded-lg bg-secondary/60 pb-2">
              {c.sheet ? (
                <Sprite
                  sheet={c.sheet}
                  scale={4}
                  label={c.name}
                  className="transition-transform group-hover:-translate-y-1.5"
                />
              ) : (
                <span className="mb-10 font-display text-5xl text-secondary-foreground/40">?</span>
              )}
            </div>
            <p className="mt-4 text-xs font-bold uppercase tracking-widest text-highlight">
              Personagem {String(i + 1).padStart(2, "0")} · {c.role}
            </p>
            <h3 className="mt-1 text-xl text-card-foreground">{c.name}</h3>
            <p className="mt-1.5 text-sm leading-relaxed text-muted-foreground">{c.text}</p>
          </li>
        ))}
      </ul>
    </div>
  );
}
