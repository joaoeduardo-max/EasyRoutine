import { z } from "zod";

export const criarTarefaSchema = z.object({
  titulo: z.string().trim().min(1, "Título é obrigatório").max(80, "Título muito longo"),
  icone: z.string().trim().min(1, "Ícone é obrigatório").max(10, "Ícone muito longo"),
  duracaoMinutos: z
    .number()
    .int("Duração precisa ser inteira")
    .positive("Duração precisa ser positiva")
    .max(1440, "Duração não pode passar de 24h")
    .optional()
    .nullable(),
});

export const atualizarTarefaSchema = z
  .object({
    titulo: z.string().trim().min(1).max(80).optional(),
    icone: z.string().trim().min(1).max(10).optional(),
    duracaoMinutos: z
      .number()
      .int()
      .positive()
      .max(1440)
      .optional()
      .nullable(),
    concluida: z.boolean().optional(),
  })
  .refine((d) => Object.values(d).some((v) => v !== undefined), {
    message: "Informe pelo menos um campo para atualizar",
  });

export const idParamSchema = z.object({
  id: z.string().uuid("ID inválido"),
});

export const rotinaIdParamSchema = z.object({
  rotinaId: z.string().uuid("ID da rotina inválido"),
});

export type CriarTarefaInput = z.infer<typeof criarTarefaSchema>;
export type AtualizarTarefaInput = z.infer<typeof atualizarTarefaSchema>;
