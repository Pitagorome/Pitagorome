import { useEffect, useRef, useState } from "react";
import { Link } from "@tanstack/react-router";
import { Github, Menu, X } from "lucide-react";
import logo from "@/assets/logo.png";
import { Button } from "@/components/ui/button";
import { REPO_URL } from "@/lib/game-content";
import { cn } from "@/lib/utils";

const NAV = [
  { to: "/o-jogo", label: "O Jogo" },
  { to: "/personagens", label: "Personagens" },
  { to: "/galeria", label: "Galeria" },
  { to: "/novidades", label: "Novidades" },
  { to: "/downloads", label: "Downloads" },
  { to: "/equipe", label: "Equipe" },
] as const;

export function SiteHeader() {
  const [open, setOpen] = useState(false);
  const [compact, setCompact] = useState(false);
  const bar = useRef<HTMLDivElement>(null);

  // Barra de progresso da rolagem e cabeçalho compacto ao rolar (do site "cofounder").
  useEffect(() => {
    let raf = 0;
    const onScroll = () => {
      cancelAnimationFrame(raf);
      raf = requestAnimationFrame(() => {
        const h = document.documentElement;
        const max = Math.max(1, h.scrollHeight - window.innerHeight);
        if (bar.current) bar.current.style.transform = `scaleX(${Math.min(1, h.scrollTop / max)})`;
        setCompact(h.scrollTop > 40);
      });
    };
    onScroll();
    window.addEventListener("scroll", onScroll, { passive: true });
    window.addEventListener("resize", onScroll);
    return () => {
      window.removeEventListener("scroll", onScroll);
      window.removeEventListener("resize", onScroll);
      cancelAnimationFrame(raf);
    };
  }, []);

  return (
    <>
      <div ref={bar} className="scroll-bar" aria-hidden="true" />
      <header
        className={cn(
          "fixed inset-x-0 top-0 z-50 transition-[background-color,box-shadow,backdrop-filter] duration-300",
          (compact || open) && "bg-ink/85 shadow-float backdrop-blur-md",
        )}
      >
        <div
          className={cn(
            "mx-auto flex max-w-6xl items-center justify-between gap-4 px-5 transition-[padding] duration-300",
            compact ? "py-2.5" : "py-5",
          )}
        >
          <Link to="/" className="shrink-0" aria-label="Pitagorome, início">
            <img
              src={logo}
              alt="Pitagorome"
              className={cn(
                "w-auto transition-[height] duration-300",
                compact ? "h-8 md:h-9" : "h-9 md:h-11",
              )}
              width={520}
              height={84}
            />
          </Link>

          <nav
            className="glass hidden items-center gap-1 rounded-xl p-1 lg:flex"
            aria-label="Principal"
          >
            {NAV.map((n) => (
              <Link
                key={n.to}
                to={n.to}
                className="rounded-lg px-3 py-2 text-sm font-medium text-primary-foreground/85 transition-colors hover:bg-primary-foreground/10 hover:text-primary-foreground"
                activeProps={{ className: "bg-primary-foreground/15 text-primary-foreground" }}
              >
                {n.label}
              </Link>
            ))}
          </nav>

          <div className="flex items-center gap-2">
            <Button asChild variant="cream" className="hidden lg:inline-flex">
              <a href={REPO_URL} target="_blank" rel="noreferrer">
                <Github /> GitHub
              </a>
            </Button>
            <Button
              variant="glass"
              size="icon"
              className="lg:hidden"
              onClick={() => setOpen((o) => !o)}
              aria-expanded={open}
              aria-label="Abrir menu"
            >
              {open ? <X /> : <Menu />}
            </Button>
          </div>
        </div>

        <nav
          className={cn(
            "glass mx-5 mb-3 flex-col gap-1 rounded-xl p-2 lg:hidden",
            open ? "flex" : "hidden",
          )}
          aria-label="Principal (celular)"
        >
          {NAV.map((n) => (
            <Link
              key={n.to}
              to={n.to}
              onClick={() => setOpen(false)}
              className="rounded-lg px-4 py-3 font-medium text-primary-foreground hover:bg-primary-foreground/10"
            >
              {n.label}
            </Link>
          ))}
          <a
            href={REPO_URL}
            target="_blank"
            rel="noreferrer"
            className="rounded-lg px-4 py-3 font-medium text-primary-foreground hover:bg-primary-foreground/10"
          >
            GitHub
          </a>
        </nav>
      </header>
    </>
  );
}
