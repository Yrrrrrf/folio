#import "@local/folio:0.0.1": issue_log, folio-init

#show: body => folio-init(
  data: (
    registers: (issue_log: ((id: "I1", description: "Demo Issue", owner: "Demo Owner", status: "Open", affects_risk: ("R1",), blocks_milestone: ("M1",)),))
  ),
  body
)

#issue_log()

This is a demonstration of the `issue_log` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
