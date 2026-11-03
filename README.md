# Tracker Treball - Control Horario, Gestion de Empleados y PRL

Autor: Hassan Adraou
Tecnologias: Java 17, Spring Boot 3, MySQL 8, Node.js (servidor ligero de desarrollo), HTML5, CSS3, JavaScript modular.

---

## 1. Descripcion del Proyecto

Tracker Treball es una plataforma SaaS de gestion de personal, control horario y prevencion de riesgos laborales (PRL) disenada para cumplir la normativa laboral y ofrecer una experiencia de usuario limpia, humana y profesional.

El diseno visual sigue las especificaciones de Figma del proyecto:
- Paleta institucional con color primario granate `#A7333A` y fondos suaves.
- Tipografia Inter y Montserrat.
- Tarjetas Bento Grid limpias y espacios amplios.
- Soporte bilingue (Catalan y Castellano) y modo oscuro integrado.

---

## 2. Estructura del Proyecto

```text
Tracker-Treball/
├── backend/                  <-- Servicios de Backend
│   ├── src/main/java/        <-- Codigo fuente Spring Boot 3 (Arquitectura Hexagonal)
│   ├── src/main/resources/   <-- Configuracion y recursos i18n
│   ├── pom.xml               <-- Descriptor de proyecto Maven
│   └── server.js             <-- Servidor Node.js ligero para desarrollo y pruebas
├── frontend/                 <-- Interfaz de Usuario
│   ├── assets/               <-- Logotipos oficiales recortados y recursos graficos
│   ├── css/
│   │   └── estilos.css       <-- Estilos limpios, accesibles y responsivos
│   ├── js/
│   │   ├── api.js            <-- Cliente API centralizado y fixtures de prueba
│   │   └── app.js            <-- Controlador modular de vistas, temporizadores y eventos
│   └── index.html            <-- Marcado semantico (Login, Dashboard, Empleados, PRL)
├── database/                 <-- Base de Datos MySQL
│   ├── 01_schema_tracker_treball.sql    <-- DDL de tablas e indices
│   └── 02_data_seed_tracker_treball.sql  <-- Fixtures de prueba del Sprint 3
├── docs/                     <-- Documentacion Tecnica
│   ├── prl_help_center_specification.md
│   └── tracker_treball_smart_work_assistant.md
└── README.md
```

---

## 3. Puesta en Marcha Rapida

### Opcion A: Servidor Ligero de Desarrollo (Inmediato)
1. Abrir terminal en la raiz del proyecto y ejecutar:
   ```bash
   node backend/server.js
   ```
2. Abrir en el navegador:
   `http://localhost:8080/`
3. La aplicacion cargara con los datos de prueba y todos los endpoints activos.

### Opcion B: Backend Spring Boot con Base de Datos MySQL
1. Importar los scripts SQL en MySQL:
   ```sql
   SOURCE database/01_schema_tracker_treball.sql;
   SOURCE database/02_data_seed_tracker_treball.sql;
   ```
2. Iniciar el servicio Spring Boot:
   ```bash
   cd backend
   mvn spring-boot:run
   ```
3. Abrir `frontend/index.html` en el navegador.

---

## 4. Endpoints de la API REST

| Metodo | Endpoint | Descripcion |
| :--- | :--- | :--- |
| POST | `/api/v1/auth/login` | Autenticacion de usuario y emision de token |
| GET | `/api/v1/employees` | Listado de empleados y metricas del equipo |
| POST | `/api/v1/employees` | Alta de nuevo empleado |
| GET | `/api/v1/dashboard/assistant` | Datos de la jornada, trafico y productividad |
| POST | `/api/v1/attendance/toggle-break` | Iniciar o pausar descanso de jornada |
| POST | `/api/v1/attendance/clock-out` | Cierre de jornada con firma hash SHA-256 |
| POST | `/api/v1/prl/sos` | Notificacion inmediata de emergencia |
| POST | `/api/v1/prl/incidents` | Registro de incidente preventivo |

---

## 5. Datos de Prueba Incluidos

- Empleados de prueba: 8 perfiles con datos representativos de desarrollo (Laura Serra, Marc Puig, Anna Soler, Jordi Vila, Nuria Costa, Pau Roca, Marta Vidal, David Ferrer).
- Jornada laboral: 08:57 a 17:30 con calculo automatico de horas y pausas.
- Prevencion PRL: Alerta meteorologica en Osona / Vic con recomendaciones de seguridad y protocolo PAS (Proteger, Avisar, Socorrer).
