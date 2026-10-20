# stm32f3xx

Семейство ARM Cortex-M4/M3-гибрид (STM32F3xx). Rust target: `thumbv7m-none-eabi` (soft-float).

## Файлы

- `memory.x` — базовая конфигурация памяти (STM32F303VC: 256K Flash, 40K RAM). Отредактируйте под вашу Board.
- `Cargo.toml` — HAL: `stm32f3xx-hal`, feature `stm32f303` — замените на ваш чип.
- `build.rs` — копирует `memory.x` в OUT_DIR для линковщика.
- `.cargo/config.toml` — target `thumbv7m-none-eabi`, runner `probe-rs run --chip STM32F303VC`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `memory.x`: объём Flash/RAM под конкретный чип;
   - `Cargo.toml`: feature HAL (`stm32f301`, `stm32f303`, `stm32f334`, …);
   - `.cargo/config.toml`: `--chip` для probe-rs.
3. Соберите и запустите:

```sh
./setup.sh                 # зависимости (однократно)
cargo build                # сборка
cargo run                  # probe-rs run: прошивка + запуск
probe-rs gdb --chip STM32F303VC target/thumbv7m-none-eabi/debug/app   # отладка
```

## Отладка

SWD через Probe (ST-Link и подобные):

```sh
probe-rs gdb --chip STM32F303VC target/thumbv7m-none-eabi/debug/app
# затем, в другом терминале:
gdb-multiarch target/thumbv7m-none-eabi/debug/app   # Linux
gdb target/thumbv7m-none-eabi/debug/app             # macOS (brew install gdb)
# (gdb) target remote :1337
```

Поиск подключённого Probe/Port — skill `find-embed-connection`.
