#!/usr/bin/env bash
set -e

echo "Running check-docs.sh..."

# Check F1: No raw italic crosswalk references survive (Gated: only applied to files importing crosswalk.typ)
for f in docs/chapters/*.typ; do
    if grep -q "import.*_helpers/crosswalk.typ" "$f" 2>/dev/null; then
        if grep -qE '\*PMBOK|\*PRINCE2' "$f"; then
            echo "F1 Failed in $f: Raw italic crosswalk references found."
            exit 1
        fi
        
        # Check F2: Every crosswalk-using chapter imports the helper
        if ! grep -qE '#?crosswalk[[:space:]]*\(' "$f"; then
            echo "F2 Failed in $f: crosswalk imported but not used."
            exit 1
        fi
    fi
done

# Check F3 and F4: project-page dog-fooding (Gated)
if [ -f "docs/manual.typ" ]; then
    if grep -qE 'project-page[[:space:]]*\(' docs/manual.typ; then
        # If it's dog-fooding, we shouldn't use raw outline
        if grep -qE '^#?outline[[:space:]]*\(' docs/manual.typ; then
            echo "F4 Failed: manual.typ contains raw outline()."
            exit 1
        fi
    fi
fi

# Gate Phase 3 checks based on placeholder in schema-table.typ
if [ -f "docs/_helpers/schema-table.typ" ] && ! grep -q "Phase 3 pending" "docs/_helpers/schema-table.typ"; then
    SCHEMA_ROWS=$(grep -cE '^[[:space:]]*\(path:' docs/_helpers/schema-data.typ || echo 0)
    if [ "$SCHEMA_ROWS" -lt 40 ]; then
        echo "F5 Failed: schema-data.typ has < 40 rows."
        exit 1
    fi

    for ns in metadata initiation baselines registers governance closure; do
        if ! grep -qE "path:[[:space:]]*\"$ns\." docs/_helpers/schema-data.typ; then
            echo "F7 Failed: Namespace $ns missing from schema."
            exit 1
        fi
    done

    GLOSSARY_TERMS=$(grep -cE '^[[:space:]]*\(term:' docs/_helpers/schema-data.typ || echo 0)
    if [ "$GLOSSARY_TERMS" -lt 25 ]; then
        echo "F8 Failed: glossary-terms < 25"
        exit 1
    fi

    MATRIX_ROWS=$(grep -cE '^[[:space:]]*\(namespace:' docs/_helpers/schema-data.typ || echo 0)
    if [ "$MATRIX_ROWS" -ne 6 ]; then
        echo "F9 Failed: crosswalk-matrix != 6 rows"
        exit 1
    fi
fi

# F10: Version string consistency
if ! grep -q '0.0.1' typst.toml || ! grep -q '0.0.1' src/lib.typ; then
    echo "F10 Failed: Version 0.0.1 mismatch"
    exit 1
fi

# F11: No TODO/FIXME/PLACEHOLDER
if grep -qE 'TODO|FIXME|PLACEHOLDER' docs/chapters/*.typ docs/_helpers/*.typ 2>/dev/null; then
    echo "F11 Failed: TODO/FIXME/PLACEHOLDER found."
    exit 1
fi

# F12: Chapters limit imports
for f in docs/chapters/*.typ; do
    if [ -f "$f" ]; then
        while read -r line; do
            if echo "$line" | grep -qE '^[[:space:]]*#import'; then
                # only allow _fixture.typ, ../../src/lib.typ, ../_helpers/...
                if ! echo "$line" | grep -qE '"_fixture\.typ"|"\.\./\.\./src.*\.typ"|"\.\."?/_helpers/[A-Za-z0-9_-]+\.typ"|"@preview/folio[A-Za-z0-9:.-]*"'; then
                    echo "F12 Failed: Invalid import in $f - $line"
                    exit 1
                fi
            fi
        done < "$f"
    fi
done

echo "check-docs.sh passed!"
exit 0

# --- Phase 7 Architecture Fitness Functions ---

echo "Running Phase 7 Fitness Functions..."

# Fitness 1 — primitives must not call get-state
if grep -rE 'get-state\(' src/primitives/ ; then
    echo "Architecture Violation: primitives must not call get-state."
    exit 1
fi

# Fitness 2 — every registered section in mod.typ has a corresponding file
for sec in $(grep -oE '"[a-z-]+":' src/sections/mod.typ | tr -d '":'); do
    # Skip standard keys that might match the pattern but aren't files if any
    find src/sections -name "${sec}.typ" -print | grep -q . || { echo "Architecture Violation: missing section file for registered section '$sec'"; exit 1; }
done

# Fitness 3 — every kind exports manifest dict and *-doc fn
for k in src/kinds/*.typ; do
    base=$(basename "$k")
    [ "$base" = "_manifest.typ" ] && continue
    [ "$base" = "mod.typ" ] && continue
    if ! (grep -qE '#let [a-z-]+ = \(' "$k" && grep -qE '#let [a-z-]+-doc' "$k"); then
        echo "Architecture Violation: kind '$base' must export manifest dict and *-doc fn."
        exit 1
    fi
done

echo "Phase 7 Fitness Functions passed!"
