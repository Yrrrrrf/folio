#import "@local/folio:0.0.1": objectives, folio-init

#show: body => folio-init(
  data: (
    initiation: (objectives: ((id: "OBJ-1", description: "Demo Objective", priority: "high"),))
  ),
  body
)

#objectives()

This is a demonstration of the `objectives` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
