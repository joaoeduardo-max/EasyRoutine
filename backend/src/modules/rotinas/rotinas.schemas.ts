import { z } from "zod";

export const corHexSchema = z
  .string()
  .regex(/^#[0-9A-Fa-f]{6}$/, "Cor deve ser hex no formato #RRGGBB");

export const criarRotinaSchema = z.object({
  titulo: z.string().trim().min(1, "Título é obrigatório").max(80, "Título muito longo"),
  descricao: z
    .string()
    .trim()
    .max(500, "Descrição muito longa")
    .optional()
    .nullable()
    .transform((v) => (v === "" ? null : v ?? null)),
  cor: corHexSchema,
  icone: z.string().trim().min(1, "Ícone é obrigatório").max(10, "Ícone muito longo"),
});

export const atualizarRotinaSchema = z
  .object({
    titulo: z.string().trim().min(1).max(80).optional(),

    descricao: z.string().trim().max(500).nullable().optional(),
    cor: corHexSchema.optional(),
    icone: z.string().trim().min(1).max(10).optional(),
  })
  .refine((d) => Object.values(d).some((v) => v !== undefined), {
    message: "Informe pelo menos um campo para atualizar",
  });

export const idParamSchema = z.object({
  id: z.string().uuid("ID inválido"),
});

export const reordenarSchema = z.object({
  ordemIds: z
    .array(z.string().uuid("ID inválido na lista"))
    .min(1, "Lista de ordem não pode ser vazia"),
});

export type CriarRotinaInput = z.infer<typeof criarRotinaSchema>;
export type AtualizarRotinaInput = z.infer<typeof atualizarRotinaSchema>;
export type IdParam = z.infer<typeof idParamSchema>;
export type ReordenarInput = z.infer<typeof reordenarSchema>;
