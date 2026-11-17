import { describe, expect, it } from "vitest";
import { checkArmario, checkCofre, precoMaquina } from "./puzzles";

describe("O Cofre da Escola", () => {
  it("opens with 2-4-6", () => {
    expect(checkCofre([2, 4, 6]).ok).toBe(true);
  });
  it("rejects a combination with zero even if the sum is 12", () => {
    expect(checkCofre([0, 4, 8]).ok).toBe(false);
  });
  it("rejects digits out of ascending order", () => {
    expect(checkCofre([6, 4, 2]).ok).toBe(false);
  });
  it("rejects odd digits", () => {
    expect(checkCofre([1, 5, 6]).ok).toBe(false);
  });
  it("rejects repeated digits", () => {
    expect(checkCofre([4, 4, 4]).ok).toBe(false);
  });
});

describe("O Troféu Desaparecido", () => {
  it("opens locker 12", () => {
    expect(checkArmario(12).ok).toBe(true);
  });
  it("keeps locker 15 (x without subtracting 3) closed", () => {
    expect(checkArmario(15).ok).toBe(false);
  });
});

describe("A Máquina de Refrigerante", () => {
  it("matches the technician's records and prices 6 cans at R$ 21", () => {
    expect([2, 4, 6].map(precoMaquina)).toEqual([9, 15, 21]);
  });
});
