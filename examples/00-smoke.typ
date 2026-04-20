#import "@local/folio:0.0.2": compose

#let smoke-manifest = (
  id: "smoke",
  title-key: "smoke.title",
  required: ("metadata.name",),
  recommended: (),
  sections: (),
  preset: "formal",
  shell: (cover: true, toc: false),
)

#let my-data = (
  metadata: (
    name: "Smoke Test Project",
  ),
)

#show: compose(smoke-manifest, my-data)
