#import "@local/folio:0.0.1": gantt, folio-init

#show: body => folio-init(
  data: (
    baselines: (schedule: (gantt: ((id: "T1", name: "Demo Task", start: "2026-01-01", end: "2026-01-10", progress: "50%"),)))
  ),
  body
)

#gantt("baselines.schedule.gantt")

This is a demonstration of the `gantt` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
