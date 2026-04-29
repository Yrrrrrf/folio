#import "../core/pipeline.typ": pmbok-pipeline
#import "../core/guard.typ": section-guard
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": get-title
#import "../components/planning.typ": boundaries, budget, gantt, milestones, team

#let planning(pipeline: pmbok-pipeline) = context {
  let st = folio-state.get()
  let current-pipeline = pipeline
  
  heading(level: 1)[Phase 3: #get-title(st.at("data", default: (:)), "phases.planning.title", "Planning")]
  
  for (phase, section_id, data_path, render_fn) in current-pipeline {
    if phase == "planning" {
      let resolved-toggle = st.config.sections.at(section_id, default: auto)
      section-guard(resolved-toggle, data_path, render_fn)
    }
  }
}
