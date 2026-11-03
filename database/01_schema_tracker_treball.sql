-- Script DDL de Creacion de Base de Datos para Tracker Treball
-- Motor: MySQL 8.0 Enterprise / UTF8MB4
-- Autor: Hassan Adraou

CREATE DATABASE IF NOT EXISTS tracker_treball_db 
    CHARACTER SET utf8mb4 
    COLLATE utf8mb4_unicode_ci;

USE tracker_treball_db;

-- 1. Tabla de Empleados
CREATE TABLE IF NOT EXISTS employees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    email VARCHAR(120) NOT NULL UNIQUE,
    departamento VARCHAR(80) NOT NULL,
    puesto VARCHAR(80) NOT NULL,
    centro_trabajo VARCHAR(100) NOT NULL DEFAULT 'Oficina Central Vic',
    rol VARCHAR(40) NOT NULL DEFAULT 'EMPLOYEE',
    estado VARCHAR(30) NOT NULL DEFAULT 'Activo',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Tabla de Usuarios y Autenticacion (RBAC)
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    username VARCHAR(80) NOT NULL UNIQUE,
    email VARCHAR(120) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    rol VARCHAR(40) NOT NULL DEFAULT 'EMPLOYEE',
    activo BOOLEAN NOT NULL DEFAULT TRUE,
    ultimo_acceso TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_employee FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Registro Principal de Jornadas Laborales
CREATE TABLE IF NOT EXISTS attendance_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    employee_id BIGINT NOT NULL,
    work_date DATE NOT NULL,
    clock_in_time TIMESTAMP NOT NULL,
    clock_out_time TIMESTAMP NULL,
    modality VARCHAR(30) NOT NULL DEFAULT 'PRESENCIAL',
    worked_minutes INT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN',
    record_hash VARCHAR(64) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_att_employee FOREIGN KEY (employee_id) REFERENCES employees(id),
    INDEX idx_emp_date (employee_id, work_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Registro de Pausas y Descansos
CREATE TABLE IF NOT EXISTS break_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    attendance_id BIGINT NOT NULL,
    break_type VARCHAR(30) NOT NULL DEFAULT 'PAUSA',
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP NULL,
    duration_minutes INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_break_att FOREIGN KEY (attendance_id) REFERENCES attendance_records(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. Tabla de Proyectos
CREATE TABLE IF NOT EXISTS projects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(120) NOT NULL,
    status VARCHAR(40) NOT NULL DEFAULT 'IN_PROGRESS',
    sprint_progress INT NOT NULL DEFAULT 0,
    team_members INT NOT NULL DEFAULT 1,
    dedicated_hours INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. Alertas Preventivas y Meteorologicas de Seguridad (PRL)
CREATE TABLE IF NOT EXISTS safety_alerts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source VARCHAR(40) NOT NULL DEFAULT 'AEMET',
    alert_level VARCHAR(20) NOT NULL DEFAULT 'WARNING',
    title VARCHAR(150) NOT NULL,
    message TEXT NOT NULL,
    effective_start TIMESTAMP NOT NULL,
    effective_end TIMESTAMP NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. Registro de Incidentes Preventivos
CREATE TABLE IF NOT EXISTS work_incidents (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reporter_employee_id BIGINT NOT NULL,
    incident_date TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    location VARCHAR(150) NOT NULL,
    hazard_description TEXT NOT NULL,
    suggested_action TEXT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'REPORTED',
    CONSTRAINT fk_inc_employee FOREIGN KEY (reporter_employee_id) REFERENCES employees(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
