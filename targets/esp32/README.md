# esp32

Семейство Espressif ESP32 — **отдельный сценарий** (ADR-0005), отличается от остальных Target'ов:

- **тулчейн**: xtensa (ESP32/ESP32-S2/S3) ставится через `espup`, не через rustup; ESP32-C3/С6 — RISC-V (`riscv32imc-unknown-none-elf`), rustup;
- **прошивка**: `espflash` через UART (ESP32 classic не имеет SWD/JTAG на дешёвых платах), не probe-rs;
- **линковщик**: `linkall.x` из esp-hal — `memory.x` и `build.rs` в этом сценарии не нужны.

## Файлы

- `Cargo.toml` — HAL: `esp-hal` (feature `esp32`), `esp-backtrace`, `esp-println`.
- `.cargo/config.toml` — target `xtensa-esp32-none-elf`, runner `espflash flash --monitor`, rustflags `-Tlinkall.x`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `Cargo.toml`: feature esp-hal (`esp32`, `esp32s3`, `esp32c3`, …);
   - `.cargo/config.toml`: target (`xtensa-esp32-none-elf` / `xtensa-esp32s3-none-elf` / `riscv32imc-unknown-none-elf`) и runner;
   - edition: esp-hal требует 2024.
3. Зависимости и сборка:

```sh
./setup.sh --esp32        # xtensa-тулчейн (espup) + espflash; для C3 — обычный ./setup.sh
source ~/.espressif/export.sh   # окружение xtensa (в C3 не нужно)
cargo build
cargo run                 # espflash flash --monitor: прошивка + монитор
```

## Отладка

Прошивка и логи — через UART (`espflash flash --monitor`). Для JTAG-отладки (ESP32-S3/C3 с встроенным JTAG) — см. документацию esp-hal и espflash; probe-rs в этом сценарии не используется.

Поиск подключённого Port — skill `find-embed-connection`.
