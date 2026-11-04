-- ==============================================================================
-- TRACKER TREBALL - VOLCADO COMPLETO PARA DESPLIEGUE EN RAILWAY MYSQL
-- Autor: Hassan Adraou
-- ==============================================================================

-- Selecciona la base de datos por defecto de Railway (railway)
USE railway;

-- 1. TABLA EMPLOYEES
CREATE TABLE IF NOT EXISTS employees (
  id bigint NOT NULL AUTO_INCREMENT,
  activo bit(1) NOT NULL DEFAULT b'1',
  centro_trabajo varchar(100) NOT NULL,
  departamento varchar(80) NOT NULL,
  email varchar(120) NOT NULL,
  nombre varchar(120) NOT NULL,
  puesto varchar(80) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY UK_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. TABLA PROJECTS
CREATE TABLE IF NOT EXISTS projects (
  id bigint NOT NULL AUTO_INCREMENT,
  dedicated_hours int NOT NULL,
  name varchar(120) NOT NULL,
  sprint_progress int NOT NULL,
  status varchar(40) NOT NULL,
  team_members int NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. TABLA SAFETY_ALERTS
CREATE TABLE IF NOT EXISTS safety_alerts (
  id bigint NOT NULL AUTO_INCREMENT,
  active bit(1) NOT NULL DEFAULT b'1',
  alert_level varchar(20) NOT NULL,
  effective_end datetime(6) NOT NULL,
  effective_start datetime(6) NOT NULL,
  message text NOT NULL,
  source varchar(40) NOT NULL,
  title varchar(150) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. TABLA ATTENDANCE_RECORDS
CREATE TABLE IF NOT EXISTS attendance_records (
  id bigint NOT NULL AUTO_INCREMENT,
  clock_in_time datetime(6) NOT NULL,
  clock_out_time datetime(6) DEFAULT NULL,
  employee_id bigint NOT NULL,
  modality varchar(30) NOT NULL,
  record_hash varchar(64) DEFAULT NULL,
  status varchar(30) NOT NULL,
  work_date date NOT NULL,
  worked_minutes int NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. TABLA BREAK_RECORDS
CREATE TABLE IF NOT EXISTS break_records (
  id bigint NOT NULL AUTO_INCREMENT,
  attendance_id bigint NOT NULL,
  break_type varchar(30) NOT NULL,
  duration_minutes int DEFAULT NULL,
  end_time datetime(6) DEFAULT NULL,
  start_time datetime(6) NOT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. TABLA WORK_INCIDENTS
CREATE TABLE IF NOT EXISTS work_incidents (
  id bigint NOT NULL AUTO_INCREMENT,
  hazard_description text NOT NULL,
  incident_date datetime(6) NOT NULL,
  location varchar(150) NOT NULL,
  reporter_employee_id bigint NOT NULL,
  status varchar(30) NOT NULL,
  suggested_action text,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==============================================================================
-- INSERCION DE DATOS
-- ==============================================================================

-- Empleados Corporativos
INSERT INTO employees (id, nombre, email, departamento, puesto, centro_trabajo, activo) VALUES
(1, 'Hassan Adraou', 'hassan.adraou@test.es', 'Tecnologia', 'Administrador General & Tech Lead', 'Oficina Central Vic', 1),
(2, 'Albert Guiteras', 'albert.guiteras@test.es', 'Tecnologia', 'Tech Lead & Arquitecto Software', 'Oficina Central Vic', 1),
(3, 'Albert Profe', 'albert.profe@test.es', 'Tecnologia', 'Director Academico y Tutor Tecnico', 'Oficina Central Vic', 1),
(4, 'Alba Garcia', 'alba.garcia@test.es', 'Personas', 'Responsable de Recursos Humanos', 'Oficina Central Vic', 1),
(5, 'Jose Daniel Calicchio', 'josedaniel.calicchio@test.es', 'Operaciones', 'Coordinador General de Operaciones', 'Oficina Central Vic', 1),
(6, 'Alba Sanz', 'alba.sanz@test.es', 'Administracion', 'Tecnica de Contabilidad y Facturacion', 'Oficina Central Vic', 1),
(7, 'Aldana Diaz', 'aldana.diaz@test.es', 'Tecnologia', 'Ingeniera de QA y Testing', 'Oficina Central Vic', 1),
(8, 'Barbara Orduz Romero', 'barbara.orduz@test.es', 'Personas', 'Especialista en Seleccion y PRL', 'Oficina Central Vic', 1),
(9, 'David Velez', 'david.velez@test.es', 'Tecnologia', 'Ingeniero Cloud y DevOps', 'Oficina Central Vic', 1),
(10, 'Eduardo Vazquez', 'eduardo.vazquez@test.es', 'Tecnologia', 'Cientifico de Datos e IA', 'Oficina Central Vic', 1),
(11, 'Elena Sanchez', 'elena.sanchez@test.es', 'Personas', 'Gestora de Nominas y Contratos', 'Oficina Central Vic', 1),
(12, 'Gabriel Bonnin', 'gabriel.bonnin@test.es', 'Operaciones', 'Analista de Procesos y Logistica', 'Oficina Central Vic', 1),
(13, 'Hector Moreno', 'hector.moreno@test.es', 'Administracion', 'Auditor Financiero y Control', 'Oficina Central Vic', 1),
(14, 'Ingrid Diaz', 'ingrid.diaz@test.es', 'Personas', 'Coordinadora de Formacion y PRL', 'Oficina Central Vic', 1),
(15, 'Luiggi Josue', 'luiggi.josue@test.es', 'Tecnologia', 'Desarrollador Movil Android', 'Oficina Central Vic', 1),
(16, 'Marc Barranco Cordero', 'marc.barranco@test.es', 'Tecnologia', 'Desarrollador Backend Spring Boot', 'Oficina Central Vic', 1),
(17, 'Michael Xavier Puentestar', 'michael.puentestar@test.es', 'Tecnologia', 'Desarrollador Fullstack', 'Oficina Central Vic', 1),
(18, 'Mohammed Alisawi Aloroza', 'mohammed.alisawi@test.es', 'Tecnologia', 'Desarrollador Frontend UI/UX', 'Oficina Central Vic', 1),
(19, 'Roger Umpiérrez', 'roger.umpierrez@test.es', 'Operaciones', 'Administrador de Sistemas y Soporte', 'Oficina Central Vic', 1),
(20, 'Silvia Navarro', 'silvia.navarro@test.es', 'Administracion', 'Responsable de Compras', 'Oficina Central Vic', 1),
(21, 'YingYing Xu', 'yingying.xu@test.es', 'Administracion', 'Controller Financiero', 'Oficina Central Vic', 1)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), email = VALUES(email);

-- Proyecto
INSERT INTO projects (id, name, status, sprint_progress, team_members, dedicated_hours) VALUES
(1, 'Tracker Treball SaaS', 'IN_PROGRESS', 85, 21, 142)
ON DUPLICATE KEY UPDATE team_members = 21;

-- Jornada en curso de prueba
INSERT INTO attendance_records (id, employee_id, work_date, clock_in_time, clock_out_time, modality, worked_minutes, status, record_hash) VALUES
(1, 1, CURDATE(), NOW(), NULL, 'PRESENCIAL', 215, 'OPEN', '7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- Alertas Preventivas de PRL
INSERT INTO safety_alerts (id, source, alert_level, title, message, effective_start, effective_end, active) VALUES
(1, 'AEMET', 'WARNING', 'Previsión meteorológica en Vic y Osona', 'Lluvias moderadas a partir de las 16:00. Precaución en desplazamientos por C-17.', NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 1),
(2, 'PRL', 'INFO', 'Protocolo Ergonomía y Descanso Visual', 'Pausas de 5 minutos cada 2 horas de trabajo continuado en pantallas.', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 1)
ON DUPLICATE KEY UPDATE title = VALUES(title);

