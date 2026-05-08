# ── Shared Utilities ──────────────────────────────────────────────────────────
# Private helpers for folio's build system.
# This file contains the centralized import-replacement logic.
# Only _replace-imports lives here; it is called by swap-local and swap-dev.
# Users should NEVER call these directly — use swap-local / swap-dev instead.

# Package identity (shared across all scripts)
LOCAL  := env('HOME') / ".local/share/typst/packages/local"
VERSION := `rg version typst.toml | cut -d'"' -f2`
PKG_ID  := "@local/folio:" + VERSION

# ── _replace-imports ──────────────────────────────────────────────────────────
# Swap all import paths in examples/, tests/, and docs/.
#
# mode = "local"  → replace relative paths with @local/folio:<version>
# mode = "dev"    → restore relative ../src/lib.typ paths
#
# The regex handles:
#   Single-line:  #import "../src/lib.typ": project-doc
#   Multi-line:   #import "../src/lib.typ": (
#                   project-doc, card,
#                 )
#   Any depth:    ../../src/lib.typ, ../src/lib.typ
#   @local form:  #import "@local/folio:0.0.1": ...
#
# Idempotent: calling the same mode twice yields the same result.
[private]
_replace-imports mode:
    #!/usr/bin/env bash
    set -euo pipefail

    if [ "{{ mode }}" = "local" ]; then
        echo "  → Replacing relative imports → {{ PKG_ID }}..."
        # depth-1 files (examples/*.typ, tests/*.typ, docs/*.typ)
        fd -e typ -d 1 . examples/ tests/ docs/ 2>/dev/null \
            | xargs -I{} sd '#import\s+"(?:\.\./)+src/lib\.typ"' '#import "{{ PKG_ID }}"' {} 2>/dev/null || true
        # nested files (examples/components/*.typ, tests/fixtures/*.typ)
        fd -e typ --min-depth 2 . examples/ tests/ docs/ 2>/dev/null \
            | xargs -I{} sd '#import\s+"(?:\.\./)+src/lib\.typ"' '#import "{{ PKG_ID }}"' {} 2>/dev/null || true

    elif [ "{{ mode }}" = "dev" ]; then
        echo "  → Restoring relative dev imports..."
        # depth-1: rewrite to ../src/lib.typ
        fd -e typ -d 1 . examples/ tests/ docs/ 2>/dev/null \
            | xargs -I{} sd '#import\s+"@local/folio:[^"]+"' '#import "../src/lib.typ"' {} 2>/dev/null || true
        # also fix any stale relative paths at depth-1 (normalize)
        fd -e typ -d 1 . examples/ tests/ docs/ 2>/dev/null \
            | xargs -I{} sd '#import\s+"(?:\.\./)+src/lib\.typ"' '#import "../src/lib.typ"' {} 2>/dev/null || true
        # nested: rewrite to ../../src/lib.typ
        fd -e typ --min-depth 2 . examples/ tests/ docs/ 2>/dev/null \
            | xargs -I{} sd '#import\s+"@local/folio:[^"]+"' '#import "../../src/lib.typ"' {} 2>/dev/null || true
        fd -e typ --min-depth 2 . examples/ tests/ docs/ 2>/dev/null \
            | xargs -I{} sd '#import\s+"(?:\.\./)+src/lib\.typ"' '#import "../../src/lib.typ"' {} 2>/dev/null || true
    else
        echo "ERROR: _replace-imports expects 'local' or 'dev', got '{{ mode }}'"
        exit 1
    fi
