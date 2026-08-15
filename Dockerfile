FROM debian:bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ghdl \
        make \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work

CMD ["bash"]
