#import "../../src/lib.typ": project-doc, link-to-task

#let data = (
  project: (name: "Orphan Reference Test"),
  initiation: (pitch: "This has a broken link."),
  registers: (
    risk_register: (
      (id: "R1", description: "Risk with broken link", affects_wbs: ("NON-EXISTENT-TASK",))
    )
  )
)

#show: project-doc(
  data: data,
  config: (audit: true, toc: true)
)

// Explicit orphan call for testing
#link-to-task("GHOST-TASK")
