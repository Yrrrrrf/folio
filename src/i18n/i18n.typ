#import "../core/state.typ": folio-state
#import "en.typ" as en
#import "es.typ" as es

#let folio-strings = (
  en: en.strings,
  es: es.strings,
)

// Typst-native compile-time parity validation
#let check-parity() = {
  let langs = folio-strings.keys()
  if langs.len() <= 1 { return }

  let ref-keys = folio-strings.en.keys()

  for lang in langs {
    let lang-keys = folio-strings.at(lang).keys()

    // 1. Reference keys missing in target language
    let missing-in-lang = ref-keys.filter(k => k not in lang-keys)
    assert(
      missing-in-lang.len() == 0,
      message: "i18n parity error: keys missing in '"
        + lang
        + "' catalog: "
        + missing-in-lang.join(", "),
    )

    // 2. Extra keys in target language missing in reference
    let missing-in-ref = lang-keys.filter(k => k not in ref-keys)
    assert(
      missing-in-ref.len() == 0,
      message: "i18n parity error: keys in '"
        + lang
        + "' but missing in 'en' catalog: "
        + missing-in-ref.join(", "),
    )
  }
}

// Perform compile-time validation immediately when this module is imported
#check-parity()

#let t(key) = {
  let st = folio-state.get()
  let lang = st.config.at("lang", default: "en")
  let lang-strings = folio-strings.at(lang, default: folio-strings.en)
  lang-strings.at(key, default: key)
}

#let status-label(key) = {
  let st = folio-state.get()
  let lang = st.config.at("lang", default: "en")
  let lang-strings = folio-strings.at(lang, default: folio-strings.en)
  lang-strings.at("status-" + key, default: key)
}
