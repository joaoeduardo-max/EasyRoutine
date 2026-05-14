import "express-async-errors";

import express from "express";
import cors from "cors";
import { errorHandler } from "./middlewares/errorHandler";

export function criarApp() {
  const app = express();

  app.use(cors());
  app.use(express.json());

  app.get("/api/health", (_req, res) => {
    res.status(200).json({ status: "ok" });
  });

  app.use((_req, res) => {
    res.status(404).json({ erro: "NOT_FOUND", mensagem: "Rota não encontrada" });
  });

  app.use(errorHandler);

  return app;
}
