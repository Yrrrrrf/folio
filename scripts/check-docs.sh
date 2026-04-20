#!/bin/bash
set -e

# Run from package root
cd "$(dirname "$0")/.."

# 1. No chapter file contains #include or #import of another chapter file
if grep -qE '^#(include|import).*ch[0-9]' docs/chapters/*.typ; then
  echo "Error: Chapters must not include/import each other"
  exit 1
fi

# 2. Every chapter from Ch 2 onward imports _fixture.typ OR declares it doesn't
for file in docs/chapters/ch0[2-9]*.typ docs/chapters/ch1[0-9]*.typ; do
  if [ -f "$file" ]; then
    if ! grep -q '_fixture.typ\|intentionally does not need the fixture' "$file"; then
      echo "Error: $file does not import _fixture.typ and does not ignore it"
      exit 1
    fi
  fi
done

# 3. Capital chapters must contain organism invocations
if ! grep -q 'charter-doc' docs/chapters/ch04-*.typ; then
  echo "Error: ch04 missing charter-doc invocation"
  exit 1
fi
if ! grep -q 'status-report-doc' docs/chapters/ch05-*.typ; then
  echo "Error: ch05 missing status-report-doc invocation"
  exit 1
fi

# 4. typst.toml exclude list is non-empty and contains docs/**
if ! grep -q 'exclude = \[.*"docs/\*\*".*\]' typst.toml; then
  echo "Error: typst.toml docs/** exclude missing"
  exit 1
fi

echo "All fitness tests passed!"
