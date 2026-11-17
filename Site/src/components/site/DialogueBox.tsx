import { useEffect, useState } from "react";
import type { DialogueLine } from "@/lib/game-content";
import { cn } from "@/lib/utils";

/** The game's dialog box, with the same typewriter reveal and "press to continue" hint. */
export function DialogueBox({ lines, className }: { lines: DialogueLine[]; className?: string }) {
  const [index, setIndex] = useState(0);
  const [shown, setShown] = useState(0);
  const line = lines[index] ?? lines[0] ?? { speaker: "", text: "" };
  const done = shown >= line.text.length;

  useEffect(() => {
    setShown(0);
  }, [index]);

  useEffect(() => {
    if (done) return;
    const t = window.setTimeout(() => setShown((s) => s + 2), 22);
    return () => window.clearTimeout(t);
  }, [shown, done]);

  const advance = () => {
    if (!done) setShown(line.text.length);
    else setIndex((i) => (i + 1) % lines.length);
  };

  return (
    <button
      type="button"
      onClick={advance}
      className={cn("panel block w-full cursor-pointer px-6 py-5 text-left md:px-8 md:py-6", className)}
      aria-label={`${line.speaker}: ${line.text}. Clique para continuar`}
    >
      <span className="block font-sans text-lg font-bold text-highlight md:text-xl">{line.speaker}</span>
      <span className="mt-2 block min-h-[5.5rem] text-base leading-relaxed text-card-foreground md:text-lg">
        {line.text.slice(0, shown)}
        {!done && <span className="animate-caret">▌</span>}
      </span>
      <span className="mt-3 block text-right text-sm text-muted-foreground">
        ▾ Clique para continuar · {index + 1}/{lines.length}
      </span>
    </button>
  );
}
