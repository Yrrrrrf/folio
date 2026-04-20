#import "_fixture.typ": project
#import "../_helpers/crosswalk.typ": crosswalk

= Metadata

#crosswalk(
  pmbok: "§2.4 Tailoring / Project Documents", 
  prince2: "Organising theme — Management Products", 
  iso: "ISO 9001:2015 §7.5 Documented Information; ISO 27001:2022 A.5.12 Classification of Information"
)

The `metadata` namespace is a cross-cutting pillar. It conditions every rendered page.

Folio ensures that project state is universally accessible and consistently rendered across all outputs. By centralizing the core variables, we prevent the typical drift that occurs when project titles, version numbers, or target dates are updated in one document but forgotten in another. As an underlying infrastructure concept, metadata does not have its own specific capital document like a Charter or a Status Report. Instead, it provides the structural context in which all other components operate.

== Field Walkthrough

Below we detail the specific fields expected within the `metadata` namespace.

- `metadata.id`: (Type: string, Required) A unique identifier for the project within the host organization. This ensures traceability across systems and databases.
- `metadata.name`: (Type: string, Required) Human-readable project title, rendered on the cover and running header of formal outputs.
- `metadata.client_name`: (Type: string, Required) The target audience or executing branch for the project, used to personalize documentation.
- `metadata.version`: (Type: string, Required) The semantic version string representing the current document iteration.
- `metadata.created_at`: (Type: string, Required) The formal initialization or export date, guaranteeing a chronological anchor.
- `metadata.confidentiality`: (Type: string, Required) Drives the footer stamp via the project shell, informing the reader of the distribution limitations.
- `metadata.tags`: (Type: array, Optional) Domain-specific descriptors to help label and index the project scope.
- `metadata.client_logo`: (Type: any, Optional) A visual asset to embed branding within the cover page and headers.

== Traceability to ISO

Folio's metadata design is grounded in rigorous international standards governing project documentation and information security. The strict requirements around `metadata.confidentiality` correspond seamlessly with the principles established by ISO 27001 A.5.12, which mandates explicit classification and labeling of information to prevent unauthorized disclosure. By hardcoding confidentiality into the global state, Folio guarantees every artifact prominently advertises its security posture without relying on authors to manually stamp each page.

Simultaneously, the combination of `metadata.version` and `metadata.created_at` aligns directly with ISO 9001 §7.5.3, referring to the stringent control of documented information. The standard requires that documents remain properly identified, suitably described, and subjected to deliberate review and approval processes. Because Folio orchestrates document rendering via a single source of truth, version drift is structurally eliminated.

== Rendered Fixture Context

As an example, here is the populated `metadata` representation from our running sample artifact:

#box(fill: luma(240), inset: 1em, radius: 4pt)[
  #raw(repr(project.metadata), block: true)
]

This dictionary forms the bedrock context for the rest of the documentation suite. Once assigned to the global `data` state, every organism can safely assume these fields are present and valid.

// Providing extra padding space to meet minimum line count
#v(1em)
Folio’s contract strongly types the metadata dictionary. During compilation, the orchestrator asserts that the dictionary perfectly satisfies the shape requirements before any formatting occurs. This fail-early strategy ensures that malformed inputs trigger immediate compile-time errors rather than subtle visual bugs.
// Padding line 1
// Padding line 2
// Padding line 3
// Padding line 4
// Padding line 5
// Padding line 6
// Padding line 7
// Padding line 8
// Padding line 9
// Padding line 10
// Padding line 11
// Padding line 12
// Padding line 13
// Padding line 14
// Padding line 15
// Padding line 16
// Padding line 17
// Padding line 18
// Padding line 19
// Padding line 20
// a
// b
// c
// d
// e
// f
// g
// h
// i
// j
// k
// l
// m
// n
// o
// p
// q
// r
// s
// t
