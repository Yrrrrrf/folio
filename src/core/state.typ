#let folio-state = state("folio-state", (
  data: (:),
  config: (:),
  brand: (:),
))

#let folio-init(data: (:), config: (:), brand: (:), body) = {
  folio-state.update(old => {
    (
      data: data,
      config: config,
      brand: brand,
    )
  })

  set page(numbering: "1")

  body
}
