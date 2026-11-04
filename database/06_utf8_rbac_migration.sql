-- ============================================================================
-- SCRIPT DE MIGRACION: UTF-8mb4, RBAC Y LIMPIEZA DE DATOS CORRUPTOS
-- Proyecto: Tracker Treball SaaS
-- Autor: Hassan Adraou
-- ============================================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 1. Asegurar codificacion utf8mb4 en la base de datos y tablas
ALTER DATABASE railway CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

ALTER TABLE employees CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE work_centers CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE work_center_holidays CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE vacation_requests CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE medical_leaves CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE projects CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE attendance_records CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE break_records CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE user_credentials CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
ALTER TABLE safety_alerts CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2. Añadir columna 'rol' en employees si no existe
DROP PROCEDURE IF EXISTS AddRolColumn;
DELIMITER $$
CREATE PROCEDURE AddRolColumn()
BEGIN
    IF NOT EXISTS (
        SELECT * FROM information_schema.COLUMNS 
        WHERE TABLE_SCHEMA = 'railway' AND TABLE_NAME = 'employees' AND COLUMN_NAME = 'rol'
    ) THEN
        ALTER TABLE employees ADD COLUMN rol VARCHAR(20) NOT NULL DEFAULT 'EMPLOYEE';
    END IF;
END $$
DELIMITER ;
CALL AddRolColumn();
DROP PROCEDURE IF EXISTS AddRolColumn;

-- 3. Configurar roles RBAC iniciales
-- Rol ADMIN (Director General / Administrador total)
UPDATE employees SET rol = 'ADMIN' WHERE id = 1 OR email = 'hassan.adraou@test.es';

-- Rol MANAGER (Responsables de equipo y supervision)
UPDATE employees SET rol = 'MANAGER' WHERE id IN (2, 3, 4, 8, 12, 14);

-- Rol EMPLOYEE (Resto de la plantilla)
UPDATE employees SET rol = 'EMPLOYEE' WHERE rol IS NULL OR rol NOT IN ('ADMIN', 'MANAGER');

-- 4. Corregir caracteres corruptos en work_center_holidays
UPDATE work_center_holidays SET nombre = 'Año Nuevo' WHERE id = 1 OR nombre LIKE 'A??o Nuevo';
UPDATE work_center_holidays SET nombre = 'Epifanía del Señor / Reyes Magos' WHERE id = 2 OR nombre LIKE '%Epifan%';
UPDATE work_center_holidays SET nombre = 'Viernes Santo' WHERE id = 3;
UPDATE work_center_holidays SET nombre = 'Lunes de Pascua' WHERE id = 11;
UPDATE work_center_holidays SET nombre = 'Fiesta del Trabajo' WHERE id = 4;
UPDATE work_center_holidays SET nombre = 'Fiesta de la Comunidad de Madrid' WHERE id = 16;
UPDATE work_center_holidays SET nombre = 'San Isidro Labrador' WHERE id = 17;
UPDATE work_center_holidays SET nombre = 'Sant Joan' WHERE id = 12;
UPDATE work_center_holidays SET nombre = 'Asunción de la Virgen' WHERE id = 5 OR nombre LIKE '%Asunci%';
UPDATE work_center_holidays SET nombre = 'Diada Nacional de Catalunya' WHERE id = 13;
UPDATE work_center_holidays SET nombre = 'La Mercè (Fiesta Mayor)' WHERE id = 14 OR nombre LIKE '%Merc%';
UPDATE work_center_holidays SET nombre = 'Fiesta Nacional de España' WHERE id = 6 OR nombre LIKE '%Espa%';
UPDATE work_center_holidays SET nombre = 'Todos los Santos' WHERE id = 7;
UPDATE work_center_holidays SET nombre = 'Nuestra Señora de la Almudena' WHERE id = 18 OR nombre LIKE '%Almudena%';
UPDATE work_center_holidays SET nombre = 'Día de la Constitución Española' WHERE id = 8 OR nombre LIKE '%Constituci%';
UPDATE work_center_holidays SET nombre = 'Inmaculada Concepción' WHERE id = 9 OR nombre LIKE '%Inmaculada%';
UPDATE work_center_holidays SET nombre = 'Natividad del Señor / Navidad' WHERE id = 10;
UPDATE work_center_holidays SET nombre = 'Sant Esteve' WHERE id = 15;

-- 5. Corregir caracteres corruptos en work_centers
UPDATE work_centers SET 
    comunidad_autonoma = 'Cataluña',
    direccion = 'Avinguda Diagonal 450, 08006 Barcelona'
WHERE id = 1;

UPDATE work_centers SET 
    comunidad_autonoma = 'Comunidad de Madrid',
    direccion = 'Paseo de la Castellana 120, 28046 Madrid'
WHERE id = 2;

UPDATE work_centers SET 
    comunidad_autonoma = 'País Vasco',
    direccion = 'Gran Vía de Don Diego López de Haro 32, 48009 Bilbao'
WHERE id = 3;

UPDATE work_centers SET 
    comunidad_autonoma = 'Andalucía',
    direccion = 'Avenida de la Constitución 18, 41004 Sevilla'
WHERE id = 4;

UPDATE work_centers SET 
    comunidad_autonoma = 'Comunidad Valenciana',
    direccion = 'Carrer de Colón 24, 46004 Valencia'
WHERE id = 5;

UPDATE work_centers SET 
    ciudad = 'París',
    comunidad_autonoma = 'Internacional',
    direccion = 'Boulevard Haussmann 88, 75008 París'
WHERE id = 6;

-- 6. Corregir caracteres corruptos en employees
UPDATE employees SET nombre = 'Roger Umpiérrez' WHERE id = 19 OR nombre LIKE 'Roger Umpi%';

-- 7. Corregir caracteres corruptos en medical_leaves
UPDATE medical_leaves SET 
    employee_name = 'Roger Umpiérrez',
    tipo = 'Enfermedad Común',
    centro_salud = 'CAP Sarrià - Barcelona',
    observaciones = 'Reposo domiciliario y tratamiento farmacológico'
WHERE id = 1;

-- 8. Corregir caracteres corruptos en vacation_requests
UPDATE vacation_requests SET 
    reason = 'Descanso de fin de año' 
WHERE id = 1;

UPDATE vacation_requests SET 
    reason = 'Semana de desconexión familiar' 
WHERE id = 2;

-- 9. Verificar estado final
SELECT 'Migration Complete' AS Status;

