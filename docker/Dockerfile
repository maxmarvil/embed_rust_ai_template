# Базовый образ Базы: общий toolchain для сборки и SWD-отладки.
# Target-специфичные зависимости здесь НЕ ставятся — их добавляет Target-ветка
# через docker/target/install.sh (см. docs/adr/0002). База намеренно поставляет
# каталог docker/target/ БЕЗ install.sh, чтобы Специализация только добавляла
# файл и не давала merge-конфликтов.

FROM rust:1.98.1-slim-bookworm

ARG PROBE_RS_VERSION=0.32.0

ENV DEBIAN_FRONTEND=noninteractive \
    CARGO_TERM_COLOR=always

# Общий инструментарий. git в образ не ставится: VCS ведёт Host (агент на Host).
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential \
      pkg-config \
      libusb-1.0-0 \
      libudev1 \
      gdb-multiarch \
      ca-certificates \
      curl \
      tar \
      xz-utils \
 && rm -rf /var/lib/apt/lists/*

# probe-rs из prebuilt-релиза (пин версии, без git и без компиляции из исходников).
RUN set -eux; \
    case "$(dpkg --print-architecture)" in \
      amd64) probe_arch=x86_64-unknown-linux-gnu ;; \
      arm64) probe_arch=aarch64-unknown-linux-gnu ;; \
      *) echo "unsupported arch: $(dpkg --print-architecture)" >&2; exit 1 ;; \
    esac; \
    url="https://github.com/probe-rs/probe-rs/releases/download/v${PROBE_RS_VERSION}/probe-rs-tools-${probe_arch}.tar.xz"; \
    curl -fsSL "$url" -o /tmp/probe-rs.tar.xz; \
    mkdir -p /opt/probe-rs; \
    tar -xJf /tmp/probe-rs.tar.xz -C /opt/probe-rs --strip-components=1; \
    rm /tmp/probe-rs.tar.xz; \
    ln -sf /opt/probe-rs/probe-rs /usr/local/bin/probe-rs; \
    probe-rs --version

WORKDIR /work

# Target-hook (ADR-0002). В Базе install.sh отсутствует — вызов no-op.
# Контекст сборки — каталог docker/, поэтому путь в COPY: target/.
COPY target/ /opt/target-setup/
RUN if [ -f /opt/target-setup/install.sh ]; then bash /opt/target-setup/install.sh; fi
