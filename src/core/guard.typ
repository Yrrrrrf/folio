#import "state.typ": folio-state
#import "../theme/ui.typ": card
#import "../theme/resolver.typ": resolve-token, resolve-spacing
#import "resolve.typ": nonempty

#let section-guard(toggle, path, render) = context {
  if toggle == false {
    return
  }

  let st = folio-state.get()
  let data = st.at("data", default: (:))
  
  if toggle == true {
    render(path)
  } else if toggle == auto {
    if nonempty(data, path) {
      render(path)
    }
  } else {
    // Legacy support for phase 1 - titles as strings
    let title = toggle
    let is-empty = not nonempty(data, path)
    
    heading(level: 2)[#title]
    
    if is-empty {
      card(title: "Sección Omitida")[
        #text(fill: resolve-token(st, "palette.intent.danger"), style: "italic")[Requiere datos en: `#path`]
      ]
    } else {
      render(path)
    }
    
    v(resolve-spacing(st, multiplier: 2.0))
  }
}
