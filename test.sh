#!/bin/bash

OUTPUT=""

if [ "$1" = "--output_path" ]; then
    OUTPUT="$2"
    shift 2
fi

MODE="$1"

FAILED=0

if [ "$MODE" = "base" ]; then
    echo "Running base tests..."
elif [ "$MODE" = "new" ]; then
    echo "Running new tests..."
    ./tests/test-postinst-secret.sh || FAILED=1
else
    echo "Unknown mode"
    exit 1
fi

if [ -n "$OUTPUT" ]; then
    mkdir -p "$(dirname "$OUTPUT")"

    if [ "$FAILED" -eq 0 ]; then
        FAILURES=0
    else
        FAILURES=1
    fi
    cat > "$OUTPUT" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<testsuite name="tests" tests="1" failures="$FAILURES">
  <testcase classname="postinst" name="secret">
EOF

if [ "$FAILED" -ne 0 ]; then
cat >> "$OUTPUT" <<EOF
    <failure message="Test failed"/>
EOF
fi

cat >> "$OUTPUT" <<EOF
  </testcase>
</testsuite>
EOF

    
fi

exit "$FAILED"
