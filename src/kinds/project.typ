#import "_manifest.typ": compose

#let project = (
  id: "project",
  title-key: "doc.project.title",
  required: (
    "metadata.id",
    "metadata.name",
    "governance.team"
  ),
  recommended: (
    "baselines.financials.line_items",
    "baselines.schedule.phases",
    "registers.risk_register"
  ),
  sections: (
    // 1. cover (handled via shell/externally usually, but listed in manifest)
    ("document-control", (:)),
    ("pitch", (:)),
    ("business-case", (:)),
    ("team", (mode: "cards")),
    ("objectives", (:)),
    ("boundaries", (:)),
    ("budget-detailed", (:)),
    ("risks", (top: 5)),
    ("risk-matrix", (:)),
    ("gantt", (:)),
    ("sign-off", (:))
  ),
  preset: "formal",
  shell: (cover: false, toc: true, toc-depth: 3)
)

#let project-doc(data) = {
  compose(project, data)
}
