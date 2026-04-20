#import "../util/mod.typ": deep-merge, set-state, check-required
#import "../contract/mod.typ": default-data
#import "../theme/mod.typ": apply-preset
#import "../shell/mod.typ": project-page, cover-page, toc
#import "../sections/mod.typ": get-section

#let MANIFEST_SCHEMA = (
  id: "str",
  title-key: "str",
  required: "array",
  recommended: "array",
  sections: "array",
  preset: "str",
  shell: "dict"
)

#let compose(manifest, user-data) = {
  // 1. Deep-merge user data over default-data
  let merged-data = deep-merge(default-data, user-data)
  
  // 2. Set state
  let req-locale = if type(user-data) == dictionary and "metadata" in user-data and "locale" in user-data.metadata {
    user-data.metadata.locale
  } else {
    none
  }
  set-state(data: merged-data, theme-preset: manifest.preset, locale: req-locale)
  
  // 4. Install theme
  show: apply-preset(name: manifest.preset)
  
  // 5. Wrap in shell project-page
  show: project-page
  
  // 3. Validate required fields
  let missing = check-required(merged-data, manifest.required)
  if missing.len() > 0 {
    // Missing required fields
    align(center)[
      #block(
        fill: red.lighten(80%), 
        stroke: 2pt + red.darken(20%), 
        inset: 1em,
        radius: 0.5em,
        width: 100%
      )[
        #text(fill: red.darken(20%), weight: "bold", size: 1.2em)[DRAFT — missing required fields:]
        #for path in missing {
          [- #path]
        }
      ]
    ]
    v(2em)
  }
  
  // 6. Cover page
  if manifest.shell.at("cover", default: false) {
    cover-page()
  }
  
  // 8. TOC
  if manifest.shell.at("toc", default: false) {
    toc(depth: manifest.shell.at("toc-depth", default: 2))
    pagebreak()
  }
  
  // 7. Iterate sections
  for (sec-id, overrides) in manifest.sections {
    let render-fn = get-section(sec-id)
    if render-fn == none {
      // Unknown section
      block(fill: orange.lighten(80%), inset: 1em, text(fill: orange.darken(20%), [Unknown section: #sec-id — skipped]))
    } else {
      render-fn(overrides: overrides)
    }
  }
}
