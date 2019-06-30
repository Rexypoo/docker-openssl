FROM alpine AS fetch_source
WORKDIR /build/tmp
ADD https://openssl.org/source/openssl-1.1.1c.tar.gz openssl-src.tar.gz

FROM fetch_source AS verify
ADD https://openssl.org/source/openssl-1.1.1c.tar.gz.asc \
    openssl-src.tar.gz.asc
ENV key_ids='8657ABB260F056B1E5190839D9C4D26D0E604491 \
             7953AC1FBC3DC8B3B292393ED5E9E43F7DF9EE8C'
COPY sh/gpg-add.sh gpg-add.sh
RUN apk add --no-cache \
    gnupg \
    && for key_id in $key_ids; do \
        ./gpg-add.sh "$key_id"; \
    done \
    && gpg --verify openssl-src.tar.gz.asc openssl-src.tar.gz

FROM fetch_source AS build
RUN apk add --no-cache \
    gcc \
    libc-dev \
    linux-headers \
    make \
    perl \
    && tar \
    --extract \
    --file openssl-src.tar.gz \
    --strip 1 \
    && ./config \
    --openssldir=/srv/openssl \
    --prefix=/build/openssl \
    -static \
    && make \
    && make install

FROM alpine AS base
WORKDIR /srv/openssl
COPY --from=build /build/tmp/LICENSE .
ENTRYPOINT ["openssl"]

FROM base AS clean
COPY --from=build /build/openssl /usr/local

FROM base AS lite
COPY --from=build /build/openssl/bin/openssl /usr/local/bin/openssl

FROM gcr.io/distroless/static AS distroless
WORKDIR /srv/openssl
COPY --from=build /build/openssl/bin/openssl /usr/local/bin/openssl
COPY --from=build /build/tmp/LICENSE .
ENTRYPOINT ["openssl"]

FROM clean AS dev
RUN apk add --no-cache \
    bash \
    man
ENTRYPOINT ["bash"]

FROM clean AS release

LABEL org.opencontainers.image.authors="docker-openssl@rexypoo.com" \
      org.opencontainers.image.url="https://hub.docker.com/r/rexypoo/openssl" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/rexypoo/openssl" \
      org.opencontainers.image.source="https://github.com/Rexypoo/docker-openssl" \
      org.opencontainers.image.vendor="rexypoo" \
      org.opencontainers.image.licenses="(MIT AND OpenSSL)" \
      org.opencontainers.image.title="rexypoo/openssl" \
      org.opencontainers.image.description="A lightweight openssl image built from source." \
      org.label-schema.docker.cmd="docker run -it --rm rexypoo/openssl <arguments>" \
      org.label-schema.docker.cmd.devel="docker run -it --rm rexypoo/openssl:dev" \
      org.label-schema.docker.cmd.debug="docker exec -it <container> sh" \
      org.label-schema.docker.cmd.help="docker run -it --rm rexypoo/openssl list -help"
