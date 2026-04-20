#import "coerce.typ"
#import "state.typ"

#let register(kind, id, title, extra: (:)) = {
  let label-name = "folio-" + kind + "-" + id
  [#metadata((folio: kind, id: id, title: title, ..extra)) #label(label-name)]
}

#let resolve(kind, id) = context {
  let label-name = "folio-" + kind + "-" + id
  let res = query(label(label-name))
  if res.len() > 0 {
    let item = res.first().value
    link(label(label-name), item.title)
  } else {
    text(fill: orange.darken(20%), underline(id))
  }
}
