# ── Shared Utilities ──────────────────────────────────────────────────────────
# Private helpers for folio's build system.
# This file contains the centralized import-replacement logic.
# Only _replace-imports lives here; it is called by swap-local and swap-dev.
# Users should NEVER call these directly — use swap-local / swap-dev instead.
# Package identity (shared across all scripts)

LOCAL := env('HOME') / ".local/share/typst/packages/local"
PREVIEW := env('TYPST_PACKAGES_DIR', env('HOME') / "docs/typst/typst-packages") / "packages/preview"
VERSION := `rg version typst.toml | cut -d'"' -f2`
PKG_ID := "@local/folio:" + VERSION

# ── _replace-imports ──────────────────────────────────────────────────────────
# Rewrites import paths across examples/, tests/, docs/. Idempotent: any current
# state (relative, @local, or @preview) can be rewritten to any target state.
#
# Regex matches all three forms:
#   relative:  "../src/lib.typ", "../../src/lib.typ"
#   @local:    "@local/folio:0.0.1"
#   @preview:  "@preview/folio:0.0.1"
#
# Note: depth-1 ↔ depth-2 split for `dev` mode assumes max nesting is

# examples/components/X.typ. Deeper trees would need depth-aware logic.
[private]
_replace-imports mode:
    #!/usr/bin/env bash
    set -euo pipefail

    PATTERN='#import\s+"(?:(?:\.\./)+src/lib\.typ|@(?:local|preview)/folio:[^"]+)"'

    case "{{ mode }}" in
        local)
            echo "  → Rewriting imports → {{ PKG_ID }}..."
            fd -e typ . examples/ tests/ docs/ 2>/dev/null \
                | xargs -I{} sd "$PATTERN" '#import "{{ PKG_ID }}"' {} 2>/dev/null || true
            ;;
        preview)
            echo "  → Rewriting imports → @preview/folio:{{ VERSION }}..."
            fd -e typ . examples/ tests/ docs/ 2>/dev/null \
                | xargs -I{} sd "$PATTERN" '#import "@preview/folio:{{ VERSION }}"' {} 2>/dev/null || true
            ;;
        dev)
            echo "  → Restoring relative dev imports..."
            fd -e typ -d 1 . examples/ tests/ docs/ 2>/dev/null \
                | xargs -I{} sd "$PATTERN" '#import "../src/lib.typ"' {} 2>/dev/null || true
            fd -e typ --min-depth 2 . examples/ tests/ docs/ 2>/dev/null \
                | xargs -I{} sd "$PATTERN" '#import "../../src/lib.typ"' {} 2>/dev/null || true
            ;;
        *)
            echo "ERROR: _replace-imports expects 'local', 'preview', or 'dev', got '{{ mode }}'"
            exit 1
            ;;
    esac
