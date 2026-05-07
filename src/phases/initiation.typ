#import "../core/phase-runner.typ": render-phase
#import "../core/pipeline.typ": pmbok-pipeline
#import "../components/initiation.typ": cover, pitch, business-case, objectives, success-criteria, stakeholders, assumptions-log

#let initiation(pipeline: pmbok-pipeline) = render-phase(pipeline, "initiation", "Initiation")

// Re-export section fns for lib.typ
#let pitch = pitch
#let business-case = business-case
#let objectives = objectives
#let success-criteria = success-criteria
#let stakeholders = stakeholders
#let assumptions-log = assumptions-log
#let cover = cover
