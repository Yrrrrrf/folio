// Folio: i18n Spanish Demo Example
// Displays all project sections translated into Spanish.
#import "../src/lib.typ": project-doc
#import "i18n-demo-data.typ": project-data

#show: project-doc(
  data: project-data,
  config: (
    audit: true,
    cover: true,
    toc: true,
    lang: "es",
  ),
)
