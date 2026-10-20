# rp2040

Raspberry Pi RP2040 (ARM Cortex-M0+ dual-core). Rust target: `thumbv6m-none-eabi`.

## Файлы

- `memory.x` — конфигурация памяти: BOOT2 (256 байт second-stage bootloader), внешний QSPI FLASH (база 2MB — как на Pico; зависит от Board), RAM 264K.
- `Cargo.toml` — HAL: `rp2040-hal` + `rp2040-boot2` (second-stage bootloader в бинарнике).
- `build.rs` — копирует `memory.x` в OUT_DIR для линковщика.
- `.cargo/config.toml` — target `thumbv6m-none-eabi`, runner `probe-rs run --chip RP2040`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `memory.x`: объём QSPI FLASH (Pico — 2MB, Pico 2 — иначе, сторонние платы — 4/8/16MB);
   - `Cargo.toml`: version `rp2040-boot2` (W25Q080 — Pico; при кастомном FLASH — свой BOOT2);
   - `.cargo/config.toml`: `--chip` для probe-rs.
3. Соберите и запустите:

```sh
./setup.sh                 # зависимости (однократно)
cargo build                # сборка
cargo run                  # probe-rs run: прошивка + запуск
probe-rs gdb --chip RP2040 target/thumbv6m-none-eabi/debug/app   # отладка
```

## Отладка

SWD через Probe (Picoprobe, Raspberry Pi Debug Probe и подобные):

```sh
probe-rs gdb --chip RP2040 target/thumbv6m-none-eabi/debug/app
# затем, в другом терминале:
gdb-multiarch target/thumbv6m-none-eabi/debug/app   # Linux
gdb target/thumbv6m-none-eabi/debug/app             # macOS (brew install gdb)
# (gdb) target remote :1337
```

Поиск подключённого Probe/Port — skill `find-embed-connection`.
