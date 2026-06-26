-- Script SQL para criar o banco Projeto IFSC
-- Compatível com MySQL 8+
-- Não interfere no cadastro nem na porta 3000; ele só prepara o banco.

CREATE DATABASE IF NOT EXISTS projeto_ifsc
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE projeto_ifsc;

-- Para reiniciar do zero, descomente as linhas abaixo:
-- DROP TABLE IF EXISTS sessions;
-- DROP TABLE IF EXISTS tasks;
-- DROP TABLE IF EXISTS profiles;
-- DROP VIEW IF EXISTS tasks_with_owner;
-- DROP PROCEDURE IF EXISTS sp_check_expired_tasks;

CREATE TABLE IF NOT EXISTS profiles (
  id            CHAR(36)     NOT NULL DEFAULT (UUID()),
  name          VARCHAR(120) NOT NULL,
  email         VARCHAR(254) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_profiles_email (email)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS tasks (
  id           CHAR(36)     NOT NULL DEFAULT (UUID()),
  profile_id   CHAR(36)     NOT NULL,
  title        VARCHAR(200) NOT NULL,
  description  TEXT         NOT NULL,
  deadline     DATETIME     NOT NULL,
  expired      TINYINT(1)   NOT NULL DEFAULT 0,
  created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_tasks_profile_id (profile_id),
  KEY idx_tasks_deadline (deadline),
  KEY idx_tasks_expired (expired),
  CONSTRAINT fk_tasks_profile_id
    FOREIGN KEY (profile_id) REFERENCES profiles (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sessions (
  id            CHAR(36)     NOT NULL DEFAULT (UUID()),
  profile_id    CHAR(36)     NOT NULL,
  logged_in_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  logged_out_at DATETIME     NULL DEFAULT NULL,
  active        TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  KEY idx_sessions_profile_id (profile_id),
  KEY idx_sessions_active (active),
  CONSTRAINT fk_sessions_profile_id
    FOREIGN KEY (profile_id) REFERENCES profiles (id)
    ON DELETE CASCADE
    ON UPDATE CASCADE
) ENGINE=InnoDB;

DROP VIEW IF EXISTS tasks_with_owner;
CREATE VIEW tasks_with_owner AS
SELECT
  t.id          AS task_id,
  t.title,
  t.description,
  t.deadline,
  t.expired,
  t.created_at  AS task_created_at,
  p.id          AS profile_id,
  p.name        AS owner_name,
  p.email       AS owner_email
FROM tasks t
JOIN profiles p ON p.id = t.profile_id;

DROP PROCEDURE IF EXISTS sp_check_expired_tasks;
DELIMITER $$
CREATE PROCEDURE sp_check_expired_tasks()
BEGIN
  UPDATE tasks
  SET expired = 1, updated_at = CURRENT_TIMESTAMP
  WHERE deadline < NOW() AND expired = 0;

  SELECT ROW_COUNT() AS tarefas_expiradas_atualizadas;
END$$
DELIMITER ;

-- Dados de exemplo para testes
INSERT INTO profiles (id, name, email, password_hash)
VALUES
  ('a1b2c3d4-0001-0000-0000-000000000001', 'Jonas Silva', 'jonas@ifsc.edu.br', '$2b$12$KIX8n2mSoLqGzV1tXJ9B5OHbK3RpW7YeN4cA6dFmQs1UvTyPjEwZr'),
  ('a1b2c3d4-0002-0000-0000-000000000002', 'Maria Oliveira', 'maria@ifsc.edu.br', '$2b$12$LJY9o3nTpMrHaW2uYK0C6PIcL4SqX8ZfO5dB7eGnRt2VwUzQkFxAs'),
  ('a1b2c3d4-0003-0000-0000-000000000003', 'Pedro Souza', 'pedro@aluno.ifsc.edu.br', '$2b$12$MKZ0p4oUqNsIbX3vZL1D7QJdM5TrY9AgP6eC8fHoSu3WxVaRlGyBt')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  password_hash = VALUES(password_hash);

INSERT INTO tasks (id, profile_id, title, description, deadline, expired)
VALUES
  ('b1000000-0000-0000-0000-000000000001', 'a1b2c3d4-0001-0000-0000-000000000001', 'Entrega do projeto de Sistemas de Informação', 'Finalizar o diagrama de classes UML e o relatório técnico do sistema de biblioteca.', '2025-07-15 23:59:00', 0),
  ('b1000000-0000-0000-0000-000000000002', 'a1b2c3d4-0001-0000-0000-000000000001', 'Prova de Ética em TI', 'Revisar os capítulos 3 e 4. Estudar privacidade de dados, responsabilidade e LGPD.', '2025-06-20 08:00:00', 0),
  ('b1000000-0000-0000-0000-000000000003', 'a1b2c3d4-0001-0000-0000-000000000001', 'Apresentação de Sociologia', 'Slides sobre Durkheim e Weber. Apresentação em grupo com 15 minutos por equipe.', '2025-06-25 14:00:00', 0),
  ('b1000000-0000-0000-0000-000000000004', 'a1b2c3d4-0001-0000-0000-000000000001', 'Deploy da aplicação PataVerde', 'Subir versão final para o servidor de homologação. Testar responsividade.', '2025-07-01 18:00:00', 0),
  ('b1000000-0000-0000-0000-000000000005', 'a1b2c3d4-0001-0000-0000-000000000001', 'Lista de exercícios de Banco de Dados', 'Resolver exercícios de normalização (1FN, 2FN, 3FN) e criar scripts SQL.', '2025-06-10 23:59:00', 1),
  ('b1000000-0000-0000-0000-000000000006', 'a1b2c3d4-0002-0000-0000-000000000002', 'Relatório de Estágio - Junho', 'Redigir relatório mensal conforme modelo da coordenação. Mínimo de 3 páginas.', '2025-06-30 17:00:00', 0),
  ('b1000000-0000-0000-0000-000000000007', 'a1b2c3d4-0002-0000-0000-000000000002', 'Trabalho de Redes de Computadores', 'Configurar topologia no Packet Tracer e documentar IPs, máscaras e gateway.', '2025-07-10 23:59:00', 0),
  ('b1000000-0000-0000-0000-000000000008', 'a1b2c3d4-0003-0000-0000-000000000003', 'Seminário de Legislação Educacional', 'Apresentar pontos principais da LDB no ensino técnico federal. 20 minutos.', '2025-06-22 09:00:00', 0),
  ('b1000000-0000-0000-0000-000000000009', 'a1b2c3d4-0003-0000-0000-000000000003', 'Implementar API REST em Node.js', 'Criar endpoints CRUD para o módulo de usuários com Express + Prisma + PostgreSQL.', '2025-07-05 23:59:00', 0)
ON DUPLICATE KEY UPDATE
  profile_id = VALUES(profile_id),
  title = VALUES(title),
  description = VALUES(description),
  deadline = VALUES(deadline),
  expired = VALUES(expired);

INSERT INTO sessions (id, profile_id, logged_in_at, logged_out_at, active)
VALUES
  ('c1000000-0000-0000-0000-000000000001', 'a1b2c3d4-0001-0000-0000-000000000001', '2025-06-01 08:30:00', '2025-06-01 12:00:00', 0),
  ('c1000000-0000-0000-0000-000000000002', 'a1b2c3d4-0001-0000-0000-000000000001', CURRENT_TIMESTAMP, NULL, 1),
  ('c1000000-0000-0000-0000-000000000003', 'a1b2c3d4-0002-0000-0000-000000000002', '2025-06-05 09:00:00', '2025-06-05 10:30:00', 0)
ON DUPLICATE KEY UPDATE
  profile_id = VALUES(profile_id),
  logged_out_at = VALUES(logged_out_at),
  active = VALUES(active);
