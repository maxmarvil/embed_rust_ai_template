# gd32vf1xx

Семейство GigaDevice GD32VF103 (RISC-V RV32IMAC). Rust target: `riscv32imac-unknown-none-elf`.

## Файлы

- `memory.x` — базовая конфигурация памяти (GD32VF103CB: 128K Flash, 32K RAM). Отредактируйте под вашу Board.
- `Cargo.toml` — рантайм `riscv-rt` + HAL: `gd32vf103xx-hal`.
- `build.rs` — копирует `memory.x` в OUT_DIR для линковщика.
- `.cargo/config.toml` — target `riscv32imac-unknown-none-elf`, runner `probe-rs run --chip GD32VF103`.

## Специализация

1. Скопируйте файлы из этого каталога в корень проекта (merge Target-ветки в main, ADR-0001).
2. Уточните под Board:
   - `memory.x`: объём Flash/RAM под конкретный чип (CB/CT/…);
   - `.cargo/config.toml`: `--chip` для probe-rs.
3. Соберите и запустите:

```sh
./setup.sh                 # зависимости (однократно)
cargo build                # сборка
cargo run                  # probe-rs run: прошивка + запуск
probe-rs gdb --chip GD32VF103 target/riscv32imac-unknown-none-elf/debug/app   # отладка
```

## Отладка

SWD/JTAG через Probe (Sipeed Slogic, J-Link и подобные). GDB — `gdb-multiarch` (Linux) / `gdb` с поддержкой riscv (macOS, `brew install gdb`):

```sh
probe-rs gdb --chip GD32VF103 target/riscv32imac-unknown-none-elf/debug/app
# затем, в другом терминале:
gdb-multiarch target/riscv32imac-unknown-none-elf/debug/app   # Linux
gdb target/riscv32imac-unknown-none-elf/debug/app             # macOS
# (gdb) target remote :1337
```

Поиск подключённого Probe/Port — skill `find-embed-connection`.
