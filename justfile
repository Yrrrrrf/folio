# folio — Modular Build System
# ─────────────────────────────────────────────────────────────────────────────
# This justfile imports focused scripts from scripts/ — each with a single
# responsibility. Run `just -l` to see all available recipes grouped by domain.
#
#   Dev    → list, clean, compile, swap-local, swap-dev
#   CI     → fmt, lint, quality
#   Test   → test-all, test-fixture, test-brand, test-components, audit-style
#   Deploy → deploy, manual, publish
#
# Architecture:
#   - Default state is RELATIVE imports (what Typst Universe sees)
#   - Import swapping is centralized in _shared.just (_replace-imports)
#   - Compile is a facade: works for directories AND individual files
#   - Publish is a composed pipeline: swap → audit → test → quality → deploy
# ─────────────────────────────────────────────────────────────────────────────

import "scripts/_shared.just"
import "scripts/dev.just"
import "scripts/ci.just"
import "scripts/test.just"
import "scripts/deploy.just"

# ── default recipe ────────────────────────────────────────────────────────────
[doc("Show all available recipes")]
default:
    @just -l
