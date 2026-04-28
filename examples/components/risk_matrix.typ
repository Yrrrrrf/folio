#import "@local/folio:0.0.1": risk_matrix, folio-init

#show: body => folio-init(
  data: (
    registers: (risk_register: ((id: "R1", description: "Demo Risk", mitigation: "Demo Mitigation", probability: "Low", impact: "Low", status: "Open", affects_wbs: ("T1",)),))
  ),
  body
)

#risk_matrix()

This is a demonstration of the `risk_matrix` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
