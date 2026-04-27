#import "@local/folio:0.0.1": project-doc

// Reproducing Project 01: Conexión de Edificios Comerciales
#let my-data = (
  metadata: (
    id: "PRJ-01",
    name: "Conexión de Edificios Comerciales",
    version: "1.0.0",
    status: "En Progreso",
    doc_control: (
      revisions: (
        (version: "1.0.0", date: "2026-02-17", changes: "Versión inicial"),
      ),
    ),
  ),
  initiation: (
    pitch: (
      value: "Interconexión de dos edificios comerciales mediante fibra óptica e instalación de red de telefonía IP.",
    ),
    business_case: (
      benefits: (
        "Escalabilidad de comunicación entre edificios.",
        "Instalación de red de telefonía IP moderna.",
        "Infraestructura de red de alta capacidad y bajo mantenimiento.",
      ),
    ),
    notes: (
      "Verificar la paridad de los medios de transmisión y los estándares de comunicación para asegurar la compatibilidad entre los edificios.",
      "Buscar y crear documentación técnica detallada para cada componente utilizado.",
      "Incluir un margen de contingencia en el presupuesto para cubrir posibles imprevistos.",
    ),
  ),
  governance: (
    team: (
      (name: "Alejandro Hernández Arriaga", role: "Cliente / Responsable"),
    ),
  ),
  baselines: (
    schedule: (
      start_date: "2026-02-17",
      end_date: "2026-03-11",
      gantt_render_end: "2026-03-12",
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
      milestones: (
        (name: "ENTREGA FINAL", date: "2026-03-11", show-date: true),
      ),
    ),
    financials: (
      line_items: (
        (id: "REQ-01", description: "Cable de fibra óptica multimodo 50µm, 3 pares", unit: "metros", qty: 2350, unit_cost: 15, category: "Infraestructura", priority: "Alta"),
        (id: "REQ-02", description: "RACK de 42U", unit: "unidades", qty: 2, unit_cost: 9499, category: "Hardware", priority: "Alta"),
        (id: "REQ-03", description: "Router", unit: "unidades", qty: 2, unit_cost: 8534, category: "Hardware", priority: "Alta"),
        (id: "REQ-04", description: "Teléfonos IP", unit: "unidades", qty: 20, unit_cost: 909.90, category: "Hardware", priority: "Alta"),
        (id: "REQ-05", description: "Switch de datos", unit: "unidades", qty: 4, unit_cost: 6160.90, category: "Hardware", priority: "Alta"),
        (id: "REQ-06", description: "Distribuidor de fibra óptica de 6 pares", unit: "unidades", qty: 2, unit_cost: 1800, category: "Infraestructura", priority: "Media"),
        (id: "REQ-07", description: "Conmutador telefónico IP", unit: "unidad", qty: 1, unit_cost: 7999, category: "Hardware", priority: "Alta"),
        (id: "REQ-08", description: "Patch cord fibra óptica multimodo LC-LC", unit: "unidades", qty: 20, unit_cost: 299, category: "Conectividad", priority: "Media"),
        (id: "REQ-09", description: "Patch cord cobre 4 pares RJ45", unit: "unidades", qty: 20, unit_cost: 135, category: "Conectividad", priority: "Media"),
        (id: "REQ-11", description: "Permiso de apertura de calle", unit: "unidad", qty: 1, unit_cost: 20000, category: "Obra Civil", priority: "Alta"),
        (id: "REQ-13", description: "Mano de obra — instalación y config. de equipo", unit: "técnicos", qty: 2, unit_cost: 10000, category: "Mano de Obra", priority: "Alta"),
      ),
      extras: (
        (name: "Gestión de Proyecto (10%)", kind: "pct_of_subtotal", value: 0.10),
        (name: "Transporte y Logística", kind: "fixed", value: 15000),
        (name: "Imprevistos (5%)", kind: "pct_of_subtotal", value: 0.05),
      ),
    ),
  ),
  registers: (
    risk_register: (
      (id: "R-01", desc: "Retraso en permisos municipales", probability: "medium", impact: "high", mitigation: "Iniciar gestiones con 2 semanas de antelación."),
      (id: "R-02", desc: "Falta de stock de equipos de red", probability: "low", impact: "high", mitigation: "Confirmar disponibilidad con proveedores antes de la compra."),
    ),
  ),
  closure: (
    acceptance_date: "17 de febrero de 2026",
    signatures: (
        client: "Alejandro Hernández Arriaga"
    )
  ),
)

#show: project-doc(my-data)
