#!/bin/sh
set -eu

export DISPLAY=:0

Xvfb :0 -screen 0 1920x1080x24 -ac -noreset >/tmp/xvfb.log 2>&1 &
sleep 0.4

fluxbox >/tmp/fluxbox.log 2>&1 &
x11vnc -display :0 -forever -shared -nopw -rfbport 5900 -quiet \
    >/tmp/x11vnc.log 2>&1 &

VCD=/work/build/timing_controller.vcd
GTKW=/work/docker/timing_controller.gtkw
RC=/work/docker/gtkwaverc
TCL=/work/docker/zoom_full.tcl

GTKWAVE_OPTS=""
if [ -f "$RC" ]; then
    GTKWAVE_OPTS="$GTKWAVE_OPTS --rcfile=$RC"
fi
if [ -f "$TCL" ]; then
    GTKWAVE_OPTS="$GTKWAVE_OPTS -S $TCL"
fi

if [ -f "$VCD" ] && [ -f "$GTKW" ]; then
    # shellcheck disable=SC2086
    gtkwave $GTKWAVE_OPTS "$VCD" "$GTKW" >/tmp/gtkwave.log 2>&1 &
elif [ -f "$VCD" ]; then
    # shellcheck disable=SC2086
    gtkwave $GTKWAVE_OPTS "$VCD" >/tmp/gtkwave.log 2>&1 &
else
    gtkwave >/tmp/gtkwave.log 2>&1 &
fi

echo "GTKWave is available at http://localhost:6080"
exec websockify --web=/usr/share/novnc 6080 localhost:5900
