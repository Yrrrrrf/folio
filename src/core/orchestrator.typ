#import "state.typ": folio-init, folio-state
#import "guard.typ": section-guard
#import "audit.typ": data-audit
#import "resolve.typ": nonempty

#import "../phases/initiation.typ": business-case, cover, objectives, pitch
#import "../phases/planning.typ": boundaries, budget, gantt, milestones, team
#import "../phases/execution.typ": change-log, issue-log, risk-matrix, status-report
#import "../phases/closure.typ": lessons-learned, sign-off

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

#let project-doc(data: (:), config: (:), brand: (:)) = body => {
  let resolved-config = (
    audit: config.at("audit", default: false),
    cover: config.at("cover", default: auto),
    sections: config.at("sections", default: (:)),
  )

  show: rest => folio-init(data: data, config: resolved-config, brand: brand, rest)

  context {
    let st = folio-state.get()

    if st.config.audit == true {
      data-audit()
    }

    if st.config.cover == true or (st.config.cover == auto and nonempty(st.data, "project.name")) {
      cover()
    }

    for (phase, section_id, data_path, render_fn) in pmbok-pipeline {
      let resolved-toggle = st.config.sections.at(section_id, default: auto)
      section-guard(resolved-toggle, data_path, render_fn)
    }

    body
  }
}
