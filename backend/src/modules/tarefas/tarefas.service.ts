import { prisma } from "../../config/prisma";
import { NotFoundError } from "../../utils/errors";
import type { CriarTarefaInput, AtualizarTarefaInput } from "./tarefas.schemas";

export interface TarefaPublica {
  id: string;
  rotinaId: string;
  titulo: string;
  ordem: number;
  duracaoMinutos: number | null;
  horario: string | null;
  cor: string | null;
  icone: string;
  concluida: boolean;
}

export function mapearTarefa(t: {
  id: string;
  rotinaId: string;
  titulo: string;
  ordem: number;
  duracaoMinutos: number | null;
  horario: string | null;
  cor: string | null;
  icone: string;
  concluida: boolean;
}): TarefaPublica {
  return {
    id: t.id,
    rotinaId: t.rotinaId,
    titulo: t.titulo,
    ordem: t.ordem,
    duracaoMinutos: t.duracaoMinutos,
    horario: t.horario,
    cor: t.cor,
    icone: t.icone,
    concluida: t.concluida,
  };
}

export async function adicionar(
  usuarioId: string,
  rotinaId: string,
  dados: CriarTarefaInput,
): Promise<TarefaPublica> {
  const rotina = await prisma.rotina.findFirst({
    where: { id: rotinaId, usuarioId },
    select: { id: true },
  });
  if (!rotina) throw new NotFoundError("Rotina não encontrada");

  const ultima = await prisma.tarefa.findFirst({
    where: { rotinaId },
    orderBy: { ordem: "desc" },
    select: { ordem: true },
  });
  const proximaOrdem = (ultima?.ordem ?? -1) + 1;

  const criada = await prisma.tarefa.create({
    data: {
      rotinaId,
      titulo: dados.titulo,
      icone: dados.icone,
      duracaoMinutos: dados.duracaoMinutos ?? null,
      horario: dados.horario ?? null,
      cor: dados.cor ?? null,
      ordem: proximaOrdem,
    },
  });
  return mapearTarefa(criada);
}

export async function atualizar(
  usuarioId: string,
  tarefaId: string,
  dados: AtualizarTarefaInput,
): Promise<TarefaPublica> {

  const existente = await prisma.tarefa.findFirst({
    where: { id: tarefaId, rotina: { usuarioId } },
    select: { id: true },
  });
  if (!existente) throw new NotFoundError("Tarefa não encontrada");

  const data: {
    titulo?: string;
    icone?: string;
    duracaoMinutos?: number | null;
    horario?: string | null;
    cor?: string | null;
    concluida?: boolean;
  } = {};
  if (dados.titulo !== undefined) data.titulo = dados.titulo;
  if (dados.icone !== undefined) data.icone = dados.icone;
  if (dados.duracaoMinutos !== undefined) data.duracaoMinutos = dados.duracaoMinutos ?? null;
  if (dados.horario !== undefined) data.horario = dados.horario ?? null;
  if (dados.cor !== undefined) data.cor = dados.cor ?? null;
  if (dados.concluida !== undefined) data.concluida = dados.concluida;

  const atualizada = await prisma.tarefa.update({
    where: { id: tarefaId },
    data,
  });
  return mapearTarefa(atualizada);
}

export async function deletar(usuarioId: string, tarefaId: string): Promise<void> {
  const resultado = await prisma.tarefa.deleteMany({
    where: { id: tarefaId, rotina: { usuarioId } },
  });
  if (resultado.count === 0) {
    throw new NotFoundError("Tarefa não encontrada");
  }
}
