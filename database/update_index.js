const fs = require('fs');
const path = require('path');

const indexPath = path.join(__dirname, '..', 'frontend', 'index.html');
let html = fs.readFileSync(indexPath, 'utf8');

// 1. Remove environment metadata
html = html.replace(
  /<span style="color: var\(--success\); font-weight: 600;">\s*[●?]\s*Conectado a Railway MySQL<\/span>/g,
  '<span style="color: var(--text-muted);"> · Estado del Servicio: <strong style="color: var(--success);">Operativo</strong></span>'
);

// 2. Replace raw SHA debug traces with elegant verified signature badges
html = html.replace(
  /<td><span style="font-family: monospace; font-size: 0\.75rem; color: var\(--text-muted\);">SHA: [^<]+<\/span><\/td>/g,
  '<td><span class="badge-signature"><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path></svg> Firma Digital Válida</span></td>'
);

// 3. Security string in profile
html = html.replace(
  /Algoritme SHA-256 Activat · Sessió X\.509 Segura/g,
  'Firma Digital Segura Activa (Auditoría Legal)'
);

// 4. Add interactive RBAC role switcher in navbar
if (!html.includes('id="select-active-role"')) {
  const targetUserBadge = '<div class="user-badge" id="user-badge-profile"';
  const roleSelectorHtml = `<!-- Selector interactivo de Rol RBAC -->
        <div class="rbac-role-selector-wrap" title="Cambiar rol activo para pruebas de permisos (RBAC)">
          <span class="rbac-role-label">ROL RBAC:</span>
          <select id="select-active-role" class="rbac-role-dropdown" aria-label="Seleccionar Rol RBAC">
            <option value="ADMIN" selected>ADMIN (Director General)</option>
            <option value="MANAGER">MANAGER (Responsable)</option>
            <option value="EMPLOYEE">EMPLEADO</option>
          </select>
        </div>

        `;
  html = html.replace(targetUserBadge, roleSelectorHtml + targetUserBadge);
}

// 5. Add Sidebar "DIRECCIÓN Y GOBERNANZA" section
if (!html.includes('id="nav-btn-admin-panel"')) {
  const targetCentros = `            <!-- Centros de Trabajo Oficiales -->
            <button id="nav-btn-centros" class="sidebar-link" type="button">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 21h18"></path>
                <path d="M5 21V7l8-4v18"></path>
                <path d="M19 21V11l-6-4"></path>
                <line x1="9" y1="9" x2="9" y2="9.01"></line>
                <line x1="9" y1="13" x2="9" y2="13.01"></line>
                <line x1="9" y1="17" x2="9" y2="17.01"></line>
              </svg>
              <span data-i18n="nav.workCenters">Centros de Trabajo</span>
            </button>
          </nav>`;

  const adminSidebarHtml = `            <!-- Centros de Trabajo Oficiales -->
            <button id="nav-btn-centros" class="sidebar-link" type="button">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M3 21h18"></path>
                <path d="M5 21V7l8-4v18"></path>
                <path d="M19 21V11l-6-4"></path>
                <line x1="9" y1="9" x2="9" y2="9.01"></line>
                <line x1="9" y1="13" x2="9" y2="13.01"></line>
                <line x1="9" y1="17" x2="9" y2="17.01"></line>
              </svg>
              <span data-i18n="nav.workCenters">Centros de Trabajo</span>
            </button>
          </nav>

          <!-- Seccion de Administracion y Direccion General (RBAC Admin) -->
          <div class="sidebar-heading rbac-admin-only" style="margin-top: 18px;">DIRECCIÓN Y GOBERNANZA</div>
          <nav class="sidebar-menu rbac-admin-only">
            <button id="nav-btn-admin-panel" class="sidebar-link link-admin-panel" type="button">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"></rect>
                <line x1="8" y1="21" x2="16" y2="21"></line>
                <line x1="12" y1="17" x2="12" y2="21"></line>
              </svg>
              <span>Panel Director General</span>
            </button>

            <button id="nav-btn-db-visor" class="sidebar-link link-db-visor" type="button">
              <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <ellipse cx="12" cy="5" rx="9" ry="3"></ellipse>
                <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"></path>
                <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"></path>
              </svg>
              <span>Gestor Visual BD</span>
            </button>
          </nav>`;

  html = html.replace(targetCentros, adminSidebarHtml);
}

// 6. Update view-empleados filter pills
html = html.replace(
  /<button id="tab-emp-all" class="emp-tab-pill active" type="button">Todos los empleados · 21<\/button>\s*<button id="tab-emp-active" class="emp-tab-pill red-count" type="button">Activos · 19<\/button>\s*<button id="tab-emp-archived" class="emp-tab-pill red-count" type="button">Archivados · 0<\/button>/,
  `<button id="tab-emp-all" class="emp-tab-pill active" type="button">Todos · 21</button>
            <button id="tab-emp-active" class="emp-tab-pill" type="button">Activos · 19</button>
            <button id="tab-emp-leaves" class="emp-tab-pill" type="button">De baja · 1</button>
            <button id="tab-emp-vacations" class="emp-tab-pill" type="button">De vacaciones · 1</button>
            <button id="tab-emp-archived" class="emp-tab-pill" type="button">Archivados · 0</button>`
);

// 7. Add user context filter pills in view-pausas
if (!html.includes('id="btn-pausas-context-my"')) {
  const targetPausasTable = '<div class="employees-table-card" style="margin-top: 20px;">';
  const pausasFilterHtml = `<div class="emp-tabs-row" style="margin-top: 18px; margin-bottom: 16px;">
            <button id="btn-pausas-context-my" class="emp-tab-pill active" type="button">Mis Pausas (Historial Semanal)</button>
            <button id="btn-pausas-context-team" class="emp-tab-pill rbac-manager-up" type="button">Mi Equipo</button>
            <button id="btn-pausas-context-all" class="emp-tab-pill rbac-admin-only" type="button">Toda la Organización</button>
          </div>
          `;
  html = html.replace(targetPausasTable, pausasFilterHtml + targetPausasTable);
}

// 8. Add Section view-admin-panel and view-db-visor
if (!html.includes('id="view-admin-panel"')) {
  const prlSectionEnd = '</section>\r\n\r\n      \r\n        <!-- Application Global Footer -->';
  const prlSectionEndLF = '</section>\n\n      \n        <!-- Application Global Footer -->';

  const newViewsHtml = `</section>

        <!-- =====================================================================
             FASE 3.1: PANEL DE SUPERVISION GLOBAL (DIRECTOR GENERAL / ADMIN)
             ===================================================================== -->
        <section id="view-admin-panel" class="subview" style="display: none;">
          <div class="emp-breadcrumb">
            <span>Organización</span> &rsaquo; <span class="active">Consola de Dirección General</span>
          </div>

          <div class="employees-top-bar">
            <div>
              <h1 class="emp-page-title">Consola de Supervisión Ejecutiva</h1>
              <p class="emp-page-sub">Panel de control integral para el Director General: aprobación de vacaciones, turnos, desviaciones y proyectos.</p>
            </div>
            <div style="display: flex; gap: 10px;">
              <button id="btn-admin-refresh" class="btn-clean btn-clean-primary" type="button">
                <span>Refrescar Datos</span>
              </button>
              <button id="btn-admin-open-db" class="btn-clean" style="background: #4F46E5; color: white; border: none; font-weight: 700;" type="button">
                <span>Abrir Gestor Visual BD</span>
              </button>
            </div>
          </div>

          <!-- 4 KPIs Ejecutivos -->
          <div class="admin-console-grid">
            <div class="emp-kpi-card">
              <div>
                <div class="emp-kpi-label">Vacaciones por Resolver</div>
                <div class="emp-kpi-number" id="kpi-admin-pending-vac" style="color: #D97706;">2</div>
                <div class="emp-kpi-note green">Aprobación, ajustes o rechazo directo</div>
              </div>
              <div class="emp-kpi-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                  <line x1="16" y1="2" x2="16" y2="6"></line>
                  <line x1="8" y1="2" x2="8" y2="6"></line>
                  <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
              </div>
            </div>

            <div class="emp-kpi-card">
              <div>
                <div class="emp-kpi-label">Plantilla Total Activa</div>
                <div class="emp-kpi-number">19 / 21</div>
                <div class="emp-kpi-note">En 6 centros de trabajo oficiales</div>
              </div>
              <div class="emp-kpi-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                  <circle cx="9" cy="7" r="4"></circle>
                </svg>
              </div>
            </div>

            <div class="emp-kpi-card">
              <div>
                <div class="emp-kpi-label">Desviaciones de Pausas</div>
                <div class="emp-kpi-number" style="color: #DC2626;">+15 min</div>
                <div class="emp-kpi-note">Cómputo adicional registrado</div>
              </div>
              <div class="emp-kpi-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <circle cx="12" cy="12" r="10"></circle>
                  <line x1="12" y1="8" x2="12" y2="12"></line>
                  <line x1="12" y1="16" x2="12.01" y2="16"></line>
                </svg>
              </div>
            </div>

            <div class="emp-kpi-card">
              <div>
                <div class="emp-kpi-label">Proyectos en Ejecución</div>
                <div class="emp-kpi-number">6</div>
                <div class="emp-kpi-note green">100% de sprints al día</div>
              </div>
              <div class="emp-kpi-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"></path>
                </svg>
              </div>
            </div>
          </div>

          <!-- Modulo 1: Resolucion Agil de Vacaciones -->
          <div class="admin-card">
            <div class="admin-card-header">
              <h2 class="admin-card-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="4" width="18" height="18" rx="2" ry="2"></rect>
                  <line x1="16" y1="2" x2="16" y2="6"></line>
                  <line x1="8" y1="2" x2="8" y2="6"></line>
                  <line x1="3" y1="10" x2="21" y2="10"></line>
                </svg>
                Gestión Ágil de Vacaciones (Aprobar, Rechazar o Pedir Ajustes)
              </h2>
              <span class="tt-badge tt-badge-warning" id="admin-vac-badge-count">Pendientes de revisión</span>
            </div>
            <div class="tt-table-container">
              <table class="tt-table">
                <thead>
                  <tr>
                    <th>Empleado</th>
                    <th>Centro</th>
                    <th>Período Solicitado</th>
                    <th>Días</th>
                    <th>Tipo</th>
                    <th>Estado Actual</th>
                    <th>Acción del Director</th>
                  </tr>
                </thead>
                <tbody id="tbody-admin-vacations">
                  <!-- Se llena dinamicamente -->
                </tbody>
              </table>
            </div>
          </div>

          <!-- Modulo 2: Turnos y Asignaciones Globales -->
          <div class="admin-card">
            <div class="admin-card-header">
              <h2 class="admin-card-title">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"></path>
                </svg>
                Supervisión Global de Turnos, Proyectos y Horas
              </h2>
            </div>
            <div class="tt-table-container">
              <table class="tt-table">
                <thead>
                  <tr>
                    <th>Departamento / Área</th>
                    <th>Responsable (Manager)</th>
                    <th>Centro Sede</th>
                    <th>Personal Asignado</th>
                    <th>Horas Imputadas</th>
                    <th>Estado de Cumplimiento</th>
                  </tr>
                </thead>
                <tbody id="tbody-admin-shifts-summary">
                  <tr>
                    <td><strong>Tecnología & Producto</strong></td>
                    <td>Albert Guiteras</td>
                    <td>Barcelona</td>
                    <td>8 empleados</td>
                    <td>312 h / mes</td>
                    <td><span class="tt-badge tt-badge-success">Excelente (98%)</span></td>
                  </tr>
                  <tr>
                    <td><strong>Operaciones & Soporte</strong></td>
                    <td>Jose Daniel Calicchio</td>
                    <td>Madrid</td>
                    <td>4 empleados</td>
                    <td>160 h / mes</td>
                    <td><span class="tt-badge tt-badge-success">En objetivo (95%)</span></td>
                  </tr>
                  <tr>
                    <td><strong>Personas, Talento & PRL</strong></td>
                    <td>Alba Garcia</td>
                    <td>Barcelona</td>
                    <td>4 empleados</td>
                    <td>155 h / mes</td>
                    <td><span class="tt-badge tt-badge-success">En objetivo (96%)</span></td>
                  </tr>
                  <tr>
                    <td><strong>Administración & Finanzas</strong></td>
                    <td>YingYing Xu</td>
                    <td>Extranjero</td>
                    <td>5 empleados</td>
                    <td>190 h / mes</td>
                    <td><span class="tt-badge tt-badge-success">En objetivo (97%)</span></td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </section>

        <!-- =====================================================================
             FASE 3.4: GESTOR VISUAL DE BASE DE DATOS (VISOR / ADMINER INTEGRADO)
             ===================================================================== -->
        <section id="view-db-visor" class="subview" style="display: none;">
          <div class="emp-breadcrumb">
            <span>Administración</span> &rsaquo; <span class="active">Gestor Visual de Base de Datos</span>
          </div>

          <div class="employees-top-bar">
            <div>
              <h1 class="emp-page-title">Gestor Visual de Base de Datos (Admin Visor)</h1>
              <p class="emp-page-sub">Consulta, añade, modifica y elimina registros directamente en la base de datos de manera segura y en tiempo real, sin recurrir a DBeaver.</p>
            </div>
            <div style="display: flex; gap: 10px;">
              <button id="btn-db-refresh" class="btn-clean btn-clean-primary" type="button">
                <span>Refrescar Tabla</span>
              </button>
              <button id="btn-db-add-row" class="btn-clean" style="background: #10B981; color: white; border: none; font-weight: 700;" type="button">
                <span>+ Añadir Registro</span>
              </button>
            </div>
          </div>

          <!-- Barra de Control del Visor -->
          <div class="db-visor-toolbar">
            <div class="db-visor-select-wrap">
              <label for="select-db-table" style="font-weight: 700; font-size: 0.88rem; color: var(--text-main);">Tabla Activa:</label>
              <select id="select-db-table" class="db-visor-select">
                <option value="employees">employees (Directorio de Empleados)</option>
                <option value="work_centers">work_centers (Centros de Trabajo)</option>
                <option value="work_center_holidays">work_center_holidays (Festivos Oficiales)</option>
                <option value="vacation_requests">vacation_requests (Solicitudes de Vacaciones)</option>
                <option value="medical_leaves">medical_leaves (Bajas Médicas)</option>
                <option value="projects">projects (Proyectos Asignados)</option>
                <option value="attendance_records">attendance_records (Fichajes de Jornada)</option>
                <option value="break_records">break_records (Pausas y Excesos)</option>
                <option value="safety_alerts">safety_alerts (Alertas PRL)</option>
              </select>
            </div>

            <div style="display: flex; align-items: center; gap: 8px;">
              <input type="text" id="input-db-search" class="login-input" placeholder="Buscar en tabla..." style="width: 240px; padding: 7px 12px; font-size: 0.84rem;">
              <span id="db-total-records-count" class="tt-badge tt-badge-neutral">0 registros</span>
            </div>
          </div>

          <!-- Contenedor de la Tabla Dinamica -->
          <div class="tt-table-container" id="db-table-scroll-container">
            <table class="tt-table" id="db-dynamic-table">
              <thead id="db-dynamic-thead">
                <!-- Se genera dinamicamente con las columnas de la tabla -->
              </thead>
              <tbody id="db-dynamic-tbody">
                <!-- Se llena con los datos recuperados -->
              </tbody>
            </table>
          </div>
        </section>
`;

  if (html.includes(prlSectionEnd)) {
    html = html.replace(prlSectionEnd, newViewsHtml + '\r\n\r\n        <!-- Application Global Footer -->');
  } else if (html.includes(prlSectionEndLF)) {
    html = html.replace(prlSectionEndLF, newViewsHtml + '\n\n        <!-- Application Global Footer -->');
  } else {
    // Fallback: search for <footer class="app-global-footer">
    html = html.replace('<footer class="app-global-footer">', newViewsHtml + '\n        <footer class="app-global-footer">');
  }
}

// 9. Add modal for DB Visor Add / Edit Row
if (!html.includes('id="modal-db-row"')) {
  const modalDbRowHtml = `
  <!-- MODAL: GESTOR VISUAL DE BD - AÑADIR / EDITAR REGISTRO -->
  <div id="modal-db-row" class="modal-overlay" style="display: none;">
    <div class="modal-card" style="max-width: 650px; max-height: 90vh; overflow-y: auto;">
      <div class="modal-header">
        <h2 class="modal-title" id="modal-db-row-title">Gestionar Registro en Base de Datos</h2>
        <button id="btn-close-db-row" class="btn-close-modal" type="button">&times;</button>
      </div>
      <form id="form-db-row" class="modal-body">
        <input type="hidden" id="inp-db-row-id">
        <input type="hidden" id="inp-db-row-mode" value="create">
        <div id="db-row-fields-container" style="display: flex; flex-direction: column; gap: 12px;">
          <!-- Campos generados dinamicamente segun la tabla -->
        </div>
        <div id="db-row-error" style="display: none; color: #dc2626; font-size: 0.85rem; margin-top: 10px; padding: 10px; background: #fee2e2; border-radius: 6px;"></div>
        <div class="modal-footer" style="margin-top: 20px; padding-top: 14px; border-top: 1px solid var(--border-color); display: flex; justify-content: flex-end; gap: 10px;">
          <button id="btn-cancel-db-row" class="btn-clean btn-clean-secondary" type="button">Cancelar</button>
          <button type="submit" id="btn-save-db-row" class="btn-clean btn-clean-primary" style="background: #10B981; border-color: #059669; font-weight: 700;">Guardar Registro</button>
        </div>
      </form>
    </div>
  </div>
`;

  html = html.replace('</body>', modalDbRowHtml + '\n</body>');
}

fs.writeFileSync(indexPath, html, 'utf8');
console.log('index.html updated successfully! Length:', html.length);
