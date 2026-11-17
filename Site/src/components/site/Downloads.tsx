import { Download, Github, Play } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Prop } from "@/components/site/Pixel";
import { DOWNLOADS, DOWNLOADS_SOON, REPO_URL } from "@/lib/game-content";

/** Lista de downloads. Com DOWNLOADS_SOON = true, os cartões ficam inativos sob o aviso "Em breve". */
export function Downloads() {
  const locked = DOWNLOADS_SOON;
  return (
    <div className="relative">
      <div
        className="stagger grid gap-6 sm:grid-cols-2 lg:grid-cols-4"
        {...(locked ? { inert: true, "aria-hidden": true } : {})}
      >
        {DOWNLOADS.map((d) => (
          <article key={d.name} className="panel flex flex-col items-start p-6">
            <div className="flex h-24 items-end">
              <Prop name={d.prop} scale={3} />
            </div>
            <p className="mt-5 text-xs font-bold uppercase tracking-widest text-highlight">
              {d.tag}
            </p>
            <h3 className="mt-1 text-xl text-card-foreground">{d.name}</h3>
            <p className="mt-2 flex-1 text-sm leading-relaxed text-muted-foreground">{d.text}</p>
            {!locked && d.href ? (
              <Button asChild variant="panel" className="mt-5">
                <a
                  href={d.href}
                  {...(d.external ? { target: "_blank", rel: "noreferrer" } : { download: true })}
                >
                  {d.external ? <Play /> : <Download />} {d.action ?? "Baixar"}
                </a>
              </Button>
            ) : (
              <Button variant="panel" className="mt-5" disabled>
                {d.external ? <Play /> : <Download />} {d.action ?? "Baixar"}
              </Button>
            )}
          </article>
        ))}
      </div>

      {locked && (
        <div
          role="status"
          className="absolute -inset-3 flex flex-col items-center justify-center gap-4 rounded-3xl border-[3px] border-dashed border-highlight bg-background/55 p-6 text-center backdrop-blur-[3px]"
        >
          <span className="animate-bob rounded-lg border-[3px] border-panel-border bg-accent px-6 py-2 font-display text-3xl font-bold uppercase tracking-wider text-accent-foreground shadow-pixel md:text-4xl">
            Em breve
          </span>
          <p className="max-w-md font-medium text-foreground">
            Os downloads serão liberados quando o jogo for lançado. Acompanhe o desenvolvimento no
            GitHub.
          </p>
          <Button asChild variant="cream">
            <a href={REPO_URL} target="_blank" rel="noreferrer">
              <Github /> Acompanhar no GitHub
            </a>
          </Button>
        </div>
      )}
    </div>
  );
}
