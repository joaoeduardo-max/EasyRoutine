import type { RequestHandler } from "express";
import { UnauthorizedError } from "../../utils/errors";
import * as authService from "./auth.service";
import type { RegistrarInput, LoginInput } from "./auth.schemas";

export const registrar: RequestHandler<unknown, unknown, RegistrarInput> = async (
  req,
  res,
) => {
  const resultado = await authService.registrar(req.body);
  res.status(201).json(resultado);
};

export const login: RequestHandler<unknown, unknown, LoginInput> = async (req, res) => {
  const resultado = await authService.login(req.body);
  res.status(200).json(resultado);
};

export const me: RequestHandler = async (req, res) => {
  if (!req.usuario) {

    throw new UnauthorizedError();
  }
  const usuario = await authService.buscarUsuarioPorId(req.usuario.id);
  res.status(200).json({ usuario });
};
