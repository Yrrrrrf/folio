#import "../core/pipeline.typ": pmbok-pipeline
#import "../core/guard.typ": section-guard
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": get-title
#import "../components/closure.typ": lessons-learned, sign-off

#let closure(pipeline: pmbok-pipeline) = context {
  let st = folio-state.get()
  let current-pipeline = pipeline
  
  heading(level: 1)[Phase 5: #get-title(st.at("data", default: (:)), "phases.closure.title", "Closure")]
  
  for (phase, section_id, data_path, render_fn) in current-pipeline {
    if phase == "closure" {
      let resolved-toggle = st.config.sections.at(section_id, default: auto)
      section-guard(resolved-toggle, data_path, render_fn)
    }
  }
}
