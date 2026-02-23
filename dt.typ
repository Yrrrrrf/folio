// ── Project Data Store ──────────────────────────────────────────────────────
// This is your Single Source of Truth for the entire project.
// Edit this file, and all documents generated in `main.typ` will reflect your changes.

#let project = (
  // --- 1. Identity ---
  name: "Nombre del Proyecto",
  version: "1.0.0",
  status: "En Progreso", // Completado, En Progreso, En Revisión
  description: "Descripción a alto nivel del objetivo y contexto general de este proyecto. Esta descripción aparece en el Acta de Constitución y en el Resumen Ejecutivo.",
  start_date: "2026-03-01",
  end_date: "2026-06-30",
  gantt_render_end: "2026-07-15",
  // --- 2. Ownership ---
  owner: "Nombre del Responsable",
  team: (
    (name: "Líder Técnico", role: "Arquitecto Senior", responsibilities: "Diseño técnico y validación."),
    (name: "Desarrollador 1", role: "Ingeniero Backend", responsibilities: "Implementación de APIs."),
  ),
  // --- 3. Stakeholders ---
  stakeholders: (
    (
      name: "Cliente A",
      organization: "Empresa Patrocinadora",
      power: "Alto",
      interest: "Alto",
      channel: "Reunión Semanal",
      attitude: "Favorable",
    ),
  ),
  // --- 4. Objectives & Benefits ---
  objectives: (
    "Entregar la fase 1 del producto antes del Q3.",
    "Reducir el tiempo de procesamiento en un 40%.",
  ),
  benefits: (
    "Ahorro de costos operativos.",
    "Mejora en la experiencia del usuario final.",
  ),
  // --- 5. Scope ---
  scope: (
    included: (
      "Desarrollo de los módulos A y B.",
      "Pruebas de integración y despliegue a producción.",
    ),
    excluded: (
      "Mantenimiento continuo después del mes 1.",
      "Desarrollo del módulo C.",
    ),
  ),
  // --- 6. Feasibility (Optional override) ---
  feasibility: (
    technical: "Se cuenta con la infraestructura en la nube necesaria y las licencias vigentes.",
    economic: "El presupuesto autorizado cubre los costos directos con un 15% de margen de contingencia.",
    operative: "El equipo tiene capacidad para absorber hasta el 30% del esfuerzo mensual.",
  ),
  // --- 7. Requirements (BOM) ---
  tech_requirements: (
    "Asegurar compatibilidad con navegadores modernos.",
    "Cumplimiento de normativa ISO 27001.",
  ),
  requirements: (
    (id: "REQ-01", description: "Licencias de Software", unit: "mes", qty: 12, unit_cost: 1500, category: "Software"),
    (id: "REQ-02", description: "Consultoría Externa", unit: "horas", qty: 40, unit_cost: 800, category: "Servicios"),
  ),
  budget_extras: (
    (description: "Contingencia (15%)", cost: 7500),
  ),
  // --- 8. Risks ---
  risks: (
    (
      id: "RSK-01",
      description: "Retraso en entrega de servidores",
      probability: "Media",
      impact: "Alto",
      mitigation: "Solicitar con 4 semanas de anticipación y usar nube temporal.",
    ),
  ),
  // --- 9. Schedule (Phases & Milestones) ---
  phases: (
    (
      name: "1. Análisis",
      subtasks: (
        (name: "Requerimientos", start: "2026-03-01", end: "2026-03-10"),
      ),
    ),
    (
      name: "2. Ejecución",
      subtasks: (
        (name: "Implementación", start: "2026-03-12", end: "2026-05-20"),
      ),
    ),
  ),
  milestones: (
    (name: "Término del Análisis", date: "2026-03-10", show-date: true),
    (name: "Fase 1 Completada", date: "2026-05-20", show-date: true),
  ),
  // --- 10. Quality & Communications ---
  quality_criteria: (
    "0 vulnerabilidades críticas detectadas en el escaneo VAPT final.",
    "95% de cobertura de código en pruebas unitarias.",
  ),
  communication_plan: (
    (audience: "Sponsor", frequency: "Quincenal", channel: "Reporte PDF", owner: "Responsable"),
    (audience: "Equipo Técnico", frequency: "Diaria", channel: "Stand-up / Slack", owner: "Tech Lead"),
  ),
  notes: (
    "El presupuesto está sujeto al tipo de cambio actual.",
  ),
  // --- 11. Acceptance & Closure ---
  acceptance_date: "30 de Junio de 2026",
  client_signature: "Nombre del Cliente Final",
  completed_deliverables: (
    "Módulo A en Producción.",
    "Módulo B en Producción.",
    "Manuales de Usuario Entregados.",
  ),
)
