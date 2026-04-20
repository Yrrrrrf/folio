#import "@local/folio:0.0.2": charter-doc

#let my-degraded-data = (
  metadata: (
    id: "DEGRADED-01",
    name: "Proyecto Vacío",
  ),
)

#show: charter-doc(my-degraded-data)
