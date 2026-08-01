#!/bin/bash

set -e

run_test() {
    DEBCONF_SECRET="$1"

    TMPDIR=$(mktemp -d)
    trap 'rm -rf "$TMPDIR"' EXIT

    cp debian/postinst "$TMPDIR/postinst"

    mkdir -p "$TMPDIR/usr/share/debconf"
    mkdir -p "$TMPDIR/etc/jitsi/videobridge"
    mkdir -p "$TMPDIR/etc/default"

    touch "$TMPDIR/etc/jitsi/videobridge/config"

    cat > "$TMPDIR/usr/share/debconf/confmodule" <<'EOF'
#!/bin/sh

RET=""

db_get() {
    case "$1" in
        jitsi-videobridge/jvbsecret)
            RET="$DEBCONF_SECRET"
            ;;
        jitsi-videobridge/jvb-hostname)
            RET="test.example.com"
            ;;
    esac
}

db_set() {
    :
}

db_stop() {
    :
}
EOF

    chmod +x "$TMPDIR/usr/share/debconf/confmodule"

    export DEBCONF_SECRET

    (
        cd "$TMPDIR"
        bash ./postinst configure
    )

    if [ -n "$1" ]; then
    grep -q "$1" "$TMPDIR/etc/jitsi/videobridge/jvb.conf"
else
    PASSWORD=$(grep 'PASSWORD=' "$TMPDIR/etc/jitsi/videobridge/jvb.conf" | sed 's/.*PASSWORD="\([^"]*\)".*/\1/')

    if [ -z "$PASSWORD" ]; then
        echo "Secret was not generated"
        exit 1
    fi
fi

    rm -rf "$TMPDIR"
}


echo "Testing existing secret reuse"
run_test "existing-secret"

echo "Testing secret generation"
run_test ""

echo "Test passed"
