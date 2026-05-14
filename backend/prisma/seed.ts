import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";

const prisma = new PrismaClient();

async function main() {
  const senhaHash = await bcrypt.hash("123456", 10);

  const usuario = await prisma.usuario.upsert({
    where: { email: "teste@teste.com" },
    update: { senhaHash, nome: "Usuário Teste" },
    create: {
      email: "teste@teste.com",
      nome: "Usuário Teste",
      senhaHash,
    },
  });

  console.log(`Seed ok: ${usuario.email}`);
}

main()
  .catch((err) => {
    console.error(err);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
