import bcrypt from "bcrypt";

const SALT_ROUNDS = 10;

export async function hashSenha(senhaPlana: string): Promise<string> {
  return bcrypt.hash(senhaPlana, SALT_ROUNDS);
}

export async function compararSenha(senhaPlana: string, hash: string): Promise<boolean> {
  return bcrypt.compare(senhaPlana, hash);
}
