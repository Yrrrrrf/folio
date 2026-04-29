#import "../../src/core/schema.typ": folio-schema
#import "../../src/core/pipeline.typ": pmbok-pipeline

#let schema-paths = folio-schema.map(r => r.path)
#let missing-paths = pmbok-pipeline.filter(p => p.data_path not in schema-paths)

#if missing-paths.len() > 0 {
  block(fill: red, inset: 1em)[
    *Schema-Pipeline Parity Failure!*
    The following pipeline paths are missing from the schema:
    #list(..missing-paths.map(p => p.data_path))
  ]
} else {
  [✅ Schema-Pipeline Parity Verified]
}
