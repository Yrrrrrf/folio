#import "@local/folio:0.0.1": folio-init, lessons-learned

#show: body => folio-init(
  data: (
    closure: (
      lessons_learned: ((category: "Demo Category", issue: "Demo Issue", recommendation: "Demo Recommendation"),),
    ),
  ),
  body,
)

#lessons-learned()

This is a demonstration of the `lessons-learned` component. It renders completely independently based solely on the data provided to the `folio-init` state container.
