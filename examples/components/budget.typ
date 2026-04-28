#import "@local/folio:0.0.1": budget, folio-init

#show: body => folio-init(
  data: (
    baselines: (financials: (budget: ((description: "Demo Expense", amount: 5000),)))
  ),
  body
)

#budget()

This is a demonstration of the `budget` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
