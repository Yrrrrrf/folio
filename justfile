# folio . JUSTFILE

LOCAL := env('HOME') / ".local/share/typst/packages/local"
VERSION := `rg version typst.toml | cut -d'"' -f2`

[doc("Clean, compile & list all PDF files")]
[group('Dev')]
test: audit-style clean compile list
    @echo "✓ Test completed"
    @fd -uu -e pdf -t f -X rm -f

[doc("Audit for hardcoded visual literals")]
[group('Dev')]
audit-style:
    #!/usr/bin/env bash
    echo "→ Auditing for hardcoded literals in components/ and primitives/..."
    # Flags rgb, luma, and basic named colors
    # We use a broad match for common color names used as literals
    VIOLATIONS=$(rg -n "(rgb\(|luma\(|\b(white|black|red|green|blue|yellow|cyan|magenta|orange|purple|gray|grey|navy|aqua|teal|maroon|fuchsia|silver|olive|lime)\b)" src/components/ src/primitives/)
    if [ -n "$VIOLATIONS" ]; then
        echo "🔴 Style audit failed! Hardcoded literals found:"
        echo "$VIOLATIONS"
        exit 1
    fi
    echo "✓ Style audit passed"

[doc("List all PDF files")]
[group('CI')]
list:
    fd -uu -e pdf -t f

[doc("Remove all PDF files (examples + tests)")]
[group('CI')]
clean:
    @# Uses -uu to bypass .gitignore, and -X to batch-delete them all at once
    fd -uu -e pdf -t f -X rm -f
    fd -uu -e pdf -t f . tests/ -X rm -f

[doc("Compile all examples")]
[group('CI')]
compile:
    @# -e typ: look for typ files
    @# -E data.typ: exclude the shared data file
    @# -x: run the command individually for EVERY match (typst only accepts 1 file at a time)
    fd -e typ -E data.typ . examples/ -x typst compile {}
    fd -e typ -E data.typ . tests/ -x typst compile {}

[doc("Compile integration showcase only")]
[group('Dev')]
test-full:
    typst compile examples/full-standards.typ

[doc("Compile branding demo only")]
[group('Dev')]
test-brand:
    typst compile examples/branding-demo.typ

[doc("Compile every component fixture individually")]
[group('Dev')]
test-components:
    fd -e typ . examples/components/ -x typst compile {}

# Copy folio repository content to local packages
[group('dev')]
local:
    #!/usr/bin/env bash
    TARGET="{{ LOCAL }}/folio/{{ VERSION }}"
    echo "→ Copying folio v{{ VERSION }} into local packages..."
    rm -rf "$TARGET"
    mkdir -p "$TARGET"
    rsync -rL \
        --include='src/' --include='src/**' \
        --include='brand-packs/' --include='brand-packs/**' \
        --include='typst.toml' \
        --exclude='*' \
        "{{ justfile_directory() }}/" "$TARGET/"
    echo "✓ folio v{{ VERSION }} copied at $TARGET"
