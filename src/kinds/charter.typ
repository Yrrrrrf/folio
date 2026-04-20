#import "_manifest.typ": compose

#let charter = (
  id: "charter",
  title-key: "doc.charter.title",
  required: (
    "metadata.id", 
    "metadata.name", 
    "initiation.pitch.problem", 
    "initiation.pitch.solution", 
    "initiation.objectives", 
    "initiation.business_case.benefits", 
    "governance.team"
  ),
  recommended: (
    "baselines.schedule.milestones", 
    "baselines.financials.budget_items", 
    "registers.assumptions_log", 
    "registers.risk_register"
  ),
  sections: (
    ("cover", (:)),
    ("document-control", (:)),
    ("pitch", (:)),
    ("objectives", (:)),
    ("business-case", (:)),
    ("boundaries", (:)),
    ("milestones", (:)),
    ("budget", (:)),
    ("team", (:)),
    ("assumptions-log", (:)),
    ("risks", (top: 5)),
    ("sign-off", (:))
  ),
  preset: "formal",
  shell: (cover: true, toc: true, toc-depth: 2)
)

#let charter-doc(data) = {
  compose(charter, data)
}
