# ── Quality Assurance Workflow ─────────────────────────────────────────────────
# Static code quality recipes: formatting, linting, and the combined quality gate.
# This file must NOT compile, test, or deploy.

[doc("Format all Typst source files with typstyle")]
[group('CI')]
fmt:
    @echo "→ Formatting with typstyle..."
    @typstyle -i . -v
    @echo "✓ Formatting complete"

[doc("Lint by compiling all examples (catches errors at build time)")]
[group('CI')]
lint:
    @echo "→ Linting (compile check)..."
    @just compile examples
    @just compile tests
    @echo "✓ Lint complete (all files compile)"

[doc("Run full quality gate (format + lint)")]
[group('CI')]
quality: fmt lint
    @echo "✓ Quality gate passed"
