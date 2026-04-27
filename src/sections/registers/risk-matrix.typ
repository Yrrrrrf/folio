#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../primitives/mod.typ": risk-matrix, h

#let risk-matrix-section(overrides: (:)) = context {
  let levels = overrides.at("levels", default: ("low", "medium", "high"))
  let s = get-state()
  if not nonempty(s.data, "registers.risk_register") { return [] }
  
  h(2, t("section.risk_matrix.title"))
  
  let rks = list(s.data, "registers.risk_register")
  
  risk-matrix(
    risks: rks,
    levels: levels
  )
}
