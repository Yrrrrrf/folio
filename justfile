# folio . JUSTFILE

LOCAL := env('HOME') / "docs/typst/src/packages/local"
VERSION := `rg version typst.toml | cut -d'"' -f2`

[doc("Run a test build")]
[group('Dev')]
test: pdf-clean pdf-compile pdf-list
    echo "✓ Test completed"

[doc("List all PDF files in the current directory")]
[group('CI')]
pdf-list:
    fd -uu -e pdf -t f

[doc("Remove all PDF files from the current directory")]
[group('CI')]
pdf-clean:
    # Uses -uu to bypass .gitignore, and -X to batch-delete them all at once
    fd -uu -e pdf -t f -X rm -f

[doc("Run a typst build of all examples in the `examples/` directory.")]
[group('CI')]
pdf-compile:
    # -e typ: look for typ files
    # -E data.typ: exclude the shared data file
    # -x: run the command individually for EVERY match (typst only accepts 1 file at a time)
    fd -e typ -E data.typ . examples/ -x typst compile {}

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
        --include='typst.toml' \
        --exclude='*' \
        "{{ justfile_directory() }}/" "$TARGET/"
    echo "✓ folio v{{ VERSION }} copied at $TARGET"
