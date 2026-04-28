#import "@local/folio:0.0.1": sign_off, folio-init

#show: body => folio-init(
  data: (
    closure: (sign_off: ((name: "Demo Signer", role: "Demo Role"),))
  ),
  body
)

#sign_off()

This is a demonstration of the `sign_off` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
