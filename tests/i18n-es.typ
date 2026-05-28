// Test: i18n Spanish
#import "../src/lib.typ": project-doc

#show: project-doc(
  data: (
    project: (
      name: "i18n Spanish Test",
      description: "Verificando salida en idioma español",
    ),
    initiation: (
      pitch: "Probando que las cadenas en español se resuelvan correctamente.",
      objectives: (
        (id: "OBJ-1", description: "Validar i18n en español", priority: "high"),
      ),
      success_criteria: (
        (
          id: "SC-1",
          type: "project",
          criterion: "Todos los enlaces clickeables, cero huérfanos",
          measurement: "Conteo de huérfanos",
          target: "0",
          objective_id: "OBJ-1",
        ),
      ),
      stakeholders: (
        (
          id: "SH-1",
          name: "Ejecutor de pruebas",
          role: "Control de Calidad",
          interest: "high",
          influence: "high",
        ),
      ),
      assumptions_log: (
        (
          id: "A-1",
          type: "assumption",
          description: "El compilador de Typst es determinista",
          status: "Validated",
        ),
      ),
    ),
    baselines: (
      scope: (
        in_scope: ("Validación de i18n",),
        out_of_scope: ("Prueba de regresión visual",),
      ),
      requirements: (
        (
          id: "REQ-01",
          description: "Emisión de etiquetas para cada entidad",
          category: "Correctness",
          priority: "high",
          qty: 1,
          unit: "feature",
          unit_cost: 0,
        ),
      ),
      schedule: (
        milestones: (
          (
            id: "M1",
            date: "2026-05-01",
            title: "Línea base completada",
            status: "Pending",
          ),
        ),
      ),
    ),
    governance: (
      team: (
        (
          role: "Desarrollador",
          name: "Autor de pruebas",
          email: "test@folio.dev",
        ),
      ),
    ),
    execution: (
      status: (
        health: "Good",
        spend: "10%",
        variance: "0d",
        summary: "Prueba de i18n en progreso.",
      ),
    ),
    registers: (
      risk_register: (
        (
          id: "R1",
          description: "Paquete no instalado localmente",
          mitigation: "Ejecutar `just local` primero",
          probability: "Low",
          impact: "High",
          status: "Open",
        ),
      ),
      issue_log: (
        (
          id: "I1",
          description: "Referencia huérfana detectada",
          owner: "CI",
          status: "Open",
        ),
      ),
      change_log: (
        (
          id: "C1",
          description: "Añadidas nuevas familias de etiquetas",
          status: "Approved",
          type: "scope",
          affects_baseline: "baselines.scope",
        ),
      ),
      decision_log: (
        (
          id: "DEC-1",
          description: "Usar slugify para IDs de etiquetas",
          date: "2026-04-01",
          decision_maker: "Arquitecto",
          rationale: "Evita colisiones de caracteres especiales.",
          reversibility: "Type-2",
          prompted_by_risk: "R1",
        ),
      ),
      deliverables_register: (
        (
          id: "D1",
          description: "Todas las familias de etiquetas en verde",
          owner: "Dev",
          due_date: "2026-05-01",
          status: "Planned",
          req_ids: ("REQ-01",),
        ),
      ),
    ),
    closure: (
      lessons_learned: (
        (
          category: "Arquitectura",
          issue: "Las etiquetas deben emitirse antes de resolver enlaces",
          recommendation: "Emitir siempre etiquetas en la misma pasada que la fila de la tabla",
        ),
      ),
      acceptance: (
        (
          deliverable_id: "D1",
          accepted_by: "Líder de QA",
          acceptance_date: "2026-05-02",
          outstanding_issues: "None",
        ),
      ),
      benefits_review: (
        (
          objective_id: "OBJ-1",
          claimed: "Cero referencias huérfanas",
          actual: "Cero referencias huérfanas",
          variance: "0%",
        ),
      ),
      handover: (
        documentation: ("Guía de referencias",),
        transfer_date: "2026-05-10",
      ),
      financial_closure: (
        final_cost: 450.0,
        budget_baseline: 500.0,
        variance: -50.0,
      ),
      sign_off: (
        (name: "Líder de QA", role: "Autoridad de aceptación"),
      ),
    ),
  ),
  config: (audit: true, toc: true, lang: "es"),
)
