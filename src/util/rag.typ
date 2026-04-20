#import "../i18n/mod.typ": t

#let RAG_ORDER = ("red", "amber", "green")

#let rag-color(value) = {
  if value == "red" { return "status.red" }
  if value == "amber" { return "status.amber" }
  if value == "green" { return "status.green" }
  "status.neutral"
}

#let rag-label(value) = {
  t("rag." + str(value))
}

#let worst-of(values) = {
  if values.len() == 0 { return "green" }
  if "red" in values { return "red" }
  if "amber" in values { return "amber" }
  "green"
}
