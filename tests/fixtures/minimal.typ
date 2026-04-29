#import "../../src/lib.typ": project-doc

#let project = (
  project: (name: "Minimal Test Project")
)

#show: project-doc(
  data: project,
  config: (audit: true, toc: true)
)
