#import "../../src/lib.typ": callout

#let crosswalk(pmbok: none, prince2: none, iso: none, title: "Standards Crosswalk") = {
  if pmbok == none and prince2 == none and iso == none {
    return
  }

  callout(
    kind: "info",
    title: none,
    [
      #text(weight: "bold")[#title]
      #v(0.5em)
      #if pmbok != none [*PMBOK:* #pmbok]
      #if pmbok != none and (prince2 != none or iso != none) [\ ]
      #if prince2 != none [*PRINCE2:* #prince2]
      #if prince2 != none and iso != none [\ ]
      #if iso != none [*ISO:* #iso]
    ]
  )
}
