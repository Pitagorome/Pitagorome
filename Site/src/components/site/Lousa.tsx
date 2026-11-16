import { useEffect, useState, type CSSProperties } from "react";
import { QUADRO } from "@/lib/game-content";
import { cn } from "@/lib/utils";

/**
 * Lousa (quadro-negro) interativa, mantida do site "cofounder": escolha um conteúdo e a fórmula
 * é "escrita" no quadro. Troca sozinha a cada 5,5 s até o visitante clicar; pausa com o mouse ou o
 * foco em cima.
 */
export function Lousa() {
  const [i, setI] = useState(0);
  const [auto, setAuto] = useState(true);
  const [pausa, setPausa] = useState(false);

  useEffect(() => {
    if (window.matchMedia?.("(prefers-reduced-motion: reduce)").matches) setAuto(false);
  }, []);

  useEffect(() => {
    if (!auto || pausa) return;
    const t = window.setTimeout(() => setI((x) => (x + 1) % QUADRO.length), 5500);
    return () => window.clearTimeout(t);
  }, [i, auto, pausa]);

  const q = QUADRO[i] ?? QUADRO[0]!;
  return (
    <div
      className="qd"
      onMouseEnter={() => setPausa(true)}
      onMouseLeave={() => setPausa(false)}
      onFocus={() => setPausa(true)}
      onBlur={() => setPausa(false)}
    >
      <div className="qd__tabs" role="tablist" aria-label="Conteúdos de matemática">
        {QUADRO.map((t, n) => (
          <button
            key={t.topico}
            type="button"
            role="tab"
            id={`qt${n}`}
            aria-selected={n === i}
            aria-controls="qpanel"
            className={cn("qd__tab", n === i && "on")}
            onClick={() => {
              setI(n);
              setAuto(false);
            }}
          >
            {t.topico}
            {n === i && auto && !pausa && <span className="qd__prog" key={i} />}
          </button>
        ))}
      </div>
      <div
        className="qd__board"
        id="qpanel"
        role="tabpanel"
        aria-labelledby={`qt${i}`}
        aria-live={auto ? "off" : "polite"}
      >
        <div className="qd__frame">
          <small>{q.topico}</small>
          <div key={i} className="chalk" style={{ "--n": q.formula.length } as CSSProperties}>
            {q.formula}
          </div>
          <p key={`p${i}`}>{q.desc}</p>
          <ul key={`l${i}`}>
            {q.tasks.map((t) => (
              <li key={t}>{t}</li>
            ))}
          </ul>
        </div>
        <div className="qd__tray" aria-hidden="true">
          <i />
          <i />
          <b />
        </div>
      </div>
    </div>
  );
}
