#import "@local/folio:0.0.1": status_report, folio-init

#show: body => folio-init(
  data: (
    execution: (status: (health: "Good", spend: "50%", variance: "0", summary: "Demo status summary."))
  ),
  body
)

#status_report()

This is a demonstration of the `status_report` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
