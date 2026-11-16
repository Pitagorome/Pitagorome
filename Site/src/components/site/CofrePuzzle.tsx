import { useState } from "react";
import { Lock, LockOpen, Minus, Plus } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Prop } from "@/components/site/Pixel";
import { checkCofre, type CofreResult } from "@/lib/puzzles";
import { cn } from "@/lib/utils";

const CLUES = [
  "O cadeado tem 3 dígitos. O primeiro número é par e a soma dos três dá 12.",
  "Nenhum dígito se repete e eles estão em ordem crescente.",
  "Ah... e todos eram pares. Nenhum era zero, disso eu tenho certeza.",
];

export function CofrePuzzle() {
  const [digits, setDigits] = useState([1, 1, 1]);
  const [result, setResult] = useState<CofreResult | null>(null);

  const change = (i: number, delta: number) => {
    setResult(null);
    setDigits((d) => d.map((v, j) => (j === i ? (v + delta + 10) % 10 : v)));
  };

  return (
    <div className="grid gap-8 md:grid-cols-[1.1fr_1fr]">
      <div className="space-y-4">
        <p className="font-display text-sm uppercase tracking-widest text-highlight">Pistas do Zelador</p>
        {CLUES.map((c) => (
          <div key={c} className="hud px-4 py-3 text-sm leading-relaxed md:text-base">
            <span className="font-bold text-accent">Zelador: </span>
            {c}
          </div>
        ))}
      </div>

      <div className="panel flex flex-col items-center gap-5 p-6">
        <Prop name="lockers" scale={4} />
        <div className="flex gap-3" role="group" aria-label="Combinação do cadeado">
          {digits.map((d, i) => (
            <div key={i} className="flex flex-col items-center gap-1">
              <Button variant="ghost" size="icon" onClick={() => change(i, 1)} aria-label={`Aumentar dígito ${i + 1}`}>
                <Plus />
              </Button>
              <span className="grid h-16 w-14 place-items-center rounded-lg border-[3px] border-panel-border bg-ink font-display text-4xl text-accent">
                {d}
              </span>
              <Button variant="ghost" size="icon" onClick={() => change(i, -1)} aria-label={`Diminuir dígito ${i + 1}`}>
                <Minus />
              </Button>
            </div>
          ))}
        </div>
        <Button variant="game" size="lg" onClick={() => setResult(checkCofre(digits))}>
          {result?.ok ? <LockOpen /> : <Lock />} Tentar abrir
        </Button>
        <div aria-live="polite" className="min-h-12 w-full text-center text-sm">
          {result?.ok && (
            <p className="font-bold text-success">
              Abriu! “Ugh. Eu sabia que a senha era essa.” — Zelador
            </p>
          )}
          {result && !result.ok && (
            <ul className={cn("space-y-1 text-destructive")}>
              {result.broken.slice(0, 2).map((b) => (
                <li key={b}>✗ {b}</li>
              ))}
            </ul>
          )}
        </div>
      </div>
    </div>
  );
}
