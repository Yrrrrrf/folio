#import "state.typ": folio-state
#import "../primitives/card.typ": card
#import "../theme/resolver.typ": resolve-token, resolve-spacing

#let section-guard(title, data-path, level: 2, body-fn) = context {
  let st = folio-state.get()
  let data = st.at("data", default: (:))
  
  let current = data
  let parts = data-path.split(".")
  let found = true
  
  for p in parts {
    if type(current) == dictionary and p in current {
      current = current.at(p)
    } else {
      found = false
      break
    }
  }
  
  let is-empty = not found or current == none or current == "" or (type(current) == array and current.len() == 0) or (type(current) == dictionary and current.pairs().len() == 0)
  
  heading(level: level)[#title]
  
  if is-empty {
    card(title: "Sección Omitida")[
      #text(fill: resolve-token(st, "palette.intent.danger"), style: "italic")[Requiere datos en: `#data-path`]
    ]
  } else {
    body-fn(current)
  }
  
  v(resolve-spacing(st, multiplier: 2.0))
}
