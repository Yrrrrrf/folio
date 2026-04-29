#import "../../src/lib.typ": project-doc

#let data = (
  project: (name: "Extra Checks Test"),
  meta: (advisor: "Dr. Smith")
)

#show: project-doc(
  data: data,
  config: (
    audit: true,
    extra-checks: (
      (path: "meta.advisor", severity: "critical", phase: "initiation", kind: "string"),
      (path: "meta.missing", severity: "recommended", phase: "initiation", kind: "string"),
    )
  )
)
