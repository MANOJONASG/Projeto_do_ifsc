CREATE DATABASE IF NOT EXISTS projeto_ifsc CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE projeto_ifsc;

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
  id          CHAR(36)     NOT NULL DEFAULT (UUID()),
  profile_id  CHAR(36)     NOT NULL,
  title       VARCHAR(200) NOT NULL,
  description TEXT         NOT NULL,
  deadline    DATETIME     NOT NULL,
  expired     TINYINT(1)   NOT NULL DEFAULT 0,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_tasks_profile_id FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_tasks_profile_id ON tasks (profile_id);
CREATE INDEX idx_tasks_deadline   ON tasks (deadline);
CREATE INDEX idx_tasks_expired    ON tasks (expired);

CREATE TABLE IF NOT EXISTS sessions (
  id            CHAR(36)   NOT NULL DEFAULT (UUID()),
  profile_id    CHAR(36)   NOT NULL,
  logged_in_at  TIMESTAMP  NOT NULL DEFAULT CURRENT_TIMESTAMP,
  logged_out_at DATETIME            DEFAULT NULL,
  active        TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  CONSTRAINT fk_sessions_profile_id FOREIGN KEY (profile_id) REFERENCES profiles (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

CREATE INDEX idx_sessions_profile_id ON sessions (profile_id);
CREATE INDEX idx_sessions_active      ON sessions (active);

CREATE OR REPLACE VIEW tasks_with_owner AS
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

DELIMITER $$
CREATE PROCEDURE IF NOT EXISTS sp_check_expired_tasks()
BEGIN
  UPDATE tasks SET expired = 1, updated_at = CURRENT_TIMESTAMP
  WHERE deadline < NOW() AND expired = 0;
  SELECT ROW_COUNT() AS tarefas_expiradas_atualizadas;
END$$
DELIMITER ;

INSERT INTO profiles (id, name, email, password_hash) VALUES
  ('a1b2c3d4-0001-0000-0000-000000000001', 'Jonas Silva',    'jonas@ifsc.edu.br',       '$2b$12$KIX8n2mSoLqGzV1tXJ9B5OHbK3RpW7YeN4cA6dFmQs1UvTyPjEwZr'),
  ('a1b2c3d4-0002-0000-0000-000000000002', 'Maria Oliveira', 'maria@ifsc.edu.br',       '$2b$12$LJY9o3nTpMrHaW2uYK0C6PIcL4SqX8ZfO5dB7eGnRt2VwUzQkFxAs'),
  ('a1b2c3d4-0003-0000-0000-000000000003', 'Pedro Souza',    'pedro@aluno.ifsc.edu.br', '$2b$12$MKZ0p4oUqNsIbX3vZL1D7QJdM5TrY9AgP6eC8fHoSu3WxVaRlGyBt');

INSERT INTO tasks (id, profile_id, title, description, deadline, expired) VALUES
  ('b1000000-0000-0000-0000-000000000001', 'a1b2c3d4-0001-0000-0000-000000000001', 'Entrega do projeto de Sistemas de Informacao', 'Finalizar o diagrama de classes UML e o relatorio tecnico do sistema de biblioteca.', '2025-07-15 23:59:00', 0),
  ('b1000000-0000-0000-0000-000000000002', 'a1b2c3d4-0001-0000-0000-000000000001', 'Prova de Etica em TI',                         'Revisar os capitulos 3 e 4. Estudar privacidade de dados, responsabilidade e LGPD.',   '2025-06-20 08:00:00', 0),
  ('b1000000-0000-0000-0000-000000000003', 'a1b2c3d4-0001-0000-0000-000000000001', 'Apresentacao de Sociologia',                   'Slides sobre Durkheim e Weber. Apresentacao em grupo com 15 minutos por equipe.',       '2025-06-25 14:00:00', 0),
  ('b1000000-0000-0000-0000-000000000004', 'a1b2c3d4-0001-0000-0000-000000000001', 'Deploy da aplicacao PataVerde',                'Subir versao final para o servidor de homologacao. Testar responsividade.',             '2025-07-01 18:00:00', 0),
  ('b1000000-0000-0000-0000-000000000005', 'a1b2c3d4-0001-0000-0000-000000000001', 'Lista de exercicios de Banco de Dados',        'Resolver exercicios de normalizacao (1FN, 2FN, 3FN) e criar scripts SQL.',             '2025-06-10 23:59:00', 1),
  ('b1000000-0000-0000-0000-000000000006', 'a1b2c3d4-0002-0000-0000-000000000002', 'Relatorio de Estagio - Junho',                 'Redigir relatorio mensal conforme modelo da coordenacao. Minimo de 3 paginas.',         '2025-06-30 17:00:00', 0),
  ('b1000000-0000-0000-0000-000000000007', 'a1b2c3d4-0002-0000-0000-000000000002', 'Trabalho de Redes de Computadores',            'Configurar topologia no Packet Tracer e documentar IPs, mascaras e gateway.',          '2025-07-10 23:59:00', 0),
  ('b1000000-0000-0000-0000-000000000008', 'a1b2c3d4-0003-0000-0000-000000000003', 'Seminario de Legislacao Educacional',          'Apresentar pontos principais da LDB no ensino tecnico federal. 20 minutos.',           '2025-06-22 09:00:00', 0),
  ('b1000000-0000-0000-0000-000000000009', 'a1b2c3d4-0003-0000-0000-000000000003', 'Implementar API REST em Node.js',              'Criar endpoints CRUD para o modulo de usuarios com Express + Prisma + PostgreSQL.',    '2025-07-05 23:59:00', 0);

INSERT INTO sessions (id, profile_id, logged_in_at, logged_out_at, active) VALUES
  ('c1000000-0000-0000-0000-000000000001', 'a1b2c3d4-0001-0000-0000-000000000001', '2025-06-01 08:30:00', '2025-06-01 12:00:00', 0),
  ('c1000000-0000-0000-0000-000000000002', 'a1b2c3d4-0001-0000-0000-000000000001', NOW(), NULL, 1),
  ('c1000000-0000-0000-0000-000000000003', 'a1b2c3d4-0002-0000-0000-000000000002', '2025-06-05 09:00:00', '2025-06-05 10:30:00', 0);
