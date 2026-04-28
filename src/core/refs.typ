#let slugify(text) = {
  lower(str(text)).replace(regex("[^a-z0-9]+"), "-").trim("-")
}

#let task-label(id) = label("task-" + slugify(id))
#let milestone-label(id) = label("milestone-" + slugify(id))
#let risk-label(id) = label("risk-" + slugify(id))
#let issue-label(id) = label("issue-" + slugify(id))
#let change-label(id) = label("change-" + slugify(id))

#let safe-link(lbl, fallback-text) = context {
  if query(lbl).len() > 0 {
    link(lbl)[#fallback-text]
  } else {
    [#fallback-text?]
  }
}

#let link-to-task(id) = safe-link(task-label(id), id)
#let link-to-milestone(id) = safe-link(milestone-label(id), id)
#let link-to-risk(id) = safe-link(risk-label(id), id)
#let link-to-issue(id) = safe-link(issue-label(id), id)
#let link-to-change(id) = safe-link(change-label(id), id)
