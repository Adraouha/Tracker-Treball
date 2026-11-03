-- Datos Semilla de Usuarios, Credenciales y Privilegios
-- Tracker Treball - Plataforma de Control Horario y PRL
-- Autor: Hassan Adraou

USE tracker_treball_db;

-- 1. Insercion de los 21 Empleados del Equipo
INSERT INTO employees (id, nombre, email, departamento, puesto, centro_trabajo, rol, estado, activo) VALUES
(1, 'Hassan Adraou', 'hassan.adraou@test.es', 'Tecnología', 'Administrador General & Tech Lead', 'Oficina Central Vic', 'ADMIN', 'Activo', 1),
(2, 'Albert Guiteras', 'albert.guiteras@test.es', 'Tecnología', 'Tech Lead & Arquitecto Software', 'Oficina Central Vic', 'SUPERVISOR', 'Activo', 1),
(3, 'Albert Profe', 'albert.profe@test.es', 'Tecnología', 'Director Académico y Tutor Técnico', 'Oficina Central Vic', 'SUPERVISOR', 'Activo', 1),
(4, 'Alba Garcia', 'alba.garcia@test.es', 'Personas', 'Responsable de Recursos Humanos', 'Oficina Central Vic', 'SUPERVISOR', 'Activo', 1),
(5, 'Jose Daniel Calicchio', 'josedaniel.calicchio@test.es', 'Operaciones', 'Coordinador General de Operaciones', 'Oficina Central Vic', 'SUPERVISOR', 'Activo', 1),
(6, 'Alba Sanz', 'alba.sanz@test.es', 'Administración', 'Técnica de Contabilidad y Facturación', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(7, 'Aldana Diaz', 'aldana.diaz@test.es', 'Tecnología', 'Ingeniera de QA y Testing', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(8, 'Barbara Orduz Romero', 'barbara.orduz@test.es', 'Personas', 'Especialista en Selección y PRL', 'Oficina Central Vic', 'RRHH_PRL', 'Activo', 1),
(9, 'David Vélez', 'david.velez@test.es', 'Tecnología', 'Ingeniero Cloud y DevOps', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(10, 'Eduardo Vázquez', 'eduardo.vazquez@test.es', 'Tecnología', 'Científico de Datos e IA', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(11, 'Elena Sánchez', 'elena.sanchez@test.es', 'Personas', 'Gestora de Nóminas y Contratos', 'Oficina Central Vic', 'RRHH_PRL', 'Vacaciones', 1),
(12, 'Gabriel Bonnin', 'gabriel.bonnin@test.es', 'Operaciones', 'Analista de Procesos y Logística', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(13, 'Héctor Moreno', 'hector.moreno@test.es', 'Administración', 'Auditor Financiero y Control', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(14, 'Ingrid Diaz', 'ingrid.diaz@test.es', 'Personas', 'Coordinadora de Formación y PRL', 'Oficina Central Vic', 'RRHH_PRL', 'Activo', 1),
(15, 'Luiggi Josue', 'luiggi.josue@test.es', 'Tecnología', 'Desarrollador Móvil Android', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(16, 'Marc Barranco Cordero', 'marc.barranco@test.es', 'Tecnología', 'Desarrollador Backend Spring Boot', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(17, 'Michael Xavier Puentestar', 'michael.puentestar@test.es', 'Tecnología', 'Desarrollador Fullstack', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(18, 'Mohammed Alisawi Aloroza', 'mohammed.alisawi@test.es', 'Tecnología', 'Desarrollador Frontend UI/UX', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(19, 'Roger Umpiérrez', 'roger.umpierrez@test.es', 'Operaciones', 'Administrador de Sistemas y Soporte', 'Oficina Central Vic', 'EMPLOYEE', 'Baja', 1),
(20, 'Silvia Navarro', 'silvia.navarro@test.es', 'Administración', 'Responsable de Compras', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1),
(21, 'YingYing Xu', 'yingying.xu@test.es', 'Administración', 'Controller Financiero', 'Oficina Central Vic', 'EMPLOYEE', 'Activo', 1)
ON DUPLICATE KEY UPDATE nombre = VALUES(nombre), email = VALUES(email), rol = VALUES(rol);

-- 2. Insercion de Credenciales de Acceso en Tabla Users
INSERT INTO users (id, employee_id, username, email, password_hash, rol, activo) VALUES
(1, 1, 'hassan.adraou', 'hassan.adraou@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.Admin2026', 'ADMIN', 1),
(2, 2, 'albert.guiteras', 'albert.guiteras@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.AlbertG2026', 'SUPERVISOR', 1),
(3, 3, 'albert.profe', 'albert.profe@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.AlbertP2026', 'SUPERVISOR', 1),
(4, 4, 'alba.garcia', 'alba.garcia@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.AlbaG2026', 'SUPERVISOR', 1),
(5, 5, 'josedaniel.calicchio', 'josedaniel.calicchio@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.JoseC2026', 'SUPERVISOR', 1),
(6, 6, 'alba.sanz', 'alba.sanz@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.AlbaS2026', 'EMPLOYEE', 1),
(7, 7, 'aldana.diaz', 'aldana.diaz@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.AldanaD2026', 'EMPLOYEE', 1),
(8, 8, 'barbara.orduz', 'barbara.orduz@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.BarbaraO2026', 'RRHH_PRL', 1),
(9, 9, 'david.velez', 'david.velez@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.DavidV2026', 'EMPLOYEE', 1),
(10, 10, 'eduardo.vazquez', 'eduardo.vazquez@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.EduardoV2026', 'EMPLOYEE', 1),
(11, 11, 'elena.sanchez', 'elena.sanchez@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.ElenaS2026', 'RRHH_PRL', 1),
(12, 12, 'gabriel.bonnin', 'gabriel.bonnin@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.GabrielB2026', 'EMPLOYEE', 1),
(13, 13, 'hector.moreno', 'hector.moreno@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.HectorM2026', 'EMPLOYEE', 1),
(14, 14, 'ingrid.diaz', 'ingrid.diaz@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.IngridD2026', 'RRHH_PRL', 1),
(15, 15, 'luiggi.josue', 'luiggi.josue@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.LuiggiJ2026', 'EMPLOYEE', 1),
(16, 16, 'marc.barranco', 'marc.barranco@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.MarcB2026', 'EMPLOYEE', 1),
(17, 17, 'michael.puentestar', 'michael.puentestar@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.MichaelP2026', 'EMPLOYEE', 1),
(18, 18, 'mohammed.alisawi', 'mohammed.alisawi@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.MohammedA2026', 'EMPLOYEE', 1),
(19, 19, 'roger.umpierrez', 'roger.umpierrez@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.RogerU2026', 'EMPLOYEE', 1),
(20, 20, 'silvia.navarro', 'silvia.navarro@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.SilviaN2026', 'EMPLOYEE', 1),
(21, 21, 'yingying.xu', 'yingying.xu@test.es', '$2a$10$wT5tG4H3h5J6k7L8m9N0oO.YingYingX2026', 'EMPLOYEE', 1)
ON DUPLICATE KEY UPDATE username = VALUES(username), email = VALUES(email), rol = VALUES(rol);

-- 3. Insercion del Proyecto Principal
INSERT INTO projects (id, name, status, sprint_progress, team_members, dedicated_hours) VALUES
(1, 'Tracker Treball SaaS', 'IN_PROGRESS', 85, 21, 142)
ON DUPLICATE KEY UPDATE team_members = 21;

-- 4. Insercion de Jornada Activa para Hassan Adraou
INSERT INTO attendance_records (id, employee_id, work_date, clock_in_time, clock_out_time, modality, worked_minutes, status, record_hash) VALUES
(1, 1, CURDATE(), CONCAT(CURDATE(), ' 08:45:00'), NULL, 'PRESENCIAL', 215, 'OPEN', '7f83b1657ff1fc53b92dc18148a1d65dfc2d4b1fa3d677284addd200126d9069')
ON DUPLICATE KEY UPDATE status = VALUES(status);

-- 5. Alertas Preventivas (PRL)
INSERT INTO safety_alerts (id, source, alert_level, title, message, effective_start, effective_end, active) VALUES
(1, 'AEMET', 'WARNING', 'Previsión meteorológica en Vic y Osona', 'Lluvias moderadas a partir de las 16:00. Precaución en desplazamientos por C-17.', NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), 1),
(2, 'PRL', 'INFO', 'Protocolo Ergonomía y Descanso Visual', 'Pausas de 5 minutos cada 2 horas de trabajo continuado en pantallas.', NOW(), DATE_ADD(NOW(), INTERVAL 7 DAY), 1)
ON DUPLICATE KEY UPDATE title = VALUES(title);
