-- ============================================================================
-- MIGRACION 05: CENTROS DE TRABAJO EXTENDIDOS, REASIGNACION ESTRICTA,
-- TABLA DE VACACIONES Y TABLA DE BAJAS MEDICAS
-- ============================================================================

-- 1. Añadir columnas a work_centers
ALTER TABLE work_centers ADD COLUMN codigo_centro VARCHAR(20) DEFAULT 'CT-01';
ALTER TABLE work_centers ADD COLUMN telefono VARCHAR(30) DEFAULT '+34 93 456 78 90';
ALTER TABLE work_centers ADD COLUMN horario VARCHAR(80) DEFAULT 'Lunes a Viernes 08:00 - 18:00';

UPDATE work_centers SET codigo_centro = 'CT-01', telefono = '+34 93 456 78 90', horario = 'Lunes a Viernes 08:00 - 18:30' WHERE id = 1;
UPDATE work_centers SET codigo_centro = 'CT-02', telefono = '+34 91 567 89 01', horario = 'Lunes a Viernes 08:30 - 18:00' WHERE id = 2;
UPDATE work_centers SET codigo_centro = 'CT-03', telefono = '+34 94 412 34 56', horario = 'Lunes a Viernes 08:00 - 17:30' WHERE id = 3;
UPDATE work_centers SET codigo_centro = 'CT-04', telefono = '+34 95 498 76 54', horario = 'Lunes a Viernes 08:00 - 17:00' WHERE id = 4;
UPDATE work_centers SET codigo_centro = 'CT-05', telefono = '+34 96 345 67 89', horario = 'Lunes a Viernes 08:30 - 18:00' WHERE id = 5;
UPDATE work_centers SET codigo_centro = 'CT-INT-01', telefono = '+33 1 42 68 55 00', horario = 'Lunes a Viernes 09:00 - 18:00 (CET)' WHERE id = 6;

-- 2. Limpieza de empleados temporales de test
DELETE FROM user_credentials WHERE employee_id > 21;
DELETE FROM attendance_records WHERE employee_id > 21;
DELETE FROM employees WHERE id > 21;

-- 3. Reasignacion estricta segun requerimiento:
-- Barcelona (Sede Central): exactamente 3 miembros existentes (Hassan, Albert G., Albert P.)
UPDATE employees SET centro_trabajo = 'Barcelona', work_center_id = 1 WHERE id IN (1, 2, 3);

-- Madrid: 4 miembros
UPDATE employees SET centro_trabajo = 'Madrid', work_center_id = 2 WHERE id IN (4, 5, 6, 7);

-- Bilbao: 4 miembros
UPDATE employees SET centro_trabajo = 'Bilbao', work_center_id = 3 WHERE id IN (8, 9, 10, 11);

-- Sevilla: 4 miembros
UPDATE employees SET centro_trabajo = 'Sevilla', work_center_id = 4 WHERE id IN (12, 13, 16, 17);

-- Valencia: 3 miembros
UPDATE employees SET centro_trabajo = 'Valencia', work_center_id = 5 WHERE id IN (14, 15, 20);

-- Extranjero: 3 miembros
UPDATE employees SET centro_trabajo = 'Extranjero', work_center_id = 6 WHERE id IN (18, 19, 21);

-- 4. Crear tabla de vacaciones (vacation_requests)
CREATE TABLE IF NOT EXISTS vacation_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    employee_name VARCHAR(120) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days_count INT NOT NULL DEFAULT 1,
    type VARCHAR(60) NOT NULL DEFAULT 'Vacaciones Anuales',
    reason VARCHAR(255) NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    reviewer_name VARCHAR(120) NULL,
    review_note VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_vac_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insercion de solicitudes de vacaciones iniciales representativas
INSERT INTO vacation_requests (employee_id, employee_name, start_date, end_date, days_count, type, reason, status, reviewer_name, review_note)
VALUES 
(1, 'Hassan Adraou', '2026-12-21', '2026-12-24', 4, 'Vacaciones Anuales', 'Descanso de fin de año', 'PENDING', NULL, NULL),
(4, 'Alba Garcia', '2026-11-16', '2026-11-20', 5, 'Vacaciones Anuales', 'Semana de desconexión familiar', 'PENDING', NULL, NULL),
(11, 'Elena Sanchez', '2026-11-02', '2026-11-09', 6, 'Vacaciones Anuales', 'Vacaciones autorizadas', 'APPROVED', 'Hassan Adraou', 'Aprobadas conforme a convenio'),
(9, 'David Velez', '2026-12-01', '2026-12-04', 4, 'Asuntos Propios', 'Gestiones personales', 'PENDING', NULL, NULL);

-- 5. Crear tabla de bajas medicas (medical_leaves)
CREATE TABLE IF NOT EXISTS medical_leaves (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    employee_name VARCHAR(120) NOT NULL,
    tipo VARCHAR(60) NOT NULL DEFAULT 'Enfermedad Común',
    fecha_inicio DATE NOT NULL,
    fecha_fin_prevista DATE NULL,
    fecha_alta_real DATE NULL,
    numero_colegiado VARCHAR(50) NULL,
    centro_salud VARCHAR(120) NULL,
    observaciones TEXT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_leave_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO medical_leaves (employee_id, employee_name, tipo, fecha_inicio, fecha_fin_prevista, numero_colegiado, centro_salud, observaciones, status)
VALUES
(19, 'Roger Umpiérrez', 'Enfermedad Común', '2026-10-25', '2026-11-15', 'COL-28491', 'CAP Sarrià - Barcelona', 'Reposo domiciliario y tratamiento farmacológico', 'ACTIVA');
