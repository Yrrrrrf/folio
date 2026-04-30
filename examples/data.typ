// Shared data dictionary for folio examples.
// This file centralizes project metadata, milestones, risks, and other PMBOK-aligned fields
// used across multiple example documents (project-01, rfp, etc).

#let project-data = (
  project: (
    name: "Chimera Urban Infrastructure",
    description: "Phase 2 Smart City implementation - Puebla District"
  ),
  initiation: (
    pitch: "Deploy a mesh network of acoustic sensors to detect and triangulate urban anomalies.",
    business_case: "Reduces emergency response time by 15% through automated incident detection.",
    objectives: (
      (id: "OBJ-1", description: "Deploy 500 sensor nodes", priority: "high"),
      (id: "OBJ-2", description: "Achieve <2s triangulation latency", priority: "high"),
      (id: "OBJ-3", description: "Integrate with municipal dispatch", priority: "neutral")
    )
  ),
  baselines: (
    scope: (
      in_scope: ("Sensor hardware deployment", "Acoustic ML model training", "API integration"),
      out_of_scope: ("Public-facing mobile app", "Camera surveillance")
    ),
    schedule: (
      milestones: (
        (id: "M1", date: "2026-05-01", title: "Pilot Complete", status: "Done"),
        (id: "M2", date: "2026-08-01", title: "District-Wide Rollout", status: "Pending")
      ),
      gantt: (
        (id: "T1", name: "Procurement", start: "2026-04-01", end: "2026-05-01", progress: "100%"),
        (id: "T2", name: "Installation", start: "2026-05-01", end: "2026-08-01", progress: "25%")
      )
    ),
    financials: (
      budget: (
        (description: "Hardware Nodes", amount: 120000),
        (description: "Installation Labor", amount: 85000),
        (description: "Software License", amount: 30000)
      )
    )
  ),
  governance: (
    team: (
      (role: "Program Manager", name: "Elena Rodriguez", email: "elena@chimera.city"),
      (role: "Hardware Lead", name: "Marco Polo", email: "marco@chimera.city")
    )
  ),
  execution: (
    status: (
      health: "Good",
      spend: "45%",
      variance: "0d",
      summary: "Hardware procurement finished ahead of schedule. Installation phase underway."
    )
  ),
  registers: (
    risk_register: (
      (id: "R1", description: "Supply chain delays for chips", mitigation: "Bulk order placed in Phase 1", probability: "Low", impact: "High", status: "Closed"),
      (id: "R2", description: "Vandalism of sensor nodes", mitigation: "Tamper-proof enclosures", probability: "Medium", impact: "Low", status: "Open", affects_wbs: ("T2",))
    ),
    issue_log: (
      (id: "I1", description: "Frequency interference in Sector 4", owner: "Marco", status: "Resolved", blocks_milestone: ("M1",)),
    ),
    change_log: (
      (id: "C1", description: "Add weather sensors to nodes", status: "Pending"),
    )
  ),
  closure: (
    lessons_learned: (
      (category: "Hardware", issue: "Battery life lower in high-humidity areas", recommendation: "Use solar-augmentation for tropical sectors"),
    ),
    sign_off: (
      (name: "Secretary of Urban Development", role: "Executive Sponsor"),
    )
  )
)
