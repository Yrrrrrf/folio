#import "../util/state.typ": get-state
#import "../i18n/mod.typ": t
#import "../theme/mod.typ": presets

#let project-page(content) = context {
  let s = get-state()
  let pr = presets.at(s.theme-preset, default: presets.formal)
  let proj-name = s.data.metadata.name
  let proj-version = s.data.metadata.version
  
  let header = [
    #text(size: 0.8em, fill: pr.palette.text.muted, [
      #strong(proj-name) #h(1fr) #proj-version
    ])
    #line(length: 100%, stroke: 0.5pt + pr.palette.border.default)
  ]
  
  let conf-str = s.data.metadata.confidentiality
  let footer = [
    #line(length: 100%, stroke: 0.5pt + pr.palette.border.default)
    #text(size: 0.8em, fill: pr.palette.text.muted, [
      #if conf-str == "Confidencial" {
        text(fill: pr.palette.intent.danger, strong(t("confidentiality.confidential")))
      } else {
        conf-str
      }
      #h(1fr)
      #t("footer.page") #counter(page).display("1") #t("footer.of") #context counter(page).final().first()
    ])
  ]

  set page(
    margin: pr.page-margins,
    header: header,
    footer: footer
  )
  
  content
}
