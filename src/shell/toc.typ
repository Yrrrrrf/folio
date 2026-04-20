#import "../i18n/mod.typ": t

#let toc(title: auto, depth: 2, include-figures: false) = {
  let act-title = if title == auto { t("shell.toc.title") } else { title }
  
  // To avoid empty pages if nothing is available, we rely on outline
  heading(level: 1, act-title)
  // Section Outline
  outline(title: none, depth: depth, indent: 2em)
  
  if include-figures {
    v(2em)
    heading(level: 2, t("figure.table"))
    outline(title: none, target: figure.where(kind: "folio-table"))
  }
}
