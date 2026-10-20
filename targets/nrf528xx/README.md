# nrf528xx

Семейство Nordic nRF52 (ARM Cortex-M4F). Rust target: `thumbv7em-none-eabihf` (hard-float).

## Файлы

- `memory.x` — базовая конфигурация памяти (nRF52840: 1MB Flash, 256K RAM; Flash начинается с 0x0 — мягкий чип). Отредактируйте под вашу Board.
- `Cargo.toml` — HAL: `nrf52840-hal` — замените на HAL вашего чипа (`nrf52832-hal`, …).
- `build.rs` — копирует `memory.x` в OUT_DIR для линковщика.
- `.cargo/config.toml` — target `thumbv7em-none-eabihf`, runner `probe-rs run --chip nRF52840_xxAA`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `memory.x`: объём Flash/RAM под конкретный чип (52832: 512K/64K, 52810: 192K/24K, …);
   - `Cargo.toml`: HAL crate под чип;
   - `.cargo/config.toml`: `--chip` для probe-rs.
3. Соберите и запустите:

```sh
./setup.sh                 # зависимости (однократно)
cargo build                # сборка
cargo run                  # probe-rs run: прошивка + запуск
probe-rs gdb --chip nRF52840_xxAA target/thumbv7em-none-eabihf/debug/app   # отладка
```

## Отладка

SWD через Probe (J-Link, CMSIS-DAP и подобные):

```sh
probe-rs gdb --chip nRF52840_xxAA target/thumbv7em-none-eabihf/debug/app
# затем, в другом терминале:
gdb-multiarch target/thumbv7em-none-eabihf/debug/app   # Linux
gdb target/thumbv7em-none-eabihf/debug/app             # macOS (brew install gdb)
# (gdb) target remote :1337
```

Поиск подключённого Probe/Port — skill `find-embed-connection`.
