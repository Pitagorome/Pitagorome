import { useEffect, useRef, useState, type ElementType, type ReactNode } from "react";
import { cn } from "@/lib/utils";

/**
 * Anima a entrada do bloco quando ele aparece na tela (do site "cofounder").
 * Uso: <Reveal className="grid ...">...</Reveal>. Filhos de um elemento com a classe
 * "stagger" entram um depois do outro.
 */
export function Reveal({
  as: Tag = "div",
  className,
  children,
  ...rest
}: {
  as?: ElementType;
  className?: string;
  children?: ReactNode;
  id?: string;
}) {
  const ref = useRef<HTMLElement>(null);
  const [on, setOn] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el || typeof IntersectionObserver === "undefined") {
      setOn(true);
      return;
    }
    const io = new IntersectionObserver(
      ([e]) => {
        if (e?.isIntersecting) {
          setOn(true);
          io.disconnect();
        }
      },
      { threshold: 0.12 },
    );
    io.observe(el);
    return () => io.disconnect();
  }, []);
  return (
    <Tag ref={ref} className={cn("rv", on && "in", className)} {...rest}>
      {children}
    </Tag>
  );
}
