#import "../src/lib.typ": folio-init, folio-state, resolve-token, resolve-spacing

#show: body => folio-init(
  brand: (
    density: "compact",
    palette: (
      primary: rgb("#8b5cf6") // Purple
    )
  ),
  body
)

#let test-rect() = context {
  let st = folio-state.get()
  
  let bg-color = resolve-token(st, "palette.primary")
  let pad = resolve-spacing(st, multiplier: 1.0)
  
  rect(
    fill: bg-color,
    inset: pad,
    radius: resolve-token(st, "geometry.radius.md"),
    text(fill: white)[Hello Folio v2.0 - This is an IoC test]
  )
}

= Phase 1 Test
#test-rect()
