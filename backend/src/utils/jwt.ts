import jwt from "jsonwebtoken";
import type { SignOptions } from "jsonwebtoken";
import { env } from "../config/env";
import { UnauthorizedError } from "./errors";

export interface TokenPayload {
  sub: string;
}

export function gerarToken(payload: TokenPayload): string {

  return jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: env.JWT_EXPIRATION,
  } as SignOptions);
}

export function verificarToken(token: string): TokenPayload {
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    if (typeof decoded === "string" || typeof decoded.sub !== "string") {
      throw new UnauthorizedError("Token inválido");
    }
    return { sub: decoded.sub };
  } catch (err) {
    if (err instanceof UnauthorizedError) throw err;
    throw new UnauthorizedError("Token inválido ou expirado");
  }
}
