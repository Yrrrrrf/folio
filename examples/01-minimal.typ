#import "@local/folio:0.0.2": charter-doc

#let my-data = (
  metadata: (
    id: "PRJ-001",
    name: "Migración Cloud AWS",
    version: "1.0",
    client_name: "Acme Corp",
    confidentiality: "Interno",
    doc_control: (
      revisions: (
        (version: "0.1", date: "2026-04-10", changes: "Borrador inicial"),
        (version: "1.0", date: "2026-04-15", changes: "Aprobado para ejecución"),
      ),
    ),
  ),
  initiation: (
    pitch: (
      problem: "Nuestra infraestructura física actual sufre de caídas frecuentes y los costos de mantenimiento son muy altos.",
      solution: "Migrar el 100% de la infraestructura a AWS aprovechando servicios administrados y auto-escalado.",
      value: "Reducción del 30% en costos operativos anuales, y 99.99% de disponibilidad (uptime).",
    ),
    objectives: (
      (id: "OBJ-1", name: "Migrar BD a RDS", progress: 100, target: 100),
      (id: "OBJ-2", name: "Migrar Aplicación a ECS", progress: 40, target: 100),
      (id: "OBJ-3", name: "Configurar CDN y WAF", target: 100),
    ),
    business_case: (
      benefits: (
        "Reducción de costos de energía ($10k/mes)",
        "Escalabilidad automática durante picos",
        "Mejor postura de seguridad",
      ),
      strategic_alignment: "La migración está alineada con el objetivo corporativo 2026 de 'Digitalización y Eficiencia de TI'.",
    ),
  ),
  baselines: (
    scope: (
      included: ("Auditoría de seguridad", "Migración de base de datos", "Creación de entorno ECS"),
      excluded: ("Actualización de código de aplicación", "Aplicaciones móviles"),
    ),
    schedule: (
      start_date: "2026-05-01",
      end_date: "2026-12-31",
      milestones: (
        (id: "M1", name: "Kickoff", date: "2026-05-01", type: "Reunión"),
        (id: "M2", name: "Infra como Código Lista", date: "2026-06-15", type: "Entregable"),
        (id: "M3", name: "Migración de Base de Datos", date: "2026-08-01", type: "Entregable"),
        (id: "M4", name: "Go Live", date: "2026-10-31", type: "Evento"),
      ),
    ),
    financials: (
      budget_items: (
        (name: "Licencias AWS 1er Año", cost_minor: 1500000), // $15,000.00
        (name: "Consultoría Migración", cost_minor: 4500000), // $45,000.00
        (name: "Capacitación DevOps", cost_minor: 800000), // $8,000.00
      ),
      contingency_reserve: 1000000, // $10,000.00
    ),
  ),
  registers: (
    assumptions_log: (
      (id: "SUP-1", type: "Técnico", desc: "La aplicación actual es fully-stateless", owner: "Arquitectura"),
      (id: "SUP-2", type: "Negocio", desc: "El presupuesto de consultoría será aprobado a tiempo", owner: "Sponsor"),
      (id: "SUP-3", type: "Recursos", desc: "El equipo DevOps mantendrá su capacidad al 100%", owner: "PM"),
    ),
    risk_register: (
      (
        id: "R-1",
        desc: "Retrasos en la aprobación por parte de seguridad",
        category: "Procesos",
        probability: "high",
        impact: "high",
        mitigation: "Involucrar a InfoSec desde el día 1.",
        affects_wbs: "M2",
      ),
      (
        id: "R-2",
        desc: "Costos ocultos en transferencia de datos AWS",
        category: "Financiero",
        probability: "medium",
        impact: "low",
        mitigation: "Configurar alertas tempranas de facturación.",
      ),
      (
        id: "R-3",
        desc: "Pérdida temporal de datos durante ventana de migración",
        category: "Técnico",
        probability: "low",
        impact: "high",
        mitigation: "Ensayos completos en ambiente staging (Dry-run).",
        affects_wbs: "M3",
      ),
      (
        id: "R-4",
        desc: "Falta de experiencia del equipo en herramientas nuevas",
        category: "Recursos",
        probability: "medium",
        impact: "medium",
        mitigation: "Incluir capacitación obligatoria ($8k presupuesto).",
      ),
      (
        id: "R-5",
        desc: "Problemas de red con VPN site-to-site",
        category: "Técnico",
        probability: "low",
        impact: "medium",
        mitigation: "Contratar línea dedicada si falla VPN por lentitud.",
      ),
    ),
  ),
  governance: (
    team: (
      (name: "Fernando Reza", role: "Project Manager", email: "fernando@acme.com"),
      (name: "Ana Ruiz", role: "Cloud Architect", email: "ana@acme.com"),
      (name: "Roberto Wong", role: "DevOps Engineer", email: "rwong@acme.com"),
    ),
  ),
  closure: (
    signatures: (
      sponsor: "Director IT",
      pm: "Fernando Reza",
      client: "VP Operaciones",
    ),
  ),
)

#show: charter-doc(my-data)
