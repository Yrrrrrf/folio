# ── Testing Workflow ──────────────────────────────────────────────────────────
# Validate that examples and fixtures compile correctly.
# All test recipes delegate to `compile` from dev.just.
# This file must NOT modify source files or swap imports.

# ── test-all ──────────────────────────────────────────────────────────────────
[doc("Compile all examples + all tests")]
[group('Test')]
test: (compile "examples") (compile "tests")
    @echo "✓ All examples and tests compiled"

# ── test-fixture ──────────────────────────────────────────────────────────────
[doc("Compile a single fixture by name (e.g., just test-fixture minimal-data)")]
[group('Test')]
test-fixture name:
    #!/usr/bin/env bash
    set -euo pipefail
    FILE="tests/fixtures/{{ name }}.typ"
    if [ ! -f "$FILE" ]; then
        echo "ERROR: Fixture '$FILE' not found"
        echo "Available fixtures:"
        fd -e typ . tests/fixtures/ --strip-cwd-prefix
        exit 1
    fi
    just compile "$FILE"

# ── test-brand ────────────────────────────────────────────────────────────────
[doc("Compile branding demo + brand pipeline test")]
[group('Test')]
test-brand:
    @echo "→ Testing brand presets..."
    just compile examples/branding-demo.typ
    @if [ -f tests/brand-pipeline.typ ]; then just compile tests/brand-pipeline.typ; fi
    @echo "✓ Brand tests passed"

# ── test-components ───────────────────────────────────────────────────────────
[doc("Compile all component examples")]
[group('Test')]
test-components: (compile "examples/components")
    @echo "✓ Component tests passed"

# ── audit-style ───────────────────────────────────────────────────────────────
[doc("Audit for hardcoded visual literals (colors, sizes) in source")]
[group('Test')]
audit-style:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "→ Auditing for hardcoded color literals..."
    VIOLATIONS=$(rg -n \
        "(rgb\(|luma\(|\b(white|black|red|green|blue|yellow|cyan|magenta|orange|purple|gray|grey|navy|aqua|teal|maroon|fuchsia|silver|olive|lime)\b)" \
        src/components/ \
        src/theme/ui.typ \
        src/core/ \
        --glob '!**/brand-packs/**' 2>/dev/null || true)
    if [ -n "$VIOLATIONS" ]; then
        echo "🔴 Style audit failed! Hardcoded literals found:"
        echo "$VIOLATIONS"
        exit 1
    fi
    echo "✓ Style audit passed"
