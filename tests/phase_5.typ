#import "../src/lib.typ": *

#show: body => folio-init(
  data: (
    project: (
      name: "Folio v2 Implementation",
      description: "A major rewrite of the core engine."
    ),
    initiation: (
      pitch: "This project will revolutionize how we write documents.",
      objectives: (
        (id: "OBJ-1", description: "Zero compiler panics", priority: "high"),
        (id: "OBJ-2", description: "Theme flexibility", priority: "normal")
      )
    ),
    baselines: (
      schedule: (
        milestones: (
          (date: "2026-04-27", title: "Core Refactor Complete", status: "Done"),
          (date: "2026-05-01", title: "Public Release", status: "Pending")
        )
      )
    ),
    execution: (
      status: (
        health: "Good",
        spend: "45%",
        variance: "+2 Days",
        summary: "Everything is proceeding as planned."
      )
    ),
    registers: (
      risk_register: (
        (id: "RSK-01", description: "Dependencies change", probability: "Medium", impact: "High", status: "Open"),
      )
    ),
    closure: (
      sign_off: (
        (name: "Yrrrrrf", role: "Sponsor"),
        (name: "AI Agent", role: "Developer")
      )
    )
  ),
  body
)

#cover()

#pitch()
#business_case()
#objectives()

#boundaries()
#milestones()
#budget()
#gantt()
#team()

#status_report()
#risk_matrix()
#issue_log()
#change_log()

#lessons_learned()
#sign_off()
