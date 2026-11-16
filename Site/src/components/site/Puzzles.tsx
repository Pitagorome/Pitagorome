import { useState, type FormEvent } from "react";
import { Eye, EyeOff, KeyRound } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Prop } from "@/components/site/Pixel";
import { checkArmario, precoMaquina } from "@/lib/puzzles";
import { cn } from "@/lib/utils";

/** Fase 2, Tarefa 6: o bilhete do Zelador esconde o número do armário (2x + 6 = 36). */
export function ArmarioPuzzle() {
  const [value, setValue] = useState("");
  const [result, setResult] = useState<{ ok: boolean; message: string } | null>(null);

  const submit = (e: FormEvent) => {
    e.preventDefault();
    setResult(checkArmario(value === "" ? Number.NaN : Number(value)));
  };

  return (
    <form onSubmit={submit} className="panel flex flex-col gap-4 p-6" aria-labelledby="puz-armario">
      <div className="flex items-end justify-between gap-4">
        <div>
          <p className="font-display text-sm uppercase tracking-[0.2em] text-highlight">
            Teste um desafio
          </p>
          <h3 id="puz-armario" className="mt-1 text-2xl text-card-foreground">
            O Troféu Desaparecido
          </h3>
        </div>
        <Prop name="lockers" scale={3} />
      </div>
      <p className="text-card-foreground">
        O Zelador deixou um bilhete: resolva <b>2x + 6 = 36</b>, diminua 3 do valor de x e procure o
        armário com esse número.
      </p>
      <label htmlFor="armario" className="font-semibold text-card-foreground">
        Número do armário
      </label>
      <div className="flex flex-wrap gap-3">
        <input
          id="armario"
          type="number"
          inputMode="numeric"
          min={0}
          max={99}
          value={value}
          onChange={(e) => {
            setValue(e.target.value);
            setResult(null);
          }}
          className="w-28 rounded-lg border-[3px] border-panel-border bg-background px-4 py-2 font-display text-2xl text-card-foreground focus:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        />
        <Button type="submit" variant="game" size="lg">
          <KeyRound /> Abrir
        </Button>
      </div>
      <p
        aria-live="polite"
        className={cn("min-h-12 font-semibold", result?.ok ? "text-success" : "text-destructive")}
      >
        {result?.message}
      </p>
    </form>
  );
}

/** Fase 3, Tarefa 11: a máquina cobra segundo uma função afim (y = 3x + 3). */
export function MaquinaPuzzle() {
  const [open, setOpen] = useState(false);
  const rows = [2, 4, 6];
  return (
    <div className="panel flex flex-col gap-4 p-6">
      <div className="flex items-end justify-between gap-4">
        <div>
          <p className="font-display text-sm uppercase tracking-[0.2em] text-highlight">
            Teste um desafio
          </p>
          <h3 className="mt-1 text-2xl text-card-foreground">A Máquina de Refrigerante</h3>
        </div>
        <Prop name="locker" scale={3} />
      </div>
      <p className="text-card-foreground">
        A máquina cobra de um jeito estranho. Os registros do técnico:
      </p>
      <table className="w-full border-collapse text-card-foreground">
        <tbody>
          {rows.map((n, idx) => (
            <tr key={n} className="border-b-2 border-border">
              <td className="py-2.5">{n} refrigerantes</td>
              <td className="py-2.5 text-right font-display text-lg">
                {idx < rows.length - 1 || open ? `R$ ${precoMaquina(n)}` : "?"}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
      <div>
        <Button variant="game" size="lg" onClick={() => setOpen((o) => !o)} aria-expanded={open}>
          {open ? <EyeOff /> : <Eye />} {open ? "Esconder resposta" : "Descobrir o preço de 6"}
        </Button>
      </div>
      <p aria-live="polite" className="min-h-6 font-semibold text-success">
        {open ? "A função é y = 3x + 3." : ""}
      </p>
    </div>
  );
}
