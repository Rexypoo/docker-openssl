FROM alpine AS build
WORKDIR /build/tmp
RUN apk add --no-cache \
    gcc \
    libc-dev \
    linux-headers \
    make \
    perl 
ADD https://github.com/openssl/openssl/archive/OpenSSL_1_0_2-stable.tar.gz openssl-src.tar.gz
RUN tar \
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

ARG BUILD_DATE
ARG VCS_REF

LABEL org.opencontainers.image.created=$BUILD_DATE \
      org.opencontainers.image.url="https://hub.docker.com/r/rexypoo/openssl" \
      org.opencontainers.image.documentation="https://hub.docker.com/r/rexypoo/openssl" \
      org.opencontainers.image.source="https://github.com/Rexypoo/docker-openssl" \
      org.opencontainers.image.version="1.0.2" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.opencontainers.image.licenses="(MIT AND OpenSSL)" \
      org.opencontainers.image.ref.name="1.0.2-alpine" \
      org.opencontainers.image.description="A lightweight openssl image built from source." \
      org.opencontainers.image.title="rexypoo/openssl" \
      org.label-schema.docker.cmd="docker run -it --rm rexypoo/openssl <arguments>" \
      org.label-schema.docker.cmd.devel="docker run -it --rm rexypoo/openssl:dev" \
      org.label-schema.docker.cmd.debug="docker exec -it <container> sh" \
      org.label-schema.docker.cmd.help="docker run -it --rm rexypoo/openssl list -help"
