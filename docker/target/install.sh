#!/usr/bin/env bash
#
# Target-hook (ADR-0002): STM32F103 (Blue Pill, STM32F103C8T6).
# Cortex-M3 -> thumbv7m-none-eabi. Линкер — штатный rust-lld,
# кросс-toolchain из apt не требуется.
set -euo pipefail

rustup target add thumbv7m-none-eabi
rustup target list --installed
