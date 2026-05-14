import "express-async-errors";

import express from "express";
import cors from "cors";
import { authRouter } from "./modules/auth/auth.routes";
import { rotinasRouter } from "./modules/rotinas/rotinas.routes";
import {
  tarefasRouter,
  tarefasAninhadasRouter,
} from "./modules/tarefas/tarefas.routes";
import { errorHandler } from "./middlewares/errorHandler";

export function criarApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get("/api/health", (_req, res) => {
    res.status(200).json({ status: "ok" });
  });

  app.use("/api/auth", authRouter);
  app.use("/api/rotinas/:rotinaId/tarefas", tarefasAninhadasRouter);
  app.use("/api/rotinas", rotinasRouter);
  app.use("/api/tarefas", tarefasRouter);

  app.use((_req, res) => {
    res.status(404).json({ erro: "NOT_FOUND", mensagem: "Rota não encontrada" });
  });

  app.use(errorHandler);

  return app;
}
