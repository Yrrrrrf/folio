#import "../../util/mod.typ": get-state, list, nonempty, t
#import "../../primitives/mod.typ": ftable, h

#let document-control(overrides: (:)) = context {
  let s = get-state()
  let has-revs = nonempty(s.data, "metadata.doc_control.revisions")
  let has-apps = nonempty(s.data, "metadata.doc_control.approvers")
  
  if not has-revs and not has-apps { return [] }
  
  h(1, t("section.document-control.title"))
  
  if has-revs {
    let revs = list(s.data, "metadata.doc_control.revisions")
    let rows = revs.map(r => (r.at("version", default: ""), r.at("date", default: ""), r.at("changes", default: "")))
    
    ftable(
      (auto, auto, 1fr),
      header: (t("footer.version"), "Fecha", t("section.changes.title")),
      rows: rows
    )
  }
}
