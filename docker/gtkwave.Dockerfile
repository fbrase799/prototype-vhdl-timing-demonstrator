FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        fluxbox \
        gtkwave \
        novnc \
        websockify \
        x11vnc \
        xvfb \
    && rm -rf /var/lib/apt/lists/* \
    && printf '%s\n' \
        '<!DOCTYPE html>' \
        '<meta http-equiv="refresh" content="0;url=vnc.html?autoconnect=1&resize=scale&reconnect=1">' \
        > /usr/share/novnc/index.html \
    && mkdir -p /root/.fluxbox \
    && printf '%s\n' \
        '[app] (name=gtkwave)' \
        '  [Maximized] {yes}' \
        '[end]' \
        > /root/.fluxbox/apps \
    && printf '%s\n' \
        'session.screen0.toolbar.visible: false' \
        > /root/.fluxbox/init

COPY docker/gtkwave-entrypoint.sh /usr/local/bin/gtkwave-entrypoint
RUN chmod +x /usr/local/bin/gtkwave-entrypoint

WORKDIR /work
EXPOSE 6080

ENTRYPOINT ["gtkwave-entrypoint"]
