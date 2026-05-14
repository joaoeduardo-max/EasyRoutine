import type { RequestHandler } from "express";
import { UnauthorizedError } from "../../utils/errors";
import * as tarefasService from "./tarefas.service";
import type { CriarTarefaInput, AtualizarTarefaInput } from "./tarefas.schemas";

function getUsuarioId(req: { usuario?: { id: string } }): string {
  if (!req.usuario) throw new UnauthorizedError();
  return req.usuario.id;
}

export const adicionar: RequestHandler<
  { rotinaId: string },
  unknown,
  CriarTarefaInput
> = async (req, res) => {
  const criada = await tarefasService.adicionar(
    getUsuarioId(req),
    req.params.rotinaId,
    req.body,
  );
  res.status(201).json(criada);
};

export const atualizar: RequestHandler<
  { id: string },
  unknown,
  AtualizarTarefaInput
> = async (req, res) => {
  const atualizada = await tarefasService.atualizar(
    getUsuarioId(req),
    req.params.id,
    req.body,
  );
  res.status(200).json(atualizada);
};

export const deletar: RequestHandler<{ id: string }> = async (req, res) => {
  await tarefasService.deletar(getUsuarioId(req), req.params.id);
  res.status(204).send();
};
