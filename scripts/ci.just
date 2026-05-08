# ── Quality Assurance Workflow ─────────────────────────────────────────────────
# Static code quality recipes: formatting, linting, and the combined quality gate.
# This file must NOT compile, test, or deploy.
#
# NOTE: Typst 0.14 does not have `fmt` or `lint` subcommands.
# These recipes use typstfmt (external) if available, and compile-based checks.
# When Typst adds native fmt/lint, these recipes can be updated in one place.

# ── fmt ───────────────────────────────────────────────────────────────────────
[doc("Format Typst source files (requires typstfmt or typstyle)")]
[group('CI')]
fmt:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v typstfmt &>/dev/null; then
        echo "→ Formatting with typstfmt..."
        fd -e typ . src/ -x typstfmt {}
        echo "✓ Formatting complete"
    elif command -v typstyle &>/dev/null; then
        echo "→ Formatting with typstyle..."
        fd -e typ . src/ -x typstyle format-all {}
        echo "✓ Formatting complete"
    else
        echo "⚠ No formatter found (typstfmt or typstyle). Skipping format step."
        echo "  Install: cargo install typstfmt  OR  cargo install typstyle"
    fi

# ── lint ──────────────────────────────────────────────────────────────────────
[doc("Lint by compiling all examples (catches errors at build time)")]
[group('CI')]
lint:
    @echo "→ Linting (compile check)..."
    @just compile examples
    @just compile tests
    @echo "✓ Lint complete (all files compile)"

# ── quality ───────────────────────────────────────────────────────────────────
[doc("Run full quality gate (format + lint)")]
[group('CI')]
quality: fmt lint
    @echo "✓ Quality gate passed"
