#import "@local/folio:0.0.1": lessons_learned, folio-init

#show: body => folio-init(
  data: (
    closure: (lessons_learned: ((category: "Demo Category", issue: "Demo Issue", recommendation: "Demo Recommendation"),))
  ),
  body
)

#lessons_learned()

This is a demonstration of the `lessons_learned` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
