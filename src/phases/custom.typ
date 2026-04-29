#import "../core/pipeline.typ": pmbok-pipeline
#import "../core/guard.typ": section-guard
#import "../core/state.typ": folio-state
#import "../core/resolve.typ": get-title

#let custom(pipeline: pmbok-pipeline) = context {
  let st = folio-state.get()
  let current-pipeline = pipeline
  
  // Only render if there are custom phase sections
  let has-custom = current-pipeline.any(p => p.phase == "custom")
  
  if has-custom {
    heading(level: 1)[Phase 6: #get-title(st.at("data", default: (:)), "phases.custom.title", "Custom Sections")]
    
    for (phase, section_id, data_path, render_fn) in current-pipeline {
      if phase == "custom" {
        let resolved-toggle = st.config.sections.at(section_id, default: auto)
        section-guard(resolved-toggle, data_path, render_fn)
      }
    }
  }
}
