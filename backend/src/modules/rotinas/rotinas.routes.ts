import { Router } from "express";
import { authMiddleware } from "../../middlewares/authMiddleware";
import { validate } from "../../middlewares/validate";
import {
  atualizarRotinaSchema,
  criarRotinaSchema,
  idParamSchema,
  reordenarSchema,
} from "./rotinas.schemas";
import * as rotinasController from "./rotinas.controller";

export const rotinasRouter = Router();

rotinasRouter.use(authMiddleware);

rotinasRouter.get("/", rotinasController.listar);
rotinasRouter.post("/", validate(criarRotinaSchema), rotinasController.criar);
rotinasRouter.get(
  "/:id",
  validate(idParamSchema, "params"),
  rotinasController.detalhes,
);
rotinasRouter.put(
  "/:id/reordenar",
  validate(idParamSchema, "params"),
  validate(reordenarSchema),
  rotinasController.reordenar,
);
rotinasRouter.put(
  "/:id",
  validate(idParamSchema, "params"),
  validate(atualizarRotinaSchema),
  rotinasController.atualizar,
);
rotinasRouter.delete(
  "/:id",
  validate(idParamSchema, "params"),
  rotinasController.deletar,
);
