#import "../core/pipeline.typ": pmbok-pipeline
#import "../core/guard.typ": section-guard
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": get-title, nonempty
#import "../components/execution.typ": change-log, issue-log, risk-matrix, status-report, decision-log, deliverables-register

#let execution(pipeline: pmbok-pipeline) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))

  // Filter sections that will actually render
  let renderable-sections = pipeline.filter(p => {
    if p.phase != "execution" { return false }
    let toggle = st.config.at("sections", default: (:)).at(p.section_id, default: auto)
    return toggle == true or (toggle == auto and nonempty(data, p.data_path))
  })

  if renderable-sections.len() == 0 { return }

  heading(level: 1)[Phase 3: #get-title(data, "phases.execution.title", "Execution")]

  for (phase, section_id, data_path, render_fn) in renderable-sections {
    let resolved-toggle = st.config.at("sections", default: (:)).at(section_id, default: auto)
    section-guard(resolved-toggle, data_path, render_fn)
  }
}
