import type { RequestHandler } from "express";
import { verificarToken } from "../utils/jwt";
import { UnauthorizedError } from "../utils/errors";

export const authMiddleware: RequestHandler = (req, _res, next) => {
  const header = req.headers["authorization"];
  if (!header || !header.startsWith("Bearer ")) {
    throw new UnauthorizedError("Token não fornecido");
  }

  const token = header.slice("Bearer ".length).trim();
  if (!token) {
    throw new UnauthorizedError("Token não fornecido");
  }

  const payload = verificarToken(token);
  req.usuario = { id: payload.sub };
  next();
};
