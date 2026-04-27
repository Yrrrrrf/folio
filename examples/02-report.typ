#import "@local/folio:0.0.1": status-report-doc

#let my-status = (
  metadata: (
    name: "Migración Cloud AWS",
    client_name: "Acme Corp",
    version: "2.1",
    confidentiality: "Interno",
  ),
  governance: (
    status: (
      rag_status: "amber",
      executive_summary: "El flujo principal está avanzado. Sin embargo, tenemos un bloqueo por dependencias de seguridad y presupuestos adicionales del CDN.",
      domain_rag: (
        "Presupuesto": "red",
        "Cronograma": "amber",
        "Alcance": "green",
        "Riesgos": "green",
      ),
    ),
  ),
  baselines: (
    schedule: (
      start_date: "2026-05-01",
      end_date: "2026-12-31",
      milestones: (
        (name: "Infra como Código Lista", date: "2026-06-15", type: "Completado"),
        (name: "Migración de Base de Datos", date: "2026-08-01", type: "En progreso"),
      ),
    ),
    financials: (
      budget_items: (
        (name: "Gastado hasta hoy (Actuals)", cost_minor: 2200000), // $22k
        (name: "Proyectado restante (ETC)", cost_minor: 4700000),
      ),
    ),
  ),
  registers: (
    risk_register: (
      (
        desc: "Retrasos en la aprobación por parte de seguridad",
        probability: "low",
        impact: "high",
        mitigation: "Ya se estableció comité semanal.",
      ),
      (
        desc: "Costos ocultos CDN y WAF",
        probability: "high",
        impact: "medium",
        mitigation: "Analizando presupuesto adicional de $4k",
      ),
    ),
    issue_log: (
      (
        id: "ISS-01",
        desc: "Permisos IAM insuficientes bloqueando despliegues ECS",
        status: "open",
        priority: "high",
        owner: "Roberto Wong",
      ),
      (id: "ISS-02", desc: "Caída de entorno dev por 3 horas", status: "closed", priority: "medium", owner: "Ana Ruiz"),
    ),
    change_log: (
      (id: "CR-01", desc: "Añadir WAF a la arquitectura base", status: "Aprobado"),
      (id: "CR-02", desc: "Ampliar consultoría DevOps 1 mes", status: "Bajo revisión"),
    ),
  ),
)

#show: status-report-doc(my-status)
