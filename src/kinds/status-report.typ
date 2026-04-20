#import "_manifest.typ": compose

#let status-report = (
  id: "status-report",
  title-key: "doc.status-report.title",
  required: (
    "metadata.name",
    "governance.status.rag_status"
  ),
  recommended: (
    "governance.status.executive_summary",
    "registers.issue_log"
  ),
  sections: (
    ("cover", (compact: true)),
    ("status-report", (:)),
    ("milestones", (:)),
    ("budget", (:)),
    ("risks", (top: 3)),
    ("issues-log", (:)),
    ("change-log", (:))
  ),
  preset: "formal",
  shell: (cover: false, toc: false)
)

#let status-report-doc(data) = {
  compose(status-report, data)
}
