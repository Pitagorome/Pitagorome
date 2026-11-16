import type { ReactNode } from "react";
import heroEscola from "@/assets/hero-escola.jpg";
import { tiles } from "@/assets/game";
import { TileFill } from "@/components/site/Pixel";

export function PageHero({ eyebrow, title, children }: { eyebrow: string; title: string; children?: ReactNode }) {
  return (
    <section className="relative overflow-hidden">
      <img
        src={heroEscola}
        alt=""
        aria-hidden
        className="pixelated absolute inset-0 h-full w-full object-cover object-[50%_20%]"
        width={1920}
        height={1080}
      />
      <div className="absolute inset-0" style={{ background: "var(--gradient-page)" }} />
      <div className="relative mx-auto max-w-6xl px-6 pb-20 pt-36 md:pb-24 md:pt-44">
        <p className="font-display text-sm uppercase tracking-[0.2em] text-accent">{eyebrow}</p>
        <h1 className="mt-3 max-w-3xl text-4xl text-primary-foreground md:text-6xl">{title}</h1>
        {children && <div className="mt-5 max-w-2xl text-lg text-primary-foreground/85">{children}</div>}
      </div>
      <TileFill src={tiles.exteriorGrama} w={16} h={16} scale={3} className="relative h-6" />
    </section>
  );
}

export function SectionTitle({ eyebrow, title, children }: { eyebrow?: string; title: string; children?: ReactNode }) {
  return (
    <div className="max-w-2xl">
      {eyebrow && <p className="font-display text-sm uppercase tracking-[0.2em] text-highlight">{eyebrow}</p>}
      <h2 className="mt-2 text-3xl text-foreground md:text-5xl">{title}</h2>
      {children && <p className="mt-4 text-lg text-muted-foreground">{children}</p>}
    </div>
  );
}
