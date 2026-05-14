import { Periodo } from "@prisma/client";
import { prisma } from "../../config/prisma";
import { BadRequestError, NotFoundError } from "../../utils/errors";
import { mapearTarefa } from "../tarefas/tarefas.service";
import type { TarefaPublica } from "../tarefas/tarefas.service";
import type { AtualizarRotinaInput, CriarRotinaInput } from "./rotinas.schemas";

export interface RotinaPublica {
  id: string;
  titulo: string;
  descricao: string | null;
  cor: string;
  icone: string;
  periodo: Periodo | null;
  ativa: boolean;
  criadaEm: Date;
  atualizadaEm: Date;
  totalTarefas: number;
}

function mapear(r: {
  id: string;
  titulo: string;
  descricao: string | null;
  cor: string;
  icone: string;
  periodo: Periodo | null;
  ativa: boolean;
  criadaEm: Date;
  atualizadaEm: Date;
}, totalTarefas: number): RotinaPublica {
  return {
    id: r.id,
    titulo: r.titulo,
    descricao: r.descricao,
    cor: r.cor,
    icone: r.icone,
    periodo: r.periodo,
    ativa: r.ativa,
    criadaEm: r.criadaEm,
    atualizadaEm: r.atualizadaEm,
    totalTarefas,
  };
}

export async function listar(usuarioId: string): Promise<RotinaPublica[]> {
  const rotinas = await prisma.rotina.findMany({
    where: { usuarioId },
    orderBy: { criadaEm: "desc" },
    include: { _count: { select: { tarefas: true } } },
  });
  return rotinas.map((r) => mapear(r, r._count.tarefas));
}

export async function criar(
  usuarioId: string,
  dados: CriarRotinaInput,
): Promise<RotinaPublica> {
  const criada = await prisma.rotina.create({
    data: {
      usuarioId,
      titulo: dados.titulo,
      descricao: dados.descricao ?? null,
      cor: dados.cor,
      icone: dados.icone,
      periodo: dados.periodo ?? null,
    },
  });

  return mapear(criada, 0);
}

export interface RotinaDetalhes extends RotinaPublica {
  tarefas: TarefaPublica[];
}

export async function buscarPorIdComTarefas(
  usuarioId: string,
  id: string,
): Promise<RotinaDetalhes> {
  const rotina = await prisma.rotina.findFirst({
    where: { id, usuarioId },
    include: { tarefas: { orderBy: { ordem: "asc" } } },
  });
  if (!rotina) throw new NotFoundError("Rotina não encontrada");
  return {
    ...mapear(rotina, rotina.tarefas.length),
    tarefas: rotina.tarefas.map(mapearTarefa),
  };
}

export async function reordenar(
  usuarioId: string,
  rotinaId: string,
  ordemIds: string[],
): Promise<TarefaPublica[]> {
  const rotina = await prisma.rotina.findFirst({
    where: { id: rotinaId, usuarioId },
    include: { tarefas: { select: { id: true } } },
  });
  if (!rotina) throw new NotFoundError("Rotina não encontrada");

  const idsAtuais = new Set(rotina.tarefas.map((t) => t.id));
  const idsRecebidos = new Set(ordemIds);
  const tamanhoIgual = idsAtuais.size === idsRecebidos.size;
  const todosBatem = ordemIds.every((id) => idsAtuais.has(id));
  if (!tamanhoIgual || !todosBatem || idsRecebidos.size !== ordemIds.length) {
    throw new BadRequestError(
      "Lista de ordem inválida: precisa conter exatamente os ids das tarefas dessa rotina, sem duplicatas",
    );
  }

  await prisma.$transaction(
    ordemIds.map((id, idx) =>
      prisma.tarefa.update({ where: { id }, data: { ordem: idx } }),
    ),
  );

  const reordenadas = await prisma.tarefa.findMany({
    where: { rotinaId },
    orderBy: { ordem: "asc" },
  });
  return reordenadas.map(mapearTarefa);
}

export async function atualizar(
  usuarioId: string,
  id: string,
  dados: AtualizarRotinaInput,
): Promise<RotinaPublica> {
  const existente = await prisma.rotina.findFirst({
    where: { id, usuarioId },
    select: { id: true },
  });
  if (!existente) throw new NotFoundError("Rotina não encontrada");

  const data: {
    titulo?: string;
    descricao?: string | null;
    cor?: string;
    icone?: string;
    periodo?: Periodo | null;
  } = {};
  if (dados.titulo !== undefined) data.titulo = dados.titulo;
  if (dados.descricao !== undefined) data.descricao = dados.descricao ?? null;
  if (dados.cor !== undefined) data.cor = dados.cor;
  if (dados.icone !== undefined) data.icone = dados.icone;
  if (dados.periodo !== undefined) data.periodo = dados.periodo ?? null;

  const atualizada = await prisma.rotina.update({
    where: { id },
    data,
    include: { _count: { select: { tarefas: true } } },
  });
  return mapear(atualizada, atualizada._count.tarefas);
}

export async function deletar(usuarioId: string, id: string): Promise<void> {

  const resultado = await prisma.rotina.deleteMany({
    where: { id, usuarioId },
  });
  if (resultado.count === 0) {
    throw new NotFoundError("Rotina não encontrada");
  }
}
