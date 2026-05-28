# ── Table Column Sizing Gates ─────────────────────────────────────────────────

[doc("Run all table-sizing fitness functions")]
[group('Test')]
check-tables: check-specs check-overflow check-arch
    @echo "✓ All table-sizing gates passed"

[doc("FF-1: No raw auto/fr tuples in components")]
[group('Test')]
check-specs:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "→ FF-1: Checking for raw column tuples in components..."
    COUNT=$( (rg 'columns:\s*\(' src/components/ 2>/dev/null || true) | wc -l | tr -d ' ')
    if [ "$COUNT" -gt 0 ]; then
        echo "🔴 FF-1 FAILED: $COUNT raw column tuples found:"
        rg -n 'columns:\s*\(' src/components/
        exit 1
    fi
    echo "✓ FF-1 passed (0 raw tuples)"

[doc("FF-5: No Typst overflow warnings in example corpus")]
[group('Test')]
check-overflow:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "→ FF-5: Compiling examples, checking for overflow..."
    WARNINGS=""
    for f in $(fd -e typ . examples/); do
        OUTPUT=$(typst compile "$f" /dev/null 2>&1 || true)
        if echo "$OUTPUT" | grep -qi "overflow"; then
            WARNINGS+="  $f: $OUTPUT\n"
        fi
    done
    if [ -n "$WARNINGS" ]; then
        echo "🔴 FF-5 FAILED: Overflow warnings detected:"
        echo -e "$WARNINGS"
        exit 1
    fi
    echo "✓ FF-5 passed (no overflow warnings)"

[doc("FF-arch: Primitive must not import resolver or kind symbols")]
[group('Test')]
check-arch:
    #!/usr/bin/env bash
    set -euo pipefail
    echo "→ FF-arch: Checking dependency direction..."
    if rg -q 'resolver|resolve-columns|kinds' src/primitives/data-table.typ; then
        echo "🔴 FF-arch FAILED: primitive imports resolver/kind symbols"
        rg -n 'resolver|resolve-columns|kinds' src/primitives/data-table.typ
        exit 1
    fi
    echo "✓ FF-arch passed"
