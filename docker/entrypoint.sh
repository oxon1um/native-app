#!/bin/sh
set -eu

export DISPLAY="${DISPLAY:-:99}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-sage}"

mkdir -p "$SAGE_DATA_DIR" "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

Xvfb "$DISPLAY" -screen 0 "${RESOLUTION:-1280x800x24}" -ac -nolisten tcp &
sleep 1
openbox-session &

if [ -n "${VNC_PASSWORD:-}" ]; then
    password_file=/tmp/x11vnc.pass
    x11vnc -storepasswd "$VNC_PASSWORD" "$password_file" >/dev/null
    vnc_auth="-rfbauth $password_file"
else
    vnc_auth="-nopw"
fi

# shellcheck disable=SC2086
x11vnc \
    -display "$DISPLAY" \
    -forever \
    -shared \
    -rfbport 5900 \
    $vnc_auth \
    >/tmp/x11vnc.log 2>&1 &

websockify \
    --web=/usr/share/novnc \
    6080 \
    localhost:5900 \
    >/tmp/websockify.log 2>&1 &

exec dbus-run-session -- /usr/local/bin/native-app \
    -ui webview \
    -data "$SAGE_DATA_DIR" \
    "$@"
