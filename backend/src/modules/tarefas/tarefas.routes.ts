import { Router } from "express";
import { authMiddleware } from "../../middlewares/authMiddleware";
import { validate } from "../../middlewares/validate";
import {
  criarTarefaSchema,
  atualizarTarefaSchema,
  idParamSchema,
  rotinaIdParamSchema,
} from "./tarefas.schemas";
import * as tarefasController from "./tarefas.controller";

export const tarefasAninhadasRouter = Router({ mergeParams: true });
tarefasAninhadasRouter.use(authMiddleware);
tarefasAninhadasRouter.post(
  "/",
  validate(rotinaIdParamSchema, "params"),
  validate(criarTarefaSchema),
  tarefasController.adicionar,
);

export const tarefasRouter = Router();
tarefasRouter.use(authMiddleware);
tarefasRouter.put(
  "/:id",
  validate(idParamSchema, "params"),
  validate(atualizarTarefaSchema),
  tarefasController.atualizar,
);
tarefasRouter.delete(
  "/:id",
  validate(idParamSchema, "params"),
  tarefasController.deletar,
);
