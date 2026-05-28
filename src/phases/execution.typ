#import "../core/phase-runner.typ": render-phase
#import "../core/pipeline.typ": pmbok-pipeline
#import "../i18n/i18n.typ": t
#import "../components/execution.typ": (
  change-log, decision-log, deliverables-register, issue-log, risk-matrix,
  status-report,
)

#let execution(pipeline: pmbok-pipeline) = render-phase(
  pipeline,
  "execution",
  t("phase-execution"),
)

// Re-export section fns for lib.typ
#let status-report = status-report
#let risk-matrix = risk-matrix
#let issue-log = issue-log
#let change-log = change-log
#let decision-log = decision-log
#let deliverables-register = deliverables-register
