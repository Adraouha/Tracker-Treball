const fs = require('fs');
const path = require('path');

const appJsPath = path.join(__dirname, '..', 'frontend', 'js', 'app.js');
let content = fs.readFileSync(appJsPath, 'utf8');

// 1. Update navigateTo to include admin-panel and db-visor
content = content.replace(
  'const views = ["dashboard", "empleados", "jornadas", "pausas", "vacaciones", "bajas", "proyectos", "centros", "prl"];',
  'const views = ["dashboard", "empleados", "jornadas", "pausas", "vacaciones", "bajas", "proyectos", "centros", "prl", "admin-panel", "db-visor"];'
);

// In navigateTo handler blocks:
const navTarget = `  } else if (viewName === "proyectos") {
    loadProjectsData();
  }`;

const navReplacement = `  } else if (viewName === "proyectos") {
    loadProjectsData();
  } else if (viewName === "admin-panel") {
    loadAdminPanelData();
  } else if (viewName === "db-visor") {
    loadDbVisorData();
  }`;

content = content.replace(navTarget, navReplacement);

// 2. Add new modules code before the DOMContentLoaded listener
const newModulesCode = `
// ============================================================================
// FASE 2: CONTROL DE ACCESO BASADO EN ROLES (RBAC) - LOGICA CLIENTE
// ============================================================================
function applyRolePermissions(targetRole) {
  const role = (targetRole || (AppState.currentUser && (AppState.currentUser.rol || AppState.currentUser.privilege)) || "ADMIN").toUpperCase();
  if (!AppState.currentUser) AppState.currentUser = { id: 1, name: "Hassan Adraou" };
  AppState.currentUser.rol = role;
  AppState.currentUser.privilege = role;

  // Actualizar selector en el navbar si existe
  const selectRole = document.getElementById("select-active-role");
  if (selectRole && selectRole.value !== role) {
    selectRole.value = role;
  }

  // Actualizar badge de texto de usuario
  const roleLabelMap = {
    ADMIN: "Director General (ADMIN)",
    MANAGER: "Manager / Responsable (MANAGER)",
    EMPLOYEE: "Empleado (EMPLEADO)"
  };
  const roleLabel = roleLabelMap[role] || role;
  const userRoleEl = document.getElementById("nav-user-role");
  if (userRoleEl) userRoleEl.textContent = roleLabel;

  // Control estricto de visibilidad por roles
  const adminOnlyEls = document.querySelectorAll(".rbac-admin-only");
  const managerUpEls = document.querySelectorAll(".rbac-manager-up");
  const newEmpBtn = document.getElementById("btn-modal-new-emp");

  if (role === "EMPLOYEE") {
    // Empleado: Solo ve y gestiona sus propios registros
    adminOnlyEls.forEach(el => el.style.setProperty("display", "none", "important"));
    managerUpEls.forEach(el => el.style.setProperty("display", "none", "important"));
    if (newEmpBtn) newEmpBtn.style.display = "none";
    document.querySelectorAll(".btn-delete-employee, .btn-archive-emp, .btn-permanent-delete").forEach(b => b.style.display = "none");
    if (AppState.currentView === "admin-panel" || AppState.currentView === "db-visor") {
      navigateTo("dashboard");
    }
  } else if (role === "MANAGER") {
    // Manager: Ve registros de su equipo, sin permiso de eliminacion fisica permanente
    adminOnlyEls.forEach(el => el.style.setProperty("display", "none", "important"));
    managerUpEls.forEach(el => el.style.removeProperty("display"));
    if (newEmpBtn) newEmpBtn.style.display = "inline-flex";
    document.querySelectorAll(".btn-permanent-delete").forEach(b => b.style.display = "none");
    if (AppState.currentView === "admin-panel" || AppState.currentView === "db-visor") {
      navigateTo("dashboard");
    }
  } else {
    // ADMIN: Control global total y CRUD completo
    adminOnlyEls.forEach(el => el.style.removeProperty("display"));
    managerUpEls.forEach(el => el.style.removeProperty("display"));
    if (newEmpBtn) newEmpBtn.style.display = "inline-flex";
    document.querySelectorAll(".btn-delete-employee, .btn-archive-emp, .btn-permanent-delete").forEach(b => b.style.removeProperty("display"));
  }

  // Refrescar la vista activa segun los nuevos permisos
  if (AppState.currentView === "pausas") loadBreaksData();
  else if (AppState.currentView === "vacaciones") loadVacationsData();
  else if (AppState.currentView === "empleados") filterEmployees();
}

// ============================================================================
// FASE 3.1: PANEL DE SUPERVISION GLOBAL (DIRECTOR GENERAL / ADMIN)
// ============================================================================
async function loadAdminPanelData() {
  const tbody = document.getElementById("tbody-admin-vacations");
  if (!tbody) return;

  tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:24px; color:var(--text-muted);">Cargando solicitudes ejecutivas...</td></tr>';

  try {
    const res = await apiGet("/vacations/requests");
    const allRequests = (res && (res.teamRequests || res.allRequests || res.myRequests)) || [];
    
    // Filtrar solicitudes que requieren atencion ejecutiva
    const pendingRequests = allRequests.filter(r => 
      r.status === "PENDING" || r.status === "PENDIENTE" || 
      r.status === "ADJUSTED" || r.status === "AJUSTE_SOLICITADO"
    );

    const kpiPending = document.getElementById("kpi-admin-pending-vac");
    const badgeCount = document.getElementById("admin-vac-badge-count");
    if (kpiPending) kpiPending.textContent = pendingRequests.length;
    if (badgeCount) badgeCount.textContent = pendingRequests.length + " solicitudes pendientes";

    if (pendingRequests.length === 0) {
      tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:30px; color:var(--text-muted);"><span class="tt-badge tt-badge-success">✓ Todas las solicitudes de vacaciones han sido resueltas</span></td></tr>';
      return;
    }

    const dSuffix = AppState.language === "ca" ? "dies" : "días";

    tbody.innerHTML = pendingRequests.map(r => {
      const isAdjust = r.status === "ADJUSTED" || r.status === "AJUSTE_SOLICITADO";
      const statusBadge = isAdjust
        ? '<span class="tt-badge tt-badge-warning">Ajuste Solicitado</span>'
        : '<span class="tt-badge tt-badge-warning">Pendiente Revisión</span>';

      return \`
        <tr>
          <td><strong>\${r.employeeName || "Empleado #" + r.employeeId}</strong></td>
          <td><span class="emp-center-badge">📍 \${r.workCenterName || "Barcelona"}</span></td>
          <td><strong>\${r.startDate} &rarr; \${r.endDate}</strong></td>
          <td><strong>\${r.daysCount}</strong> \${dSuffix}</td>
          <td><div><strong>\${r.type}</strong></div><div style="font-size:0.75rem; color:var(--text-muted);">\${r.reason || ""}</div></td>
          <td>\${statusBadge}</td>
          <td>
            <div style="display:flex; gap:6px;">
              <button type="button" class="btn-admin-action btn-admin-accept" onclick="handleAdminReviewVacation(\${r.id}, 'accept')" title="Aprobar inmediatamente">
                ✓ Aprobar
              </button>
              <button type="button" class="btn-admin-action btn-admin-adjust" onclick="handleAdminReviewVacation(\${r.id}, 'adjust')" title="Solicitar ajuste de fechas al empleado">
                ✎ Ajustes
              </button>
              <button type="button" class="btn-admin-action btn-admin-reject" onclick="handleAdminReviewVacation(\${r.id}, 'reject')" title="Rechazar solicitud con motivo">
                ✕ Rechazar
              </button>
            </div>
          </td>
        </tr>
      \`;
    }).join("");
  } catch (err) {
    tbody.innerHTML = '<tr><td colspan="7" style="text-align:center; padding:20px; color:#dc2626;">Error al cargar datos del panel ejecutivo.</td></tr>';
  }
}

async function handleAdminReviewVacation(id, action) {
  let note = "";
  if (action === "adjust") {
    note = prompt("Indica al empleado las fechas o días de ajuste sugeridos:", "Proponer retrasar 2 días por cierre de sprint");
    if (note === null) return;
  } else if (action === "reject") {
    note = prompt("Indica el motivo del rechazo:", "Coincidencia de fechas críticas con el equipo");
    if (note === null) return;
  }

  const reviewerName = AppState.currentUser ? AppState.currentUser.name : "Director General";
  const res = await apiPost('/vacations/requests/' + id + '/review', {
    action,
    note,
    reviewerName
  });

  if (res && res.status === "SUCCESS") {
    alert("✓ Solicitud de vacaciones gestionada correctamente por el Director General.");
    await loadAdminPanelData();
    if (AppState.currentView === "vacaciones") await loadVacationsData();
  } else {
    alert("Error al procesar la solicitud: " + ((res && res.error) || "Error de red"));
  }
}

// ============================================================================
// FASE 3.4: GESTOR VISUAL DE BASE DE DATOS (ADMIN VISOR / ADMINER INTEGRADO)
// ============================================================================
let currentDbTable = "employees";
let currentDbColumns = [];
let currentDbRows = [];

async function loadDbVisorData() {
  const select = document.getElementById("select-db-table");
  if (select) {
    currentDbTable = select.value || "employees";
  }
  await loadDbVisorTable(currentDbTable);
}

async function loadDbVisorTable(tableName) {
  currentDbTable = tableName;
  const thead = document.getElementById("db-dynamic-thead");
  const tbody = document.getElementById("db-dynamic-tbody");
  const countBadge = document.getElementById("db-total-records-count");
  if (!thead || !tbody) return;

  thead.innerHTML = '<tr><th style="padding:16px;">Cargando estructura de ' + tableName + '...</th></tr>';
  tbody.innerHTML = '<tr><td style="text-align:center; padding:30px; color:var(--text-muted);">Consultando base de datos en tiempo real...</td></tr>';

  try {
    const res = await apiGetAdminTableData(tableName, 100);
    if (!res || !res.rows) {
      tbody.innerHTML = '<tr><td style="text-align:center; padding:30px; color:var(--text-muted);">No se pudieron recuperar datos para la tabla ' + tableName + '.</td></tr>';
      return;
    }

    currentDbRows = res.rows || [];
    currentDbColumns = res.columns || [];

    if (countBadge) countBadge.textContent = currentDbRows.length + " registros";

    let theadHtml = "<tr>";
    currentDbColumns.forEach(c => {
      theadHtml += '<th><div>' + c.COLUMN_NAME + '</div><span class="db-col-badge">' + c.DATA_TYPE + '</span></th>';
    });
    theadHtml += '<th style="text-align:right;">Acciones CRUD</th></tr>';
    thead.innerHTML = theadHtml;

    renderDbVisorRows(currentDbRows);

  } catch (err) {
    tbody.innerHTML = '<tr><td style="text-align:center; padding:20px; color:#dc2626;">Error al consultar la tabla ' + tableName + ': ' + err.message + '</td></tr>';
  }
}

function renderDbVisorRows(rows) {
  const tbody = document.getElementById("db-dynamic-tbody");
  if (!tbody) return;

  if (rows.length === 0) {
    tbody.innerHTML = '<tr><td colspan="' + (currentDbColumns.length + 1) + '" style="text-align:center; padding:32px; color:var(--text-muted);">No hay registros en la tabla \\'' + currentDbTable + '\\'. Pulsa "+ Añadir Registro" para insertar uno nuevo.</td></tr>';
    return;
  }

  tbody.innerHTML = rows.map(row => {
    let cellsHtml = "";
    currentDbColumns.forEach(c => {
      let val = row[c.COLUMN_NAME];
      if (val === null || val === undefined) {
        val = '<span style="color:var(--text-muted); font-style:italic;">NULL</span>';
      } else if (typeof val === "boolean" || c.DATA_TYPE === "tinyint") {
        val = val ? '<span class="tt-badge tt-badge-success">true</span>' : '<span class="tt-badge tt-badge-neutral">false</span>';
      } else if (typeof val === "string" && val.length > 40) {
        val = '<span title="' + String(val).replace(/"/g, '&quot;') + '">' + String(val).substring(0, 38) + '...</span>';
      }
      cellsHtml += '<td>' + val + '</td>';
    });

    const rowId = row.id || row.ID || 0;
    return \`
      <tr>
        \${cellsHtml}
        <td style="text-align:right; white-space:nowrap;">
          <button type="button" class="btn-clean" style="padding:4px 8px; font-size:0.75rem; background:#3B82F6; color:white; border:none; margin-right:4px;" onclick="openDbRowModal('edit', \${rowId})">
            ✎ Editar
          </button>
          <button type="button" class="btn-clean" style="padding:4px 8px; font-size:0.75rem; background:#EF4444; color:white; border:none;" onclick="handleDbRowDelete(\${rowId})">
            ✕ Borrar
          </button>
        </td>
      </tr>
    \`;
  }).join("");
}

function openDbRowModal(mode, rowId = null) {
  const modal = document.getElementById("modal-db-row");
  const title = document.getElementById("modal-db-row-title");
  const container = document.getElementById("db-row-fields-container");
  const modeInp = document.getElementById("inp-db-row-mode");
  const idInp = document.getElementById("inp-db-row-id");
  const errorEl = document.getElementById("db-row-error");

  if (!modal || !container) return;
  if (errorEl) errorEl.style.display = "none";

  modeInp.value = mode;
  idInp.value = rowId || "";

  let rowData = {};
  if (mode === "edit" && rowId) {
    rowData = currentDbRows.find(r => r.id == rowId) || {};
    title.textContent = "Modificar Registro #" + rowId + " en '" + currentDbTable + "'";
  } else {
    title.textContent = "Añadir Nuevo Registro en '" + currentDbTable + "'";
  }

  container.innerHTML = currentDbColumns.map(col => {
    const colName = col.COLUMN_NAME;
    if (colName === "id" && mode === "create") return "";

    const val = rowData[colName] !== undefined && rowData[colName] !== null ? rowData[colName] : "";
    const isReadOnly = colName === "id";

    return \`
      <div class="login-field-group">
        <label class="login-field-label" style="display:flex; justify-content:space-between;">
          <span>\${colName}</span>
          <span style="font-size:0.72rem; color:var(--text-muted);">\${col.DATA_TYPE}</span>
        </label>
        <input 
          type="text" 
          name="\${colName}" 
          class="login-input" 
          value="\${String(val).replace(/"/g, '&quot;')}" 
          \${isReadOnly ? 'readonly style="background:var(--bg-page); color:var(--text-muted);"' : ''}
          placeholder="Valor para \${colName}"
        >
      </div>
    \`;
  }).join("");

  modal.style.display = "flex";
}

async function handleDbRowDelete(rowId) {
  if (!confirm("¿Estás seguro de que deseas eliminar permanentemente el registro #" + rowId + " de la tabla '" + currentDbTable + "'? Esta acción es definitiva.")) {
    return;
  }

  const res = await apiDeleteAdminTableRow(currentDbTable, rowId);
  if (res && res.status === "SUCCESS") {
    alert("✓ Registro #" + rowId + " eliminado permanentemente de la base de datos.");
    await loadDbVisorTable(currentDbTable);
  } else {
    alert("Error al eliminar registro: " + ((res && res.error) || "Permiso denegado"));
  }
}
`;

// Insert newModulesCode before document.addEventListener("DOMContentLoaded"
content = content.replace('document.addEventListener("DOMContentLoaded", () => {', newModulesCode + '\ndocument.addEventListener("DOMContentLoaded", () => {');

// 3. Add listeners inside DOMContentLoaded
const domTarget = '  // Navegacion Sidebar Completa (Todas las Vistas)\n  document.getElementById("nav-btn-dashboard")?.addEventListener("click", () => navigateTo("dashboard"));';

const domListeners = `  // Selector de Rol RBAC interactivo
  document.getElementById("select-active-role")?.addEventListener("change", (e) => {
    applyRolePermissions(e.target.value);
  });

  // Navegacion Vistas Admin
  document.getElementById("nav-btn-admin-panel")?.addEventListener("click", () => navigateTo("admin-panel"));
  document.getElementById("nav-btn-db-visor")?.addEventListener("click", () => navigateTo("db-visor"));
  document.getElementById("btn-admin-open-db")?.addEventListener("click", () => navigateTo("db-visor"));
  document.getElementById("btn-admin-refresh")?.addEventListener("click", () => loadAdminPanelData());

  // Listeners Gestor Visual BD
  document.getElementById("select-db-table")?.addEventListener("change", (e) => {
    loadDbVisorTable(e.target.value);
  });
  document.getElementById("btn-db-refresh")?.addEventListener("click", () => {
    loadDbVisorTable(currentDbTable);
  });
  document.getElementById("input-db-search")?.addEventListener("input", (e) => {
    const q = (e.target.value || "").toLowerCase().trim();
    if (!q) {
      renderDbVisorRows(currentDbRows);
    } else {
      const filtered = currentDbRows.filter(r => 
        Object.values(r).some(v => v !== null && String(v).toLowerCase().includes(q))
      );
      renderDbVisorRows(filtered);
    }
  });
  document.getElementById("btn-db-add-row")?.addEventListener("click", () => {
    openDbRowModal("create");
  });
  document.getElementById("btn-close-db-row")?.addEventListener("click", () => {
    document.getElementById("modal-db-row").style.display = "none";
  });
  document.getElementById("btn-cancel-db-row")?.addEventListener("click", () => {
    document.getElementById("modal-db-row").style.display = "none";
  });
  document.getElementById("form-db-row")?.addEventListener("submit", async (e) => {
    e.preventDefault();
    const mode = document.getElementById("inp-db-row-mode").value;
    const rowId = document.getElementById("inp-db-row-id").value;
    const form = e.target;
    const data = {};

    currentDbColumns.forEach(col => {
      const colName = col.COLUMN_NAME;
      if (colName === "id" && mode === "create") return;
      const input = form.elements[colName];
      if (input && input.value !== undefined) {
        let v = input.value.trim();
        if (v === "" && col.IS_NULLABLE === "YES") {
          data[colName] = null;
        } else if (col.DATA_TYPE === "int" || col.DATA_TYPE === "bigint" || col.DATA_TYPE === "smallint") {
          data[colName] = v === "" ? null : parseInt(v, 10);
        } else if (col.DATA_TYPE === "tinyint" && (v === "true" || v === "false")) {
          data[colName] = v === "true" ? 1 : 0;
        } else {
          data[colName] = v;
        }
      }
    });

    let res;
    if (mode === "create") {
      res = await apiInsertAdminTableRow(currentDbTable, data);
    } else {
      res = await apiUpdateAdminTableRow(currentDbTable, rowId, data);
    }

    if (res && res.status === "SUCCESS") {
      alert("✓ Registro guardado con éxito en la tabla '" + currentDbTable + "'.");
      document.getElementById("modal-db-row").style.display = "none";
      await loadDbVisorTable(currentDbTable);
    } else {
      const errEl = document.getElementById("db-row-error");
      if (errEl) {
        errEl.textContent = (res && res.error) || "Error al guardar el registro.";
        errEl.style.display = "block";
      } else {
        alert("Error al guardar: " + ((res && res.error) || "Error desconocido"));
      }
    }
  });

  // Filtros de Pausas por Contexto (Empleado / Manager / Admin)
  document.getElementById("btn-pausas-context-my")?.addEventListener("click", (e) => {
    document.querySelectorAll("#btn-pausas-context-my, #btn-pausas-context-team, #btn-pausas-context-all").forEach(b => b.classList.remove("active"));
    e.target.classList.add("active");
    AppState.pausasContextFilter = "my";
    loadBreaksData();
  });
  document.getElementById("btn-pausas-context-team")?.addEventListener("click", (e) => {
    document.querySelectorAll("#btn-pausas-context-my, #btn-pausas-context-team, #btn-pausas-context-all").forEach(b => b.classList.remove("active"));
    e.target.classList.add("active");
    AppState.pausasContextFilter = "team";
    loadBreaksData();
  });
  document.getElementById("btn-pausas-context-all")?.addEventListener("click", (e) => {
    document.querySelectorAll("#btn-pausas-context-my, #btn-pausas-context-team, #btn-pausas-context-all").forEach(b => b.classList.remove("active"));
    e.target.classList.add("active");
    AppState.pausasContextFilter = "all";
    loadBreaksData();
  });

  // Filtros Empleados por Estado Laboral
  document.getElementById("tab-emp-leaves")?.addEventListener("click", () => setEmployeeTabFilter("leaves"));
  document.getElementById("tab-emp-vacations")?.addEventListener("click", () => setEmployeeTabFilter("vacations"));

  // Aplicar rol por defecto al iniciar
  applyRolePermissions("ADMIN");

  // Navegacion Sidebar Completa (Todas las Vistas)
  document.getElementById("nav-btn-dashboard")?.addEventListener("click", () => navigateTo("dashboard"));`;

content = content.replace(domTarget, domListeners);

// 4. Update loadBreaksData with context filter and weekly grouping
const oldLoadBreaks = `async function loadBreaksData() {
  const tbody = document.getElementById("tbody-pausas-table");
  if (!tbody) return;

  if (!AppState.recordedBreaks || AppState.recordedBreaks.length === 0) {
    AppState.recordedBreaks = [
      { id: 1, employeeName: "Hassan Adraou", center: "Barcelona", type: "Café / Descanso", start: "10:30", end: "10:45", minutes: 15, excessMinutes: 0, status: "Dentro de límite" },
      { id: 2, employeeName: "Alba Garcia", center: "Madrid", type: "Almuerzo / Comida", start: "14:00", end: "15:00", minutes: 60, excessMinutes: 0, status: "Dentro de límite" },
      { id: 3, employeeName: "Elena Sanchez", center: "Bilbao", type: "Café / Descanso", start: "11:15", end: "11:35", minutes: 20, excessMinutes: 5, status: "Exceso +5 min" },
      { id: 4, employeeName: "Marc Barranco", center: "Barcelona", type: "Consulta Médica", start: "09:30", end: "10:15", minutes: 45, excessMinutes: 0, status: "Justificada" },
      { id: 5, employeeName: "Javier Fernandez", center: "Sevilla", type: "Café / Descanso", start: "11:00", end: "11:25", minutes: 25, excessMinutes: 10, status: "Exceso +10 min" }
    ];
  }

  const isCa = AppState.language === "ca";
  const totalExcess = AppState.recordedBreaks.reduce((sum, b) => sum + (b.excessMinutes || 0), 0);
  const totalExcessHours = (totalExcess / 60).toFixed(1);

  const kpiCount = document.getElementById("kpi-pauses-count");
  const kpiExcess = document.getElementById("kpi-excess-pauses-val");
  const kpiExcessSub = document.getElementById("kpi-excess-pauses-sub");

  if (kpiCount) kpiCount.textContent = AppState.recordedBreaks.length;
  if (kpiExcess) {
    kpiExcess.textContent = \`\${totalExcess} min (\${totalExcessHours} h)\`;
  }
  if (kpiExcessSub) {
    kpiExcessSub.textContent = isCa 
      ? \`Temps addicional computat a l'informe mensual\` 
      : \`Tiempo adicional computado en reporte mensual\`;
  }

  tbody.innerHTML = AppState.recordedBreaks.map(b => {
    const isExcess = b.excessMinutes > 0;
    const statusClass = isExcess ? "badge-rejected" : "badge-active";
    const statusText = isExcess 
      ? \`+\${b.excessMinutes} min (\${isCa ? "Excedent" : "Excedido"})\` 
      : (isCa ? "Reglamentària" : "Reglamentaria");

    return \`
      <tr>
        <td><strong>\${b.employeeName}</strong></td>
        <td><span class="emp-center-badge">📍 \${b.center}</span></td>
        <td><strong>\${b.type}</strong></td>
        <td>\${b.start} - \${b.end}</td>
        <td>\${b.minutes} min</td>
        <td><strong style="color: \${isExcess ? '#DC2626' : '#166534'};">\${b.excessMinutes > 0 ? '+' + b.excessMinutes + ' min (' + (b.excessMinutes / 60).toFixed(2) + ' h)' : '0 min'}</strong></td>
        <td><span class="status-pill \${statusClass}">\${statusText}</span></td>
      </tr>
    \`;
  }).join("");
}`;

const newLoadBreaks = `async function loadBreaksData() {
  const tbody = document.getElementById("tbody-pausas-table");
  if (!tbody) return;

  if (!AppState.recordedBreaks || AppState.recordedBreaks.length === 0) {
    AppState.recordedBreaks = [
      { id: 1, employeeName: "Hassan Adraou", center: "Barcelona", week: "Semana 45 · Noviembre 2026", type: "Café / Descanso", start: "10:30", end: "10:45", minutes: 15, excessMinutes: 0, status: "Dentro de límite" },
      { id: 2, employeeName: "Alba Garcia", center: "Barcelona", week: "Semana 45 · Noviembre 2026", type: "Almuerzo / Comida", start: "14:00", end: "15:00", minutes: 60, excessMinutes: 0, status: "Dentro de límite" },
      { id: 3, employeeName: "Elena Sánchez", center: "Bilbao", week: "Semana 45 · Noviembre 2026", type: "Café / Descanso", start: "11:15", end: "11:35", minutes: 20, excessMinutes: 5, status: "Exceso +5 min" },
      { id: 4, employeeName: "Marc Barranco Cordero", center: "Barcelona", week: "Semana 45 · Noviembre 2026", type: "Consulta Médica", start: "09:30", end: "10:15", minutes: 45, excessMinutes: 0, status: "Justificada" },
      { id: 5, employeeName: "Gabriel Bonnin", center: "Sevilla", week: "Semana 45 · Noviembre 2026", type: "Café / Descanso", start: "11:00", end: "11:25", minutes: 25, excessMinutes: 10, status: "Exceso +10 min" },
      { id: 6, employeeName: "Hassan Adraou", center: "Barcelona", week: "Semana 44 · Octubre 2026", type: "Almuerzo / Comida", start: "14:00", end: "14:55", minutes: 55, excessMinutes: 0, status: "Dentro de límite" },
      { id: 7, employeeName: "Albert Guiteras", center: "Barcelona", week: "Semana 44 · Octubre 2026", type: "Café / Descanso", start: "10:30", end: "10:45", minutes: 15, excessMinutes: 0, status: "Dentro de límite" }
    ];
  }

  const isCa = AppState.language === "ca";
  const user = AppState.currentUser || { name: "Hassan Adraou", centroTrabajo: "Barcelona" };
  const role = (user.rol || user.privilege || "EMPLOYEE").toUpperCase();
  const context = AppState.pausasContextFilter || (role === "EMPLOYEE" ? "my" : (role === "MANAGER" ? "team" : "all"));

  // Filtrado por contexto de usuario (RBAC)
  let visibleBreaks = AppState.recordedBreaks;
  if (context === "my") {
    visibleBreaks = AppState.recordedBreaks.filter(b => b.employeeName === user.name || b.employeeName === "Hassan Adraou");
  } else if (context === "team") {
    visibleBreaks = AppState.recordedBreaks.filter(b => b.center === (user.centroTrabajo || "Barcelona"));
  }

  const totalExcess = visibleBreaks.reduce((sum, b) => sum + (b.excessMinutes || 0), 0);
  const totalExcessHours = (totalExcess / 60).toFixed(1);

  const kpiCount = document.getElementById("kpi-pauses-count");
  const kpiExcess = document.getElementById("kpi-excess-pauses-val");
  const kpiExcessSub = document.getElementById("kpi-excess-pauses-sub");

  if (kpiCount) kpiCount.textContent = visibleBreaks.length;
  if (kpiExcess) {
    kpiExcess.textContent = totalExcess + " min (" + totalExcessHours + " h)";
  }
  if (kpiExcessSub) {
    kpiExcessSub.textContent = isCa 
      ? "Temps addicional computat a l'informe mensual" 
      : "Tiempo adicional computado en reporte mensual";
  }

  // Agrupacion por semanas con sumatorio acumulado
  const weeksMap = {};
  visibleBreaks.forEach(b => {
    const w = b.week || "Semana Actual";
    if (!weeksMap[w]) weeksMap[w] = [];
    weeksMap[w].push(b);
  });

  let rowsHtml = "";
  Object.keys(weeksMap).forEach(weekName => {
    const list = weeksMap[weekName];
    const weekTotalMin = list.reduce((sum, b) => sum + (b.minutes || 0), 0);
    const weekExcessMin = list.reduce((sum, b) => sum + (b.excessMinutes || 0), 0);
    const weekHoursStr = (weekTotalMin / 60).toFixed(1) + " h (" + weekTotalMin + " min)";
    const weekExcessStr = weekExcessMin > 0 ? (weekExcessMin + " min / " + (weekExcessMin / 60).toFixed(2) + " h exceso") : "0 exceso";

    rowsHtml += \`
      <tr class="tt-table-group-header">
        <td colspan="7">
          📅 \${weekName} &nbsp;|&nbsp; <strong>\${list.length} pausas</strong> &nbsp;|&nbsp; Tiempo Acumulado: <strong>\${weekHoursStr}</strong> &nbsp;|&nbsp; Tiempo adicional: <strong style="color:\${weekExcessMin > 0 ? '#DC2626' : 'inherit'};">\${weekExcessStr}</strong>
        </td>
      </tr>
    \`;

    list.forEach(b => {
      const isExcess = b.excessMinutes > 0;
      const statusBadge = isExcess 
        ? '<span class="tt-badge tt-badge-danger">+' + b.excessMinutes + ' min (' + (isCa ? "Excedent" : "Excedido") + ')</span>'
        : '<span class="tt-badge tt-badge-success">' + (isCa ? "Reglamentària" : "Reglamentaria") + '</span>';

      rowsHtml += \`
        <tr>
          <td><strong>\${b.employeeName}</strong></td>
          <td><span class="emp-center-badge">📍 \${b.center}</span></td>
          <td><strong>\${b.type}</strong></td>
          <td>\${b.start} - \${b.end}</td>
          <td>\${b.minutes} min</td>
          <td><strong style="color: \${isExcess ? '#DC2626' : '#166534'};">\${b.excessMinutes > 0 ? '+' + b.excessMinutes + ' min (' + (b.excessMinutes / 60).toFixed(2) + ' h)' : '0 min'}</strong></td>
          <td>\${statusBadge}</td>
        </tr>
      \`;
    });
  });

  tbody.innerHTML = rowsHtml;
}`;

content = content.replace(oldLoadBreaks, newLoadBreaks);

// 5. Update filterEmployees and setEmployeeTabFilter for leaves and vacations
const oldSetFilter = `function setEmployeeTabFilter(tabKey) {
  AppState.empTabFilter = tabKey;
  AppState.empCurrentPage = 1;

  document.getElementById("tab-emp-all")?.classList.toggle("active", tabKey === "all");
  document.getElementById("tab-emp-active")?.classList.toggle("active", tabKey === "active");
  document.getElementById("tab-emp-archived")?.classList.toggle("active", tabKey === "archived");

  filterEmployees();
}`;

const newSetFilter = `function setEmployeeTabFilter(tabKey) {
  AppState.empTabFilter = tabKey;
  AppState.empCurrentPage = 1;

  document.getElementById("tab-emp-all")?.classList.toggle("active", tabKey === "all");
  document.getElementById("tab-emp-active")?.classList.toggle("active", tabKey === "active");
  document.getElementById("tab-emp-leaves")?.classList.toggle("active", tabKey === "leaves");
  document.getElementById("tab-emp-vacations")?.classList.toggle("active", tabKey === "vacations");
  document.getElementById("tab-emp-archived")?.classList.toggle("active", tabKey === "archived");

  filterEmployees();
}`;

content = content.replace(oldSetFilter, newSetFilter);

// Update filter condition inside filterEmployees
const oldTabFilterCondition = `    // Filtro de pestañas superiores (Todos / Activos / Archivados)
    if (AppState.empTabFilter === "active" && emp.status !== "Activo") return false;
    if (AppState.empTabFilter === "archived" && emp.status !== "Baja") return false;`;

const newTabFilterCondition = `    // Filtro de pestañas superiores por estado laboral (Activo, De baja, Vacaciones, Archivados)
    if (AppState.empTabFilter === "active" && emp.status !== "Activo") return false;
    if (AppState.empTabFilter === "leaves" && emp.status !== "Baja") return false;
    if (AppState.empTabFilter === "vacations" && emp.status !== "Vacaciones") return false;
    if (AppState.empTabFilter === "archived" && (emp.activo !== false && emp.status !== "Archivado")) return false;`;

content = content.replace(oldTabFilterCondition, newTabFilterCondition);

fs.writeFileSync(appJsPath, content, 'utf8');

// Also sync with root frontend/app.js
const rootAppJsPath = path.join(__dirname, '..', 'frontend', 'app.js');
fs.writeFileSync(rootAppJsPath, content, 'utf8');

console.log('app.js refactor applied successfully! Synced to frontend/js/app.js and frontend/app.js');

