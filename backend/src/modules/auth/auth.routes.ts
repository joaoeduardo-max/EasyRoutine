import { Router } from "express";
import { validate } from "../../middlewares/validate";
import { authMiddleware } from "../../middlewares/authMiddleware";
import { registrarSchema, loginSchema } from "./auth.schemas";
import * as authController from "./auth.controller";

export const authRouter = Router();

authRouter.post("/registrar", validate(registrarSchema), authController.registrar);
authRouter.post("/login", validate(loginSchema), authController.login);
authRouter.get("/me", authMiddleware, authController.me);
