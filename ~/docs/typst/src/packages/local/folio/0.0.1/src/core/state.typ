#import "../theme/resolver.typ": resolve-token

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

  context {
    let st = folio-state.get()
    let font = resolve-token(st, "typography.family")
    let size = resolve-token(st, "typography.size.body")
    let margin = resolve-token(st, "geometry.page-margin")
    let paper = resolve-token(st, "geometry.paper")

    set text(font: font, size: size)
    set page(margin: margin, paper: paper, numbering: "1")
    body
  }
}
