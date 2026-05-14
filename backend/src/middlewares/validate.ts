import type { RequestHandler } from "express";
import type { ZodType } from "zod";

type Fonte = "body" | "params" | "query";

export function validate<T>(schema: ZodType<T>, fonte: Fonte = "body"): RequestHandler {
  return (req, res, next) => {
    const resultado = schema.safeParse(req[fonte]);
    if (!resultado.success) {
      res.status(400).json({
        erro: "VALIDATION_ERROR",
        mensagem: "Dados inválidos",
        detalhes: resultado.error.flatten().fieldErrors,
      });
      return;
    }

    req[fonte] = resultado.data as never;
    next();
  };
}
