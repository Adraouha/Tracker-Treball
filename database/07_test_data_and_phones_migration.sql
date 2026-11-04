-- ============================================================================
-- MIGRACION 07: ANONIMIZACION DE DATOS DE PRUEBA (TEST DATA & RANDOM 9-DIGIT PHONES)
-- Reemplaza apellidos por 'Test' y asigna teléfonos irreales aleatorios de 9 números.
-- ============================================================================

-- 1. Actualización de Plantilla (Employees) con Apellidos Test y Teléfonos Aleatorios (6XXXXXXXX)
UPDATE employees SET nombre = 'Hassan Test', telefono = '611315578', email = 'hassan.test@trackertreball.com' WHERE id = 1;
UPDATE employees SET nombre = 'Albert G. Test', telefono = '622908338', email = 'albert.guiteras.test@trackertreball.com' WHERE id = 2;
UPDATE employees SET nombre = 'Albert P. Test', telefono = '633513195', email = 'albert.profe.test@trackertreball.com' WHERE id = 3;
UPDATE employees SET nombre = 'Alba G. Test', telefono = '644678530', email = 'alba.garcia.test@trackertreball.com' WHERE id = 4;
UPDATE employees SET nombre = 'Jose Daniel Test', telefono = '655648546', email = 'josedaniel.test@trackertreball.com' WHERE id = 5;
UPDATE employees SET nombre = 'Alba S. Test', telefono = '666885775', email = 'alba.sanz.test@trackertreball.com' WHERE id = 6;
UPDATE employees SET nombre = 'Aldana Test', telefono = '677247753', email = 'aldana.test@trackertreball.com' WHERE id = 7;
UPDATE employees SET nombre = 'Barbara Test', telefono = '688916043', email = 'barbara.test@trackertreball.com' WHERE id = 8;
UPDATE employees SET nombre = 'David Test', telefono = '699976855', email = 'david.test@trackertreball.com' WHERE id = 9;
UPDATE employees SET nombre = 'Eduardo Test', telefono = '614899779', email = 'eduardo.test@trackertreball.com' WHERE id = 10;
UPDATE employees SET nombre = 'Elena Test', telefono = '625647958', email = 'elena.test@trackertreball.com' WHERE id = 11;
UPDATE employees SET nombre = 'Gabriel Test', telefono = '636646638', email = 'gabriel.test@trackertreball.com' WHERE id = 12;
UPDATE employees SET nombre = 'Hector Test', telefono = '647676035', email = 'hector.test@trackertreball.com' WHERE id = 13;
UPDATE employees SET nombre = 'Ingrid Test', telefono = '658873730', email = 'ingrid.test@trackertreball.com' WHERE id = 14;
UPDATE employees SET nombre = 'Luiggi Test', telefono = '669611249', email = 'luiggi.test@trackertreball.com' WHERE id = 15;
UPDATE employees SET nombre = 'Marc Test', telefono = '670969556', email = 'marc.test@trackertreball.com' WHERE id = 16;
UPDATE employees SET nombre = 'Michael Xavier Test', telefono = '681327411', email = 'michael.xavier.test@trackertreball.com' WHERE id = 17;
UPDATE employees SET nombre = 'Mohammed Test', telefono = '692560987', email = 'mohammed.test@trackertreball.com' WHERE id = 18;
UPDATE employees SET nombre = 'Roger Test', telefono = '603941537', email = 'roger.test@trackertreball.com' WHERE id = 19;
UPDATE employees SET nombre = 'Silvia Test', telefono = '615966837', email = 'silvia.test@trackertreball.com' WHERE id = 20;
UPDATE employees SET nombre = 'YingYing Test', telefono = '626876406', email = 'yingying.test@trackertreball.com' WHERE id = 21;
UPDATE employees SET nombre = 'Usuario Prueba Test', telefono = '637510893', email = 'prueba.test@trackertreball.com' WHERE id = 25;

-- 2. Actualización de Solicitudes de Vacaciones
UPDATE vacation_requests SET employee_name = 'Hassan Test' WHERE employee_id = 1;
UPDATE vacation_requests SET employee_name = 'Alba G. Test' WHERE employee_id = 4;
UPDATE vacation_requests SET employee_name = 'Elena Test' WHERE employee_id = 11;
UPDATE vacation_requests SET employee_name = 'David Test' WHERE employee_id = 9;
UPDATE vacation_requests SET employee_name = 'Albert G. Test' WHERE employee_id = 2;
UPDATE vacation_requests SET reviewer_name = 'Hassan Test' WHERE reviewer_name = 'Hassan Adraou';

-- 3. Actualización de Bajas Médicas
UPDATE medical_leaves SET employee_name = 'Roger Test' WHERE employee_id = 19;
