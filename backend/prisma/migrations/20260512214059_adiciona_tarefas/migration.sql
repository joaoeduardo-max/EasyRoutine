-- CreateTable
CREATE TABLE `tarefas` (
    `id` VARCHAR(191) NOT NULL,
    `rotina_id` VARCHAR(191) NOT NULL,
    `titulo` VARCHAR(191) NOT NULL,
    `ordem` INTEGER NOT NULL,
    `duracao_minutos` INTEGER NULL,
    `icone` VARCHAR(191) NOT NULL,
    `concluida` BOOLEAN NOT NULL DEFAULT false,

    INDEX `tarefas_rotina_id_ordem_idx`(`rotina_id`, `ordem`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `tarefas` ADD CONSTRAINT `tarefas_rotina_id_fkey` FOREIGN KEY (`rotina_id`) REFERENCES `rotinas`(`id`) ON DELETE CASCADE ON UPDATE CASCADE;
