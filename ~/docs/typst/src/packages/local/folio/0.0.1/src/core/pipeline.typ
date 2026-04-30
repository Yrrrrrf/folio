#import "../components/initiation.typ": business-case, objectives, pitch
#import "../components/planning.typ": boundaries, budget, gantt, milestones, team
#import "../components/execution.typ": change-log, issue-log, risk-matrix, status-report
#import "../components/closure.typ": lessons-learned, sign-off

#let pmbok-pipeline = (
  (phase: "initiation", section_id: "pitch", data_path: "initiation.pitch", render_fn: pitch),
  (phase: "initiation", section_id: "business_case", data_path: "initiation.business_case", render_fn: business-case),
  (phase: "initiation", section_id: "objectives", data_path: "initiation.objectives", render_fn: objectives),
  (phase: "planning", section_id: "boundaries", data_path: "baselines.scope", render_fn: boundaries),
  (phase: "planning", section_id: "milestones", data_path: "baselines.schedule.milestones", render_fn: milestones),
  (phase: "planning", section_id: "budget", data_path: "baselines.financials.budget", render_fn: budget),
  (phase: "planning", section_id: "gantt", data_path: "baselines.schedule.gantt", render_fn: gantt),
  (phase: "planning", section_id: "team", data_path: "governance.team", render_fn: team),
  (phase: "execution", section_id: "status_report", data_path: "execution.status", render_fn: status-report),
  (phase: "execution", section_id: "risk_matrix", data_path: "registers.risk_register", render_fn: risk-matrix),
  (phase: "execution", section_id: "issue_log", data_path: "registers.issue_log", render_fn: issue-log),
  (phase: "execution", section_id: "change_log", data_path: "registers.change_log", render_fn: change-log),
  (phase: "closure", section_id: "lessons_learned", data_path: "closure.lessons_learned", render_fn: lessons-learned),
  (phase: "closure", section_id: "sign_off", data_path: "closure.sign_off", render_fn: sign-off),
)
