#!/usr/bin/env bash
# setup.sh — установка зависимостей Базы на Host (Linux / macOS).
# Сборка и отладка выполняются локально на Host, без Docker (ADR-0004).
#
# Использование:
#   ./setup.sh             # базовый набор: Rust, embedded-таргеты, probe-rs, GDB
#   ./setup.sh --esp32     # дополнительно: xtensa-тулчейн и espflash (ADR-0005)
#
# Скрипт идемпотентен: повторный запуск безопасен.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROBE_RS_VERSION="0.32.0"
RUST_EMBEDDED_TARGETS=(
    thumbv6m-none-eabi   # ARMv6-M: rp2040, stm32f0/g0/l0
    thumbv7m-none-eabi   # ARMv7-M: stm32f1/f3/l4
    thumbv7em-none-eabi  # ARMv7E-M: stm32f4/f7/h7, nrf528xx
    thumbv7em-none-eabihf
    riscv32imac-unknown-none-elf  # RISC-V: gd32vf1xx, esp32c3
)

log()   { printf '\033[1;32m[setup]\033[0m %s\n' "$*"; }
warn()  { printf '\033[1;33m[setup]\033[0m %s\n' "$*" >&2; }
die()   { printf '\033[1;31m[setup]\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Определение Host-системы
# ---------------------------------------------------------------------------
detect_os() {
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux)  OS="linux" ;;
        *)      die "Неподдерживаемая ОС: $(uname -s). Поддерживаются Linux и macOS." ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        *)             die "Неподдерживаемая архитектура: $(uname -m)" ;;
    esac
}

have() { command -v "$1" >/dev/null 2>&1; }

# ---------------------------------------------------------------------------
# Rust toolchain
# ---------------------------------------------------------------------------
ensure_rust() {
    if ! have rustup; then
        log "Устанавливаю rustup…"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
            | sh -s -- -y --default-toolchain stable
        # shellcheck disable=SC1091
        source "${HOME}/.cargo/env"
    fi
    if ! have cargo; then
        # shellcheck disable=SC1091
        [ -f "${HOME}/.cargo/env" ] && source "${HOME}/.cargo/env"
    fi
    have cargo || die "cargo недоступен после установки rustup"
    log "Rust: $(rustc --version)"
}

add_rust_targets() {
    log "Добавляю embedded-таргеты Rust…"
    for t in "${RUST_EMBEDDED_TARGETS[@]}"; do
        rustup target add "$t"
    done
}

# ---------------------------------------------------------------------------
# probe-rs
# ---------------------------------------------------------------------------
install_probe_rs() {
    if have probe-rs; then
        log "probe-rs уже установлен: $(probe-rs --version)"
        return 0
    fi

    log "Устанавливаю probe-rs v${PROBE_RS_VERSION} (прямой бинарник)…"
    local tmp artifact
    tmp="$(mktemp -d)"
    trap 'rm -rf "${tmp}"' RETURN

    case "${OS}:${ARCH}" in
        linux:x86_64)   artifact="probe-rs-x86_64-unknown-linux-musl" ;;
        linux:aarch64)  artifact="probe-rs-aarch64-unknown-linux-musl" ;;
        macos:x86_64)   artifact="probe-rs-x86_64-apple-darwin" ;;
        macos:aarch64)  artifact="probe-rs-aarch64-apple-darwin" ;;
        *)              artifact="" ;;
    esac

    # Пробуем несколько имён архива (зависят от релиза); при неудаче — fallback на cargo.
    if [ -n "${artifact}" ]; then
        for url in \
            "https://github.com/probe-rs/probe-rs/releases/download/v${PROBE_RS_VERSION}/${artifact}.tar.gz" \
            "https://github.com/probe-rs/probe-rs/releases/latest/download/${artifact}.tar.gz"
        do
            if curl -fsSL "${url}" -o "${tmp}/probe-rs.tar.gz"; then
                tar -xzf "${tmp}/probe-rs.tar.gz" -C "${tmp}"
                local bin
                bin="$(find "${tmp}" -type f -name probe-rs | head -n1 || true)"
                if [ -n "${bin}" ]; then
                    mkdir -p "${HOME}/.cargo/bin"
                    install -m 0755 "${bin}" "${HOME}/.cargo/bin/probe-rs"
                    log "probe-rs установлен: $(${HOME}/.cargo/bin/probe-rs --version)"
                    return 0
                fi
            fi
        done
    fi

    log "Прямое скачивание не удалось — ставлю через cargo (может занять время)…"
    cargo install probe-rs --locked --version "${PROBE_RS_VERSION}"
}

# ---------------------------------------------------------------------------
# GDB (кросс-отладка)
# ---------------------------------------------------------------------------
install_gdb() {
    # Уже есть подходящий gdb?
    local g
    for g in gdb-multiarch arm-none-eabi-gdb; do
        if have "${g}"; then
            log "GDB уже установлен: ${g} ($(${g} --version | head -n1))"
            return 0
        fi
    done

    if [ "${OS}" = "linux" ]; then
        if have apt-get; then
            log "Устанавливаю gdb-multiarch (apt)…"
            sudo apt-get update
            sudo apt-get install -y gdb-multiarch
        else
            warn "apt-get не найден — установите gdb-multiarch пакетным менеджером вашего дистрибутива."
        fi
    else
        if have brew; then
            log "Устанавливаю gdb (Homebrew)…"
            brew install gdb
        else
            warn "Homebrew не найден — установите его с https://brew.sh и повторите ./setup.sh"
        fi
    fi
}

# ---------------------------------------------------------------------------
# udev-правила (Linux): доступ к Probe без root
# ---------------------------------------------------------------------------
install_udev_rules() {
    [ "${OS}" = "linux" ] || return 0

    local dst="/etc/udev/rules.d/69-probe-rs.rules"
    if [ -f "${dst}" ]; then
        return 0
    fi
    if have udevadm; then
        log "Устанавливаю udev-правила probe-rs (доступ к Probe без root)…"
        curl -fsSL https://probe.rs/files/69-probe-rs.rules | sudo tee "${dst}" >/dev/null
        sudo udevadm control --reload-rules
        sudo udevadm trigger
    else
        warn "udev не найден — возможно, вы в контейнере; пропускаю правила."
    fi
}

# ---------------------------------------------------------------------------
# ESP32 — отдельный сценарий (ADR-0005)
# ---------------------------------------------------------------------------
setup_esp32() {
    log "ESP32: устанавливаю xtensa-тулчейн через espup…"
    if ! have espup; then
        cargo install espup --locked
    fi
    espup install
    # shellcheck disable=SC1091
    [ -f "${HOME}/.espressif/export.sh" ] && warn "Для xtensa-тулчейна выполните: source ${HOME}/.espressif/export.sh"

    log "ESP32: устанавливаю espflash…"
    have espflash || cargo install espflash --locked
    rustup target add riscv32imc-unknown-none-elf  # esp32c3
}

main() {
    local want_esp32=0
    for arg in "$@"; do
        case "${arg}" in
            --esp32) want_esp32=1 ;;
            -h|--help) sed -n '2,9p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
            *) die "Неизвестный аргумент: ${arg} (см. ./setup.sh --help)" ;;
        esac
    done

    detect_os
    detect_arch
    log "Host: ${OS} (${ARCH}) — локальная сборка без Docker"

    ensure_rust
    add_rust_targets
    install_probe_rs
    install_gdb
    install_udev_rules

    if [ "${want_esp32}" = "1" ]; then
        setup_esp32
    fi

    log "Готово. Дальше: cargo build, probe-rs run / probe-rs gdb (см. README.md)."
}

main "$@"
