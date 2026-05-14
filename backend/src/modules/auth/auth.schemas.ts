import { z } from "zod";

export const registrarSchema = z.object({
  nome: z
    .string()
    .trim()
    .min(2, "Nome precisa ter pelo menos 2 caracteres")
    .max(80, "Nome muito longo"),
  email: z.string().trim().toLowerCase().email("Email inválido"),
  senha: z
    .string()
    .min(6, "Senha precisa ter pelo menos 6 caracteres")
    .max(72, "Senha muito longa"),
});

export const loginSchema = z.object({
  email: z.string().trim().toLowerCase().email("Email inválido"),
  senha: z.string().min(1, "Senha é obrigatória"),
});

export type RegistrarInput = z.infer<typeof registrarSchema>;
export type LoginInput = z.infer<typeof loginSchema>;
