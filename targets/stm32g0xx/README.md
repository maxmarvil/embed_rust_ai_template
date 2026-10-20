# stm32g0xx

Семейство ARM Cortex-M0+ (STM32G0xx). Rust target: `thumbv6m-none-eabi`.

## Файлы

- `memory.x` — базовая конфигурация памяти (STM32G071RB: 128K Flash, 36K RAM). Отредактируйте под вашу Board.
- `Cargo.toml` — HAL: `stm32g0xx-hal`, feature `stm32g071` — замените на ваш чип.
- `build.rs` — копирует `memory.x` в OUT_DIR для линковщика.
- `.cargo/config.toml` — target `thumbv6m-none-eabi`, runner `probe-rs run --chip STM32G071RB`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `memory.x`: объём Flash/RAM под конкретный чип (G030/G070/G0B1/…);
   - `Cargo.toml`: feature HAL (`stm32g030`, `stm32g070`, `stm32g071`, …);
   - `.cargo/config.toml`: `--chip` для probe-rs.
3. Соберите и запустите:

```sh
./setup.sh                 # зависимости (однократно)
cargo build                # сборка
cargo run                  # probe-rs run: прошивка + запуск
probe-rs gdb --chip STM32G071RB target/thumbv6m-none-eabi/debug/app   # отладка
```

## Отладка

SWD через Probe (ST-Link и подобные):

```sh
probe-rs gdb --chip STM32G071RB target/thumbv6m-none-eabi/debug/app
# затем, в другом терминале:
gdb-multiarch target/thumbv6m-none-eabi/debug/app   # Linux
gdb target/thumbv6m-none-eabi/debug/app             # macOS (brew install gdb)
# (gdb) target remote :1337
```

Поиск подключённого Probe/Port — skill `find-embed-connection`.
