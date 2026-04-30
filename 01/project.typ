#let project-data = (
  project: (
    name: "Conexión de Edificios Comerciales",
    description: "Interconexión de dos edificios comerciales mediante fibra óptica e instalación de red de telefonía IP.",
    version: "1.0.0",
    start_date: "2026-02-17",
    gantt_render_end: "2026-03-12",
  ),
  initiation: (
    pitch: "Interconexión de dos edificios comerciales mediante fibra óptica para escalabilidad y modernización con telefonía IP.",
    business_case: "Infraestructura de red de alta capacidad y bajo mantenimiento para edificios comerciales.",
    objectives: (
      (id: "OBJ-1", description: "Realizar la ubicación de los edificios", priority: "high"),
      (id: "OBJ-2", description: "Realizar el direccionamiento IP", priority: "high"),
      (id: "OBJ-3", description: "Realizar cotización de componentes", priority: "high"),
    ),
  ),
  baselines: (
    scope: (
      in_scope: (
        "Cable de fibra óptica multimodo",
        "RACK de 42U",
        "Router",
        "Teléfonos IP",
        "Switch de datos",
        "Conmutador telefónico IP",
      ),
      out_of_scope: ("Obra civil pesada (no canalización)", "Suministro de energía eléctrica"),
    ),
    schedule: (
      milestones: (
        (id: "M1", date: "2026-03-11", title: "ENTREGA FINAL", name: "ENTREGA FINAL", status: "Pending"),
      ),
      gantt: (
        (id: "T1", name: "I. Análisis de Requerimientos", start: "2026-02-17", end: "2026-02-20", progress: "0%"),
        (id: "T2", name: "II. Diseño y Propuesta", start: "2026-02-21", end: "2026-02-25", progress: "0%"),
        (id: "T3", name: "III. Revisión y Aprobación", start: "2026-02-26", end: "2026-02-28", progress: "0%"),
        (id: "T4", name: "IV. Adquisición e Implementación", start: "2026-03-01", end: "2026-03-07", progress: "0%"),
        (id: "T5", name: "V. Configuración y Cierre", start: "2026-03-08", end: "2026-03-11", progress: "0%"),
      ),
      phases: (
        (
          name: "I. Análisis de Requerimientos",
          subtasks: (
            (name: "1. Visita con cliente", start: "2026-02-17", end: "2026-02-17"),
            (name: "2. Clasificación de requerimientos", start: "2026-02-18", end: "2026-02-18"),
            (name: "3. Análisis de viabilidad", start: "2026-02-19", end: "2026-02-19"),
            (name: "4. Documento técnico", start: "2026-02-20", end: "2026-02-20"),
          ),
        ),
        (
          name: "II. Diseño y Propuesta",
          subtasks: (
            (name: "5. Diseño lógico de la red", start: "2026-02-21", end: "2026-02-22"),
            (name: "6. Selección de equipos", start: "2026-02-23", end: "2026-02-23"),
            (name: "7. Presupuesto", start: "2026-02-24", end: "2026-02-24"),
            (name: "8. Presentación al cliente", start: "2026-02-25", end: "2026-02-25"),
          ),
        ),
        (
          name: "III. Revisión y Aprobación",
          subtasks: (
            (name: "9. Revisión y ajuste", start: "2026-02-26", end: "2026-02-27"),
            (name: "10. Aprobación final", start: "2026-02-28", end: "2026-02-28"),
          ),
        ),
        (
          name: "IV. Adquisición e Implementación",
          subtasks: (
            (name: "11. Adquisición de materiales", start: "2026-03-01", end: "2026-03-03"),
            (name: "12. Gestión de permisos", start: "2026-03-04", end: "2026-03-04"),
            (name: "13. Instalación física", start: "2026-03-05", end: "2026-03-06"),
            (name: "14. Montaje de equipos", start: "2026-03-07", end: "2026-03-07"),
          ),
        ),
        (
          name: "V. Configuración y Cierre",
          subtasks: (
            (name: "15. Configuración inicial", start: "2026-03-08", end: "2026-03-08"),
            (name: "16. Pruebas de conectividad", start: "2026-03-09", end: "2026-03-09"),
            (name: "17. Documentación", start: "2026-03-10", end: "2026-03-10"),
            (name: "18. Entrega y firma", start: "2026-03-11", end: "2026-03-11"),
          ),
        ),
      ),
    ),
    financials: (
      budget: (
        (description: "Cable de fibra óptica multimodo", amount: 35250),
        (description: "RACK de 42U (2 unidades)", amount: 18998),
        (description: "Router (2 unidades)", amount: 17068),
        (description: "Teléfonos IP (20 unidades)", amount: 18198),
        (description: "Switch de datos (4 unidades)", amount: 24643.60),
        (description: "Distribuidor de fibra óptica", amount: 3600),
        (description: "Conmutador telefónico IP", amount: 7999),
        (description: "Patch cord fibra óptica (20 unidades)", amount: 5980),
        (description: "Patch cord cobre (20 unidades)", amount: 2700),
        (description: "Permiso de apertura de calle", amount: 20000),
        (description: "Mano de obra - instalación y config.", amount: 20000),
      ),
    ),
  ),
  governance: (
    team: (
      (role: "Cliente / Responsable", name: "Alejandro Hernández Arriaga", email: "alejandro@example.com"),
    ),
  ),
  execution: (
    status: (
      health: "Good",
      spend: "0%",
      variance: "0d",
      summary: "Proyecto en fase de inicio.",
    ),
  ),
  registers: (
    risk_register: (
      (id: "R1", description: "Permiso de apertura de calle denegado por autoridad municipal", mitigation: "Gestión anticipada y plan de ruta alternativo", probability: "Medium", impact: "High", status: "Open"),
      (id: "R2", description: "Daño accidental a la fibra óptica durante la instalación física", mitigation: "Uso de canalización reforzada y personal certificado", probability: "Low", impact: "High", status: "Open"),
      (id: "R3", description: "Incompatibilidad entre equipos de telefonía IP existentes y nuevos", mitigation: "Pruebas de laboratorio previas a la instalación masiva", probability: "Low", impact: "Medium", status: "Open"),
      (id: "R4", description: "Retraso en el suministro de RACKs de 42U por problemas de cadena de suministro", mitigation: "Órdenes de compra inmediatas tras aprobación", probability: "High", impact: "Medium", status: "Open"),
      (id: "R5", description: "Condiciones climáticas adversas (lluvias intensas) para obra civil", mitigation: "Margen de contingencia en el cronograma de 3 días", probability: "Medium", impact: "Low", status: "Open"),
      (id: "R6", description: "Fluctuación de precios en componentes de red (importados)", mitigation: "Presupuesto con margen del 5% para imprevistos", probability: "Medium", impact: "Medium", status: "Open"),
      (id: "R7", description: "Falta de paridad en los medios de transmisión entre edificios", mitigation: "Verificación técnica exhaustiva en fase de diseño", probability: "Low", impact: "High", status: "Open"),
      (id: "R8", description: "Interferencia en señal de datos por mala canalización de energía eléctrica", mitigation: "Separación física estricta según normas internacionales", probability: "Low", impact: "Medium", status: "Open"),
      (id: "R9", description: "Renuncia o indisponibilidad de personal técnico especializado", mitigation: "Contratación de empresa externa de respaldo (outsourcing)", probability: "Low", impact: "Medium", status: "Open"),
      (id: "R10", description: "Fallo en las pruebas de estrés de la red tras la configuración", mitigation: "Auditoría de configuración y re-ajuste de parámetros QoS", probability: "Low", impact: "High", status: "Open"),
    ),
    issue_log: (),
    change_log: (),
  ),
  closure: (
    lessons_learned: (),
    sign_off: (
      (name: "Alejandro Hernández Arriaga", role: "Cliente / Responsable"),
    ),
  ),
)
