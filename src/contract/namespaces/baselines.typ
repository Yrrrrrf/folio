#let baselines-defaults = (
  scope: (included: (), excluded: (), wbs: (), deliverables: ()),
  schedule: (start_date: "", end_date: "", phases: (), milestones: (), critical_path: (), dependencies: ()),
  financials: (
    budget_items: (),
    line_items: (),
    extras: (),
    contingency_reserve: 0,
    payment_terms: (),
    projections: (),
    bom: (),
  ),
  quality: (
    tech_requirements: (),
    functional: (),
    non_functional: (),
    acceptance_criteria: (),
    testing: (),
    qa_plan: (:),
  ),
  legal: (contract_terms: (:), ip: (:), confidentiality: (:), liability: (:), termination: (:), jurisdiction: (:)),
  security: (requirements: (), data_governance: (:), compliance: (), audit_trail: (:)),
)
