ARG BASE_IMAGE=debian:bookworm-slim

FROM ${BASE_IMAGE}

ARG DANTE_PORT=1080

RUN apt-get update && \
    apt-get install -y --no-install-recommends dante-server gettext-base && \
    rm -rf /var/lib/apt/lists/*

COPY danted.conf.tpl /etc/danted.conf.tpl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE ${DANTE_PORT}

ENTRYPOINT ["/entrypoint.sh"]
