import { Link } from "@tanstack/react-router";
import { sprites, tiles } from "@/assets/game";
import logo from "@/assets/logo.png";
import { Prop, Sprite, TileFill } from "@/components/site/Pixel";
import { REPO_URL } from "@/lib/game-content";

export function SiteFooter() {
  return (
    <footer className="relative mt-24">
      {/* The school's front lawn and sidewalk, built from the game's own tiles */}
      <div className="relative">
        <TileFill src={tiles.exteriorGrama} w={16} h={16} scale={4} className="h-28" />
        <div className="pointer-events-none absolute inset-x-0 bottom-0 mx-auto flex max-w-6xl items-end justify-between px-6">
          <Prop name="plantPalm" scale={4} />
          <Prop name="studentDesk" scale={4} className="hidden sm:block" />
          <Sprite sheet={sprites.adamIdle} scale={4} />
          <Prop name="lockers" scale={4} className="hidden sm:block" />
          <Prop name="plantFicus" scale={4} />
        </div>
      </div>
      <TileFill src={tiles.exteriorCalcada} w={16} h={16} scale={4} className="h-16" />

      <div className="bg-ink text-ink-foreground">
        <div className="mx-auto grid max-w-6xl gap-10 px-6 py-14 md:grid-cols-[1.4fr_1fr_1fr]">
          <div className="space-y-4">
            <img src={logo} alt="Pitagorome" className="h-10 w-auto" width={520} height={84} loading="lazy" />
            <p className="max-w-sm text-sm text-ink-foreground/75">
              Jogo educativo de matemática e administração escolar. Projeto do Instituto Federal de
              São Paulo, Campus São Paulo.
            </p>
          </div>
          <div>
            <p className="font-display text-accent">O jogo</p>
            <ul className="mt-3 space-y-2 text-sm text-ink-foreground/80">
              <li>
                <Link to="/o-jogo" className="hover:text-accent">
                  Como se joga
                </Link>
              </li>
              <li>
                <Link to="/personagens" className="hover:text-accent">
                  Personagens
                </Link>
              </li>
              <li>
                <Link to="/galeria" className="hover:text-accent">
                  Galeria
                </Link>
              </li>
              <li>
                <Link to="/downloads" className="hover:text-accent">
                  Downloads
                </Link>
              </li>
            </ul>
          </div>
          <div>
            <p className="font-display text-accent">Projeto</p>
            <ul className="mt-3 space-y-2 text-sm text-ink-foreground/80">
              <li>
                <Link to="/novidades" className="hover:text-accent">
                  Novidades
                </Link>
              </li>
              <li>
                <Link to="/equipe" className="hover:text-accent">
                  Equipe
                </Link>
              </li>
              <li>
                <a href={REPO_URL} target="_blank" rel="noreferrer" className="hover:text-accent">
                  GitHub
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="border-t border-ink-foreground/10">
          <p className="mx-auto max-w-6xl px-6 py-5 text-xs text-ink-foreground/55">
            Desenvolvido por Ana Julia, Eduardo, Guilherme e João Paulo · IFSP, 2026 · Tiles e
            personagens: Modern Interiors/Exteriors por LimeZu (uso não comercial).
          </p>
        </div>
      </div>
    </footer>
  );
}
