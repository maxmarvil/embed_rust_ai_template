# stm32f4xx

Семейство ARM Cortex-M4F (STM32F4xx). Rust target: `thumbv7em-none-eabi` (soft-float).

## Файлы

- `memory.x` — базовая конфигурация памяти (STM32F407VG: 1MB Flash, 128K RAM). Отредактируйте под вашу Board.
- `Cargo.toml` — HAL: `stm32f4xx-hal`, feature `stm32f407` — замените на ваш чип.
- `build.rs` — копирует `memory.x` в OUT_DIR для линковщика.
- `.cargo/config.toml` — target `thumbv7em-none-eabi`, runner `probe-rs run --chip STM32F407VG`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `memory.x`: объём Flash/RAM под конкретный чип;
   - `Cargo.toml`: feature HAL (`stm32f401`, `stm32f407`, `stm32f411`, …);
   - `.cargo/config.toml`: `--chip` для probe-rs.
3. Соберите и запустите:

```sh
./setup.sh                 # зависимости (однократно)
cargo build                # сборка
cargo run                  # probe-rs run: прошивка + запуск
probe-rs gdb --chip STM32F407VG target/thumbv7em-none-eabi/debug/app   # отладка
```

## Отладка

SWD через Probe (ST-Link и подобные):

```sh
probe-rs gdb --chip STM32F407VG target/thumbv7em-none-eabi/debug/app
# затем, в другом терминале:
gdb-multiarch target/thumbv7em-none-eabi/debug/app   # Linux
gdb target/thumbv7em-none-eabi/debug/app             # macOS (brew install gdb)
# (gdb) target remote :1337
```

Поиск подключённого Probe/Port — skill `find-embed-connection`.
