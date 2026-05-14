import type { ErrorRequestHandler } from "express";
import { ZodError } from "zod";
import { AppError } from "../utils/errors";

export const errorHandler: ErrorRequestHandler = (err, _req, res, _next) => {
  if (err instanceof AppError) {
    res.status(err.status).json({
      erro: err.codigo,
      mensagem: err.message,
      ...(err.detalhes !== undefined ? { detalhes: err.detalhes } : {}),
    });
    return;
  }

  if (err instanceof ZodError) {
    res.status(400).json({
      erro: "VALIDATION_ERROR",
      mensagem: "Dados inválidos",
      detalhes: err.flatten().fieldErrors,
    });
    return;
  }

  const conflito = mapearConflitoPrisma(err);
  if (conflito) {
    res.status(409).json(conflito);
    return;
  }

  console.error("[ERRO NÃO TRATADO]", err);
  res.status(500).json({
    erro: "INTERNAL_ERROR",
    mensagem: "Erro interno do servidor",
  });
};

function mapearConflitoPrisma(err: unknown): { erro: string; mensagem: string } | null {
  if (typeof err !== "object" || err === null) return null;
  const e = err as { code?: unknown; meta?: { target?: unknown } };
  if (e.code !== "P2002") return null;
  const alvo = Array.isArray(e.meta?.target) ? e.meta.target.join(", ") : "campo único";
  return {
    erro: "CONFLICT",
    mensagem: `Já existe um registro com esse ${alvo}`,
  };
}
