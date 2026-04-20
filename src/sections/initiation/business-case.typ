#import "../../util/mod.typ": get-state, nonempty, present, list, t
#import "../../primitives/mod.typ": h

#let business-case(overrides: (:)) = context {
  let s = get-state()
  let bc = s.data.initiation.business_case
  
  let has-benefits = nonempty(s.data, "initiation.business_case.benefits")
  let has-align = present(s.data, "initiation.business_case.strategic_alignment")
  
  if not has-benefits and not has-align { return [] }
  
  h(1, t("section.business-case.title"))
  
  if has-benefits {
    let bens = list(s.data, "initiation.business_case.benefits")
    for b in bens {
      [- #b]
    }
  }
  
  if has-align {
    if has-benefits { v(1em) }
    text(style: "italic", bc.strategic_alignment)
  }
}
