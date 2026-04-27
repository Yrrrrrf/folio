#let folio-state = state("folio-state", (
  data: (:),
  locale: "en-US",
  brand: (:)
))

#let folio-init(
  data: (:),
  locale: "en-US",
  brand: (:),
  body
) = {
  folio-state.update(old => {
    (
      data: data,
      locale: locale,
      brand: brand
    )
  })

  set page(numbering: "1")

  body
}
