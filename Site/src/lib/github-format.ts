/** Turns "teste: grade fica vermelha" into a tag + readable text. */
export function describeCommit(message: string): { tag: string; text: string } {
  const m = message.match(/^([\p{L}]+)(\(.+?\))?:\s*(.+)$/u);
  const map: Record<string, string> = {
    feat: "Novidade",
    fix: "Correção",
    teste: "Teste",
    test: "Teste",
    docs: "Docs",
    refactor: "Ajuste",
    style: "Visual",
    chore: "Manutenção",
    correção: "Correção",
    correcao: "Correção",
    funcionalidade: "Novidade",
    melhoria: "Ajuste",
  };
  if (m) {
    const text = m[3] ?? message;
    return {
      tag: map[(m[1] ?? "").toLowerCase()] ?? "Atualização",
      text: text.charAt(0).toUpperCase() + text.slice(1),
    };
  }
  return { tag: "Atualização", text: message };
}

export function formatDate(iso: string) {
  if (!iso) return "";
  return new Date(iso).toLocaleDateString("pt-BR", {
    day: "2-digit",
    month: "short",
    year: "numeric",
    timeZone: "America/Sao_Paulo",
  });
}
