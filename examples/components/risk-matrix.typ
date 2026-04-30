#import "@local/folio:0.0.1": folio-init, risk-matrix

#show: body => folio-init(
  data: (
    registers: (
      risk_register: (
        (
          id: "R1",
          description: "Demo Risk",
          mitigation: "Demo Mitigation",
          probability: "Low",
          impact: "Low",
          status: "Open",
          affects_wbs: ("T1",),
        ),
      ),
    ),
  ),
  body,
)

#risk-matrix("registers.risk_register")

This is a demonstration of the `risk-matrix` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
