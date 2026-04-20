#import "../../util/mod.typ": get-state, present, nonempty, list, t
#import "../../primitives/mod.typ": signature-line, h

#let sign-off(overrides: (:)) = context {
  let s = get-state()
  
  let has-sigs = present(s.data, "closure.signatures")
  let has-matrix = nonempty(s.data, "closure.sign_off_matrix")
  
  if not has-sigs and not has-matrix { return [] }
  
  h(1, t("section.sign-off.title"))
  
  let sigs = ()
  
  if has-sigs {
    let cd = s.data.closure.signatures
    if cd.at("sponsor", default: "") != "" {
      sigs.push((name: cd.sponsor, role: "Sponsor"))
    }
    if cd.at("pm", default: "") != "" {
      sigs.push((name: cd.pm, role: "Project Manager"))
    }
    if cd.at("client", default: "") != "" {
      sigs.push((name: cd.client, role: "Cliente principal"))
    }
  } else if has-matrix {
    let mx = list(s.data, "closure.sign_off_matrix")
    for row in mx {
      sigs.push((name: row.at("name", default: ""), role: row.at("role", default: "")))
    }
  }
  
  let cols = ()
  let contents = ()
  for sig in sigs {
    cols.push(1fr)
    contents.push(signature-line(name: sig.name, role: sig.role, width: 80%))
  }
  
  grid(
    columns: cols,
    gutter: 2em,
    ..contents
  )
}
