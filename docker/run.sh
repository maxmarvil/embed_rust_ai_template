#!/usr/bin/env bash
#
# Единая точка запуска docker-окружения Базы: сборка образа, оболочка,
# прошивка и SWD-отладка через probe-rs.
#
# Профиль = <Target, Host>. Target задаётся переменной TARGET (семейство чипов,
# влияет только на toolchain, установленный Target-веткой). Host определяется
# автоматически по uname. Ветвление по Host — см. docs/adr/0003:
#   Linux  — probe-rs работает В КОНТЕЙНЕРЕ (USB пробрасывается);
#   macOS  — probe-rs работает НА HOST (Docker Desktop не пробрасывает USB).
set -euo pipefail

IMAGE="${IMAGE:-embed-rust-ai/base}"
DOCKER="${DOCKER:-docker}"
TARGET="${TARGET:-}"
GDB_PORT="${GDB_PORT:-1337}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

die() { printf 'run.sh: %s\n' "$*" >&2; exit 1; }

detect_host() {
  case "$(uname -s)" in
    Linux)  printf 'linux' ;;
    Darwin) printf 'macos' ;;
    *) die "unsupported host: $(uname -s) (Linux and macOS only)" ;;
  esac
}

detect_platform() {
  case "$(uname -m)" in
    x86_64|amd64) printf 'linux/amd64' ;;
    arm64|aarch64) printf 'linux/arm64' ;;
    *) die "unsupported architecture: $(uname -m)" ;;
  esac
}

HOST="$(detect_host)"
PLATFORM="$(detect_platform)"

# Аргументы монтирования: репозиторий виден внутри как /work.
RUN_ARGS=(-v "${REPO_ROOT}:/work" -w /work)
if [ -n "$TARGET" ]; then
  RUN_ARGS+=(-e "EMBED_TARGET=${TARGET}")
fi

# Доступ к Probe по USB. Только Linux: macOS-контейнер железо не увидит (ADR-0003).
USB_ARGS=()
if [ "$HOST" = linux ]; then
  if [ "${PRIVILEGED:-0}" = 1 ]; then
    USB_ARGS=(--privileged)
  else
    USB_ARGS=("--device-cgroup-rule=c 189:* rmw" -v /dev/bus/usb:/dev/bus/usb)
  fi
fi

profile() {
  printf 'profile: target=%s host=%s' "${TARGET:-<unset>}" "$HOST"
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args...]

Commands:
  build            Собрать образ ${IMAGE} под текущую архитектуру
  shell            Интерактивная оболочка в контейнере (репозиторий в /work)
  flash <args...>  Прошивка: probe-rs download <args...>
  gdb   <args...>  GDB-сервер: probe-rs gdb <args...>
  clean            Удалить образ ${IMAGE}

Переменные окружения:
  TARGET=<family>  Профиль: Target, напр. stm32f4xx (Host определяется сам)
  IMAGE, DOCKER, GDB_PORT
  PRIVILEGED=1     Linux: запустить контейнер с --privileged вместо проброса USB

$(profile)
EOF
}

require_image() {
  "$DOCKER" image inspect "$IMAGE" >/dev/null 2>&1 \
    || die "образ '${IMAGE}' не найден; сначала: $(basename "$0") build"
}

require_host_probe_rs() {
  command -v probe-rs >/dev/null 2>&1 \
    || die "probe-rs не найден на Host; на macOS отладка идёт с Host (ADR-0003)"
}

# run_probe_rs <subcommand> [args...] — выполнить probe-rs в нужном месте.
run_probe_rs() {
  local sub="$1"; shift
  if [ "$HOST" = linux ]; then
    require_image
    local extra=()
    if [ "$sub" = gdb ]; then
      extra=(-p "${GDB_PORT}:${GDB_PORT}")
    fi
    "$DOCKER" run -it --rm \
      "${RUN_ARGS[@]}" \
      ${USB_ARGS[@]+"${USB_ARGS[@]}"} \
      ${extra[@]+"${extra[@]}"} \
      "$IMAGE" probe-rs "$sub" "$@"
  else
    require_host_probe_rs
    probe-rs "$sub" "$@"
  fi
}

cmd_build() {
  "$DOCKER" build --platform "$PLATFORM" -t "$IMAGE" "$SCRIPT_DIR"
}

cmd_shell() {
  require_image
  "$DOCKER" run -it --rm \
    "${RUN_ARGS[@]}" \
    ${USB_ARGS[@]+"${USB_ARGS[@]}"} \
    "$IMAGE" bash
}

cmd_flash() { run_probe_rs download "$@"; }
cmd_gdb()   { run_probe_rs gdb "$@"; }

cmd_clean() {
  "$DOCKER" image rm "$IMAGE" >/dev/null 2>&1 || true
}

main() {
  [ $# -ge 1 ] || { usage; exit 1; }
  local cmd="$1"; shift
  case "$cmd" in
    build) cmd_build ;;
    shell) cmd_shell ;;
    flash) cmd_flash "$@" ;;
    gdb)   cmd_gdb "$@" ;;
    clean) cmd_clean ;;
    -h|--help|help) usage ;;
    *) die "unknown command: ${cmd} (see --help)" ;;
  esac
}

main "$@"
