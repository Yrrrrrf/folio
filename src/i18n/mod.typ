#import "../util/state.typ": get-state, set-state
#import "es-MX.typ"
#import "en-US.typ"

#let LOCALES = ("es-MX", "en-US")
#let locale-labels = (
  "es-MX": es-MX.labels,
  "en-US": en-US.labels
)

#let t(key) = context {
  let s = get-state()
  let loc = if s.locale in LOCALES { s.locale } else { "es-MX" }
  let dict = locale-labels.at(loc)
  dict.at(key, default: key)
}

#let set-locale(locale) = {
  set-state(locale: locale)
}
