#import "@local/folio:0.0.1": project-doc
#import "data.typ": project-data

#show: project-doc(
  data: project-data,
  config: (
    audit: true,
    toc: true
  )
)
