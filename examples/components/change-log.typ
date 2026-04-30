#import "@local/folio:0.0.1": change-log, folio-init

#show: body => folio-init(
  data: (
    registers: (change_log: ((id: "C1", description: "Demo Change", status: "Pending"),))
  ),
  body
)

#change-log("registers.change_log")

This is a demonstration of the `change_log` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
