/**
 * "O Cofre da Escola" (Fase 1, Tarefa 3) — clues from data/dialogues/fase1_dialogues.gd:
 * 3 digits, first is even, sum is 12, no repeated digit, ascending order,
 * every digit is even, none is zero.
 */
export type CofreResult = { ok: boolean; broken: string[] };

export function checkCofre(digits: number[]): CofreResult {
  const broken: string[] = [];
  if (digits.length !== 3 || digits.some((d) => !Number.isInteger(d) || d < 0 || d > 9)) {
    return { ok: false, broken: ["O cadeado tem exatamente 3 dígitos."] };
  }
  const [a = 0, b = 0, c = 0] = digits;
  if (a % 2 !== 0) broken.push("O primeiro número precisa ser par.");
  if (a + b + c !== 12) broken.push(`A soma dos três precisa dar 12 (deu ${a + b + c}).`);
  if (new Set(digits).size !== 3) broken.push("Nenhum dígito pode se repetir.");
  if (!(a < b && b < c)) broken.push("Os dígitos precisam estar em ordem crescente.");
  if (digits.some((d) => d % 2 !== 0)) broken.push("Todos os dígitos eram pares.");
  if (digits.includes(0)) broken.push("Nenhum dígito era zero.");
  return { ok: broken.length === 0, broken };
}

/**
 * "O Troféu Desaparecido" (Fase 2, Tarefa 6): o bilhete do Zelador pede para resolver
 * 2x + 6 = 36 e diminuir 3 de x. O troféu está no armário 12.
 */
export const ARMARIO_CERTO = (36 - 6) / 2 - 3;

export function checkArmario(n: number): { ok: boolean; message: string } {
  if (!Number.isFinite(n)) return { ok: false, message: "Digite o número de um armário." };
  return n === ARMARIO_CERTO
    ? {
        ok: true,
        message: `Armário ${n} aberto. Achou o troféu! (2x + 6 = 36, x = 15, 15 − 3 = 12)`,
      }
    : { ok: false, message: `O armário ${n} está vazio. Tente resolver a equação primeiro.` };
}

/** "A Máquina de Refrigerante" (Fase 3, Tarefa 11): o preço segue a função afim y = 3x + 3. */
export const precoMaquina = (latas: number) => 3 * latas + 3;
