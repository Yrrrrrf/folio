#import "@local/folio:0.0.1": team, folio-init

#show: body => folio-init(
  data: (
    governance: (team: ((role: "Demo Role", name: "Demo Name", email: "demo@example.com"),))
  ),
  body
)

#team()

This is a demonstration of the `team` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
