import { prisma } from "../../config/prisma";
import { hashSenha, compararSenha } from "../../utils/password";
import { gerarToken } from "../../utils/jwt";
import { ConflictError, NotFoundError, UnauthorizedError } from "../../utils/errors";
import type { RegistrarInput, LoginInput } from "./auth.schemas";

export interface UsuarioPublico {
  id: string;
  nome: string;
  email: string;
  criadoEm: Date;
}

export interface AutenticacaoResultado {
  token: string;
  usuario: UsuarioPublico;
}

function mapearUsuario(u: {
  id: string;
  nome: string;
  email: string;
  criadoEm: Date;
}): UsuarioPublico {
  return { id: u.id, nome: u.nome, email: u.email, criadoEm: u.criadoEm };
}

export async function registrar(input: RegistrarInput): Promise<AutenticacaoResultado> {
  const existente = await prisma.usuario.findUnique({ where: { email: input.email } });
  if (existente) {
    throw new ConflictError("Já existe uma conta com esse email");
  }

  const senhaHash = await hashSenha(input.senha);
  const criado = await prisma.usuario.create({
    data: { nome: input.nome, email: input.email, senhaHash },
  });

  const token = gerarToken({ sub: criado.id });
  return { token, usuario: mapearUsuario(criado) };
}

export async function login(input: LoginInput): Promise<AutenticacaoResultado> {
  const usuario = await prisma.usuario.findUnique({ where: { email: input.email } });
  if (!usuario) {

    throw new UnauthorizedError("Email ou senha incorretos");
  }

  const senhaOk = await compararSenha(input.senha, usuario.senhaHash);
  if (!senhaOk) {
    throw new UnauthorizedError("Email ou senha incorretos");
  }

  const token = gerarToken({ sub: usuario.id });
  return { token, usuario: mapearUsuario(usuario) };
}

export async function buscarUsuarioPorId(id: string): Promise<UsuarioPublico> {
  const usuario = await prisma.usuario.findUnique({ where: { id } });
  if (!usuario) {
    throw new NotFoundError("Usuário não encontrado");
  }
  return mapearUsuario(usuario);
}
