#import "../../src/lib.typ": project-doc
#import "../../examples/data.typ": project-data

#show: project-doc(
  data: project-data,
  config: (audit: true, toc: true)
)
