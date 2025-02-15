ARG GOLANG_VERSION=1.19.0
ARG ALPINE_VERSION=3.18

FROM library/golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS trivy

FROM trivy as trivy-amd64
ARG TRIVY_VERSION=0.42.0
RUN set -ex; \
    wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"; \
    tar -xzf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz; \
    mv trivy /usr/local/bin

FROM trivy as trivy-arm64
ARG TRIVY_VERSION=0.42.0
RUN set -ex; \
    wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-ARM64.tar.gz"; \
    tar -xzf trivy_${TRIVY_VERSION}_Linux-ARM64.tar.gz; \
    mv trivy /usr/local/bin

FROM trivy-${TARGETARCH} as trivy-base

FROM library/golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION}
RUN apk --no-cache add \
    bash \
    coreutils \
    curl \
    docker \
    file \
    g++ \
    gcc \
    git \
    make \
    mercurial \
    rsync \
    subversion \
    wget \
    yq
COPY scripts/ /usr/local/go/bin/
COPY --from=trivy-base /usr/local/bin/ /usr/bin/
RUN set -x && \
    chmod -v +x /usr/local/go/bin/go-*.sh && \
    go version && \
    trivy image --download-db-only --quiet
