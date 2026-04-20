#let DEFAULT_STATE = (
  theme-preset: "formal",
  locale: "es-MX",
  data: (:),
  config: (:)
)

#let folio-state = state("folio-state", DEFAULT_STATE)

#let set-state(theme-preset: none, locale: none, data: none, config: none) = {
  folio-state.update(old => {
    let new-state = old
    if theme-preset != none { new-state.theme-preset = theme-preset }
    if locale != none { new-state.locale = locale }
    if data != none { new-state.data = data }
    if config != none { new-state.config = config }
    new-state
  })
}

#let get-state() = {
  folio-state.get()
}
