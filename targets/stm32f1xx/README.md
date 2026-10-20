# stm32f1xx

Семейство ARM Cortex-M3 (STM32F1xx). Rust target: `thumbv7m-none-eabi`.

## Файлы

- `memory.x` — базовая конфигурация памяти (STM32F103C8, Blue Pill: 64K Flash, 20K RAM). Отредактируйте под вашу Board.
- `Cargo.toml` — HAL: `stm32f1xx-hal`, feature `stm32f103` — замените на ваш чип.
- `build.rs` — копирует `memory.x` в OUT_DIR для линковщика.
- `.cargo/config.toml` — target `thumbv7m-none-eabi`, runner `probe-rs run --chip STM32F103C8`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `memory.x`: объём Flash/RAM под конкретный чип (C8/RB/ZE/…);
   - `Cargo.toml`: feature HAL (`stm32f100`, `stm32f101`, `stm32f103`, …);
   - `.cargo/config.toml`: `--chip` для probe-rs.
3. Соберите и запустите:

```sh
./setup.sh                 # зависимости (однократно)
cargo build                # сборка
cargo run                  # probe-rs run: прошивка + запуск
probe-rs gdb --chip STM32F103C8 target/thumbv7m-none-eabi/debug/app   # отладка
```

## Отладка

SWD через Probe (ST-Link и подобные):

```sh
probe-rs gdb --chip STM32F103C8 target/thumbv7m-none-eabi/debug/app
# затем, в другом терминале:
gdb-multiarch target/thumbv7m-none-eabi/debug/app   # Linux
gdb target/thumbv7m-none-eabi/debug/app             # macOS (brew install gdb)
# (gdb) target remote :1337
```

Поиск подключённого Probe/Port — skill `find-embed-connection`.
