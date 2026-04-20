#let project = (
  metadata: (
    id: "PRJ-2026",
    name: "Aurora Cloud Migration",
    client_name: "Acme Corp",
    version: "1.2.0",
    created_at: "2026-05-15",
    confidentiality: "Internal",
    tags: ("Cloud", "Infra", "Q2")
  ),
  initiation: (
    pitch: (
      problem: "Legacy infra causes frequent outages.",
      solution: "Migrate Tier 1 services to AWS.",
      value: "Reduce downtime by 90%."
    ),
    objectives: (
      (name: "Achieve 99.99% uptime for core API by Q3."),
      (name: "Complete migration with zero data loss.")
    ),
    business_case: (
      benefits: "Save $45k/year in maintenance.",
    ),
    feasibility: (
      technical: "High",
      economic: "High",
      legal: "Medium",
      operational: "High",
      schedule: "Medium"
    )
  ),
  baselines: (
    scope: (
      (id: "1.0", name: "Assessment", description: "Audit existing infra"),
    ),
    schedule: (
      milestones: (
        (name: "Audit Complete", date: "2026-06-01"),
      )
    ),
    financials: (
      budget_items: (
        (name: "Software", amount: "$10,000"),
      )
    ),
    quality: ()
  ),
  registers: (
    assumptions_log: (
      (id: "A1", description: "Existing network bandwidth is sufficient."),
    ),
    risk_register: (
      (description: "API Downtime", probability: "Medium", impact: "High", mitigation: "Blue/Green deployment"),
    ),
    issue_log: (
      (description: "AWS account limit reached", status: "Resolved", owner: "DevOps", severity: "High"),
    ),
    change_log: (
      (description: "Add auto-scaling group", status: "Approved", owner: "Architect", impact: "Medium"),
    )
  ),
  governance: (
    team: (
      (role: "Sponsor", name: "Jane Doe"),
      (role: "Project Manager", name: "John Smith"),
    ),
    stakeholders: (
      (name: "DevOps Team", interest: "High", influence: "High"),
    ),
    raci_matrix: (
      (task: "Cutover", r: "DevOps", a: "Architect", c: "PM", i: "Sponsor"),
    ),
    communications: (
      (audience: "Sponsor", channel: "Email", frequency: "Weekly"),
    ),
    status: (
      rag_status: "Green",
      executive_summary: "Migration is on track."
    )
  ),
  closure: (
    acceptance_date: "2026-09-05",
    handover_deliverables: ("AWS Architecture Repo", "Runbooks"),
    lessons_learned: ("Start compliance review earlier.",),
    signatures: (
      sponsor: "Jane Doe",
      pm: "John Smith"
    )
  )
)
