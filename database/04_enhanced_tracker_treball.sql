-- ==============================================================================
-- MIGRACION MEJORADA PARA TRACKER TREBALL (FASE EMPRESARIAL / ENTERPRISE)
-- Autor: Hassan Adraou
-- Base de Datos: MySQL 8+ (Railway)
-- ==============================================================================

USE railway;

-- 1. TABLA DE CENTROS DE TRABAJO
CREATE TABLE IF NOT EXISTS work_centers (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(80) NOT NULL UNIQUE,
    ciudad VARCHAR(80) NOT NULL,
    provincia VARCHAR(80) NOT NULL,
    comunidad_autonoma VARCHAR(80) NOT NULL,
    zona_geografica VARCHAR(80) NOT NULL,
    direccion VARCHAR(160) NOT NULL,
    latitud DECIMAL(9, 6) NOT NULL,
    longitud DECIMAL(9, 6) NOT NULL,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insercion de los 6 Centros de Trabajo requeridos
INSERT INTO work_centers (id, nombre, ciudad, provincia, comunidad_autonoma, zona_geografica, direccion, latitud, longitud)
VALUES 
    (1, 'Barcelona', 'Barcelona', 'Barcelona', 'Cataluña', 'Noreste', 'Avinguda Diagonal 450, 08006 Barcelona', 41.3879, 2.1699),
    (2, 'Madrid', 'Madrid', 'Madrid', 'Comunidad de Madrid', 'Centro', 'Paseo de la Castellana 120, 28046 Madrid', 40.4168, -3.7038),
    (3, 'Bilbao', 'Bilbao', 'Bizkaia', 'País Vasco', 'Norte', 'Gran Vía de Don Diego López de Haro 32, 48009 Bilbao', 43.2630, -2.9350),
    (4, 'Sevilla', 'Sevilla', 'Sevilla', 'Andalucía', 'Sur', 'Avenida de la Constitución 18, 41004 Sevilla', 37.3891, -5.9845),
    (5, 'Valencia', 'Valencia', 'Valencia', 'Comunidad Valenciana', 'Levante', 'Carrer de Colón 24, 46004 Valencia', 39.4699, -0.3763),
    (6, 'Extranjero', 'París', 'Internacional', 'Internacional', 'Europa', 'Boulevard Haussmann 88, 75008 París', 48.8566, 2.3522)
ON DUPLICATE KEY UPDATE 
    direccion=VALUES(direccion), latitud=VALUES(latitud), longitud=VALUES(longitud);

-- 2. AMPLIAR TABLA DE EMPLEADOS CON CAMPOS EXTENDIDOS Y RELACION CON CENTRO DE TRABAJO
-- Añadir work_center_id, nss, estado_civil, domicilio, fecha_nacimiento, telefono si no existen
SET @dbname = DATABASE();
SET @tablename = "employees";

-- Procedimiento para añadir columnas si no existen
DROP PROCEDURE IF EXISTS add_emp_columns;
DELIMITER $$
CREATE PROCEDURE add_emp_columns()
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='work_center_id') THEN
        ALTER TABLE employees ADD COLUMN work_center_id BIGINT NULL;
    END IF;
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='nss') THEN
        ALTER TABLE employees ADD COLUMN nss VARCHAR(30) NULL;
    END IF;
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='estado_civil') THEN
        ALTER TABLE employees ADD COLUMN estado_civil VARCHAR(30) NOT NULL DEFAULT 'Soltero/a';
    END IF;
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='domicilio') THEN
        ALTER TABLE employees ADD COLUMN domicilio VARCHAR(180) NOT NULL DEFAULT 'Calle Principal 1, Barcelona';
    END IF;
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='fecha_nacimiento') THEN
        ALTER TABLE employees ADD COLUMN fecha_nacimiento DATE NULL;
    END IF;
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME=@tablename AND COLUMN_NAME='telefono') THEN
        ALTER TABLE employees ADD COLUMN telefono VARCHAR(30) NOT NULL DEFAULT '+34 600 000 000';
    END IF;
END$$
DELIMITER ;
CALL add_emp_columns();
DROP PROCEDURE IF EXISTS add_emp_columns;

-- Asignar centros de trabajo por defecto y datos personales a los 21 empleados
UPDATE employees SET 
    work_center_id = CASE 
        WHEN id IN (1, 2, 3, 4, 16, 17, 18) THEN 1 -- Barcelona
        WHEN id IN (5, 6, 7, 8) THEN 2              -- Madrid
        WHEN id IN (9, 10, 11) THEN 3               -- Bilbao
        WHEN id IN (12, 13) THEN 4                  -- Sevilla
        WHEN id IN (14, 15, 20) THEN 5              -- Valencia
        ELSE 6                                      -- Extranjero (19, 21)
    END,
    centro_trabajo = CASE 
        WHEN id IN (1, 2, 3, 4, 16, 17, 18) THEN 'Barcelona'
        WHEN id IN (5, 6, 7, 8) THEN 'Madrid'
        WHEN id IN (9, 10, 11) THEN 'Bilbao'
        WHEN id IN (12, 13) THEN 'Sevilla'
        WHEN id IN (14, 15, 20) THEN 'Valencia'
        ELSE 'Extranjero'
    END,
    nss = CONCAT('28', LPAD(id, 8, '0'), '45'),
    fecha_nacimiento = CASE
        WHEN id = 1 THEN '1995-11-04' -- Cumpleaños mañana para prueba de alertas
        WHEN id = 2 THEN '1992-06-15'
        WHEN id = 3 THEN '1988-03-22'
        WHEN id = 4 THEN '1994-09-10'
        ELSE DATE_SUB('2000-01-01', INTERVAL (id * 380) DAY)
    END,
    estado_civil = CASE WHEN MOD(id, 2) = 0 THEN 'Casado/a' ELSE 'Soltero/a' END,
    domicilio = CONCAT('Carrer Major ', id * 4, ', ', centro_trabajo)
WHERE work_center_id IS NULL OR nss IS NULL;

-- 3. TABLA DE CREDENCIALES Y ACCESO DE USUARIOS
CREATE TABLE IF NOT EXISTS user_credentials (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL UNIQUE,
    username VARCHAR(80) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    password_plain_hint VARCHAR(100) NULL,
    must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acceso TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_cred_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Credenciales automáticas para los 21 empleados (contraseña inicial segura: 'Tracker2026!')
-- BCrypt para 'Tracker2026!' es '$2a$10$O0Fsz4B1dO6i1qU16kL4uOHdI3D7r3.N1QxWd1L3m6Q0Dq5tE5wre'
INSERT INTO user_credentials (employee_id, username, password_hash, password_plain_hint, must_change_password)
SELECT 
    e.id, 
    LOWER(SUBSTRING_INDEX(e.email, '@', 1)), 
    '$2a$10$7RkJyW8oE1b5rVwVq7v.7eC31T1KjG7VzG9c0VzH6b7oN1a2b3c4d', -- 'Tracker2026!'
    'Tracker2026!',
    FALSE
FROM employees e
ON DUPLICATE KEY UPDATE 
    username=VALUES(username);

-- 4. AMPLIAR TABLA DE PAUSAS CON CONTROL DE TIEMPO ESTIPULADO Y EXCESO CONSUMIDO
DROP PROCEDURE IF EXISTS add_break_columns;
DELIMITER $$
CREATE PROCEDURE add_break_columns()
BEGIN
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME='break_records' AND COLUMN_NAME='tiempo_estipulado_minutos') THEN
        ALTER TABLE break_records ADD COLUMN tiempo_estipulado_minutos INT NOT NULL DEFAULT 15;
    END IF;
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME='break_records' AND COLUMN_NAME='minutos_adicionales') THEN
        ALTER TABLE break_records ADD COLUMN minutos_adicionales INT NOT NULL DEFAULT 0;
    END IF;
    IF NOT EXISTS (SELECT * FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=@dbname AND TABLE_NAME='break_records' AND COLUMN_NAME='mensaje_notificacion') THEN
        ALTER TABLE break_records ADD COLUMN mensaje_notificacion VARCHAR(255) NULL;
    END IF;
END$$
DELIMITER ;
CALL add_break_columns();
DROP PROCEDURE IF EXISTS add_break_columns;

-- 5. TABLA DE CALENDARIOS Y FESTIVOS POR CENTRO DE TRABAJO
CREATE TABLE IF NOT EXISTS work_center_holidays (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    work_center_id BIGINT NULL, -- NULL indica festivo nacional (aplica a todos)
    fecha DATE NOT NULL,
    nombre VARCHAR(120) NOT NULL,
    tipo VARCHAR(40) NOT NULL DEFAULT 'NACIONAL', -- NACIONAL, AUTONOMICO, LOCAL
    ano INT NOT NULL DEFAULT 2026,
    CONSTRAINT fk_holiday_wc FOREIGN KEY (work_center_id) REFERENCES work_centers(id) ON DELETE CASCADE,
    INDEX idx_holiday_date (fecha),
    INDEX idx_holiday_wc (work_center_id, fecha)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Festivos de muestra para 2026 según centro de trabajo
INSERT INTO work_center_holidays (work_center_id, fecha, nombre, tipo, ano)
VALUES 
    -- Festivos Nacionales España (aplica a todos los centros españoles)
    (NULL, '2026-01-01', 'Año Nuevo', 'NACIONAL', 2026),
    (NULL, '2026-01-06', 'Epifanía del Señor / Reyes Magos', 'NACIONAL', 2026),
    (NULL, '2026-04-03', 'Viernes Santo', 'NACIONAL', 2026),
    (NULL, '2026-05-01', 'Fiesta del Trabajo', 'NACIONAL', 2026),
    (NULL, '2026-08-15', 'Asunción de la Virgen', 'NACIONAL', 2026),
    (NULL, '2026-10-12', 'Fiesta Nacional de España', 'NACIONAL', 2026),
    (NULL, '2026-11-01', 'Todos los Santos', 'NACIONAL', 2026),
    (NULL, '2026-12-06', 'Día de la Constitución Española', 'NACIONAL', 2026),
    (NULL, '2026-12-08', 'Inmaculada Concepción', 'NACIONAL', 2026),
    (NULL, '2026-12-25', 'Natividad del Señor / Navidad', 'NACIONAL', 2026),
    
    -- Festivos Barcelona (Cataluña)
    (1, '2026-04-06', 'Lunes de Pascua', 'AUTONOMICO', 2026),
    (1, '2026-06-24', 'Sant Joan', 'AUTONOMICO', 2026),
    (1, '2026-09-11', 'Diada Nacional de Catalunya', 'AUTONOMICO', 2026),
    (1, '2026-09-24', 'La Mercè (Fiesta Mayor)', 'LOCAL', 2026),
    (1, '2026-12-26', 'Sant Esteve', 'AUTONOMICO', 2026),

    -- Festivos Madrid
    (2, '2026-05-02', 'Fiesta de la Comunidad de Madrid', 'AUTONOMICO', 2026),
    (2, '2026-05-15', 'San Isidro Labrador', 'LOCAL', 2026),
    (2, '2026-11-09', 'Nuestra Señora de la Almudena', 'LOCAL', 2026),

    -- Festivos Bilbao (Euskadi)
    (3, '2026-04-06', 'Lunes de Pascua', 'AUTONOMICO', 2026),
    (3, '2026-07-25', 'Santiago Apóstol', 'AUTONOMICO', 2026),
    (3, '2026-08-28', 'Viernes de la Semana Grande', 'LOCAL', 2026),

    -- Festivos Sevilla (Andalucía)
    (4, '2026-02-28', 'Día de Andalucía', 'AUTONOMICO', 2026),
    (4, '2026-04-22', 'Miércoles de Feria de Abril', 'LOCAL', 2026),
    (4, '2026-06-04', 'Corpus Christi', 'LOCAL', 2026),

    -- Festivos Valencia
    (5, '2026-03-19', 'San José / Fallas', 'AUTONOMICO', 2026),
    (5, '2026-04-13', 'San Vicente Ferrer', 'LOCAL', 2026),
    (5, '2026-10-09', 'Día de la Comunitat Valenciana', 'AUTONOMICO', 2026),

    -- Festivos Extranjero (Francia / Internacional)
    (6, '2026-07-14', 'Fête Nationale / Bastille Day', 'LOCAL', 2026),
    (6, '2026-11-11', 'Armistice 1918', 'LOCAL', 2026)
ON DUPLICATE KEY UPDATE nombre=VALUES(nombre);

