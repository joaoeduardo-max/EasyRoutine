-- AlterTable
ALTER TABLE `rotinas` ADD COLUMN `periodo` ENUM('MANHA', 'TARDE', 'NOITE') NULL;

-- AlterTable
ALTER TABLE `tarefas` ADD COLUMN `cor` VARCHAR(191) NULL,
    ADD COLUMN `horario` VARCHAR(5) NULL;
