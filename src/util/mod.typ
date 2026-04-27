#import "state.typ"
#import "financials.typ"

#import "coerce.typ"
#import "merge.typ"
#import "format.typ"
#import "rag.typ"
#import "validate.typ"
#import "cross-ref.typ"

// Convenience top-level
#import coerce: get, present, list, nonempty
#import merge: deep-merge
#import state: folio-state, set-state, get-state
#import validate: check-required
#import "../i18n/mod.typ": t
