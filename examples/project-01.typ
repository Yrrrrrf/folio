#import "@local/folio:0.0.1": project-doc

#let mock-data = (
  project: (
    name: "Chimera Vision Core",
    description: "Phase 1 spatial engine build-out"
  ),
  initiation: (
    pitch: "Develop a high-performance spatial indexing core for real-time tracking.",
    business_case: "Reduces search latency by 40%, enabling larger scale enterprise clients.",
    objectives: (
      (id: "OBJ-01", description: "Implement PostGIS cluster", priority: "high"),
      (id: "OBJ-02", description: "Deploy GraphQL API", priority: "neutral")
    )
  ),
  baselines: (
    scope: (
      in_scope: ("PostGIS indexing", "REST API translation layer", "Authentication"),
      out_of_scope: ("UI Dashboard", "Mobile Apps")
    ),
    schedule: (
      milestones: (
        (id: "M-01", date: "2026-06-01", title: "DB Setup", status: "Done"),
        (id: "M-02", date: "2026-07-01", title: "API Complete", status: "Pending")
      ),
      gantt: (
        (id: "REQ-01", name: "Requirements", start: "2026-05-01", end: "2026-05-15", progress: "100%"),
        (id: "DEV-01", name: "Backend Dev", start: "2026-05-15", end: "2026-07-01", progress: "40%")
      )
    ),
    financials: (
      budget: (
        (description: "Cloud Infrastructure", amount: 15000),
        (description: "Contractors", amount: 45000)
      )
    )
  ),
  governance: (
    team: (
      (role: "Project Manager", name: "Alice Smith", email: "alice@example.com"),
      (role: "Tech Lead", name: "Bob Jones", email: "bob@example.com")
    )
  ),
  execution: (
    status: (
      health: "Good",
      spend: "30%",
      variance: "+2d",
      summary: "Project is on track. Initial DB schemas are deployed and populated."
    )
  ),
  registers: (
    risk_register: (
      (id: "R-01", description: "API Rate limiting", mitigation: "Implement Redis cache", probability: "Medium", impact: "High", status: "Open", affects_wbs: ("DEV-01",)),
    ),
    issue_log: (
      (id: "I-01", description: "AWS Region Outage", owner: "Bob", status: "Resolved", affects_risk: ("R-01",), blocks_milestone: ("M-01",)),
    ),
    change_log: (
      (id: "CR-01", description: "Add GraphQL subscriptions", status: "Approved"),
    )
  ),
  closure: (
    lessons_learned: (
      (category: "Technical", issue: "Redis configuration was complex", recommendation: "Use managed Redis"),
    ),
    sign_off: (
      (name: "Charlie CEO", role: "Sponsor"),
    )
  )
)

#show: project-doc(
  data: mock-data,
  config: (audit: true)
)

= Introduction
This document demonstrates the full reproduction of the Folio v0.0.1 architecture, pulling all elements from the central data dictionary.
