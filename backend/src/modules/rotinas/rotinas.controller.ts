import type { RequestHandler } from "express";
import { UnauthorizedError } from "../../utils/errors";
import * as rotinasService from "./rotinas.service";
import type {
  AtualizarRotinaInput,
  CriarRotinaInput,
  IdParam,
  ReordenarInput,
} from "./rotinas.schemas";

function getUsuarioId(req: { usuario?: { id: string } }): string {
  if (!req.usuario) throw new UnauthorizedError();
  return req.usuario.id;
}

export const listar: RequestHandler = async (req, res) => {
  const rotinas = await rotinasService.listar(getUsuarioId(req));
  res.status(200).json(rotinas);
};

export const criar: RequestHandler<unknown, unknown, CriarRotinaInput> = async (
  req,
  res,
) => {
  const criada = await rotinasService.criar(getUsuarioId(req), req.body);
  res.status(201).json(criada);
};

export const detalhes: RequestHandler<IdParam> = async (req, res) => {
  const rotina = await rotinasService.buscarPorIdComTarefas(
    getUsuarioId(req),
    req.params.id,
  );
  res.status(200).json(rotina);
};

export const reordenar: RequestHandler<IdParam, unknown, ReordenarInput> = async (
  req,
  res,
) => {
  const tarefas = await rotinasService.reordenar(
    getUsuarioId(req),
    req.params.id,
    req.body.ordemIds,
  );
  res.status(200).json(tarefas);
};

export const atualizar: RequestHandler<IdParam, unknown, AtualizarRotinaInput> = async (
  req,
  res,
) => {
  const atualizada = await rotinasService.atualizar(
    getUsuarioId(req),
    req.params.id,
    req.body,
  );
  res.status(200).json(atualizada);
};

export const deletar: RequestHandler<IdParam> = async (req, res) => {
  await rotinasService.deletar(getUsuarioId(req), req.params.id);
  res.status(204).send();
};
