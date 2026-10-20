# embed\_rust\_ai\_template

Базовый шаблон для разработки встраиваемых систем на Rust с применением ai-агентов.

Сборка и отладка выполняются **локально на Host** (Linux или macOS), без Docker — [ADR-0004](./docs/adr/0004-local-host-build-no-docker.md). Зависимости ставятся скриптом при старте работ.

Целевые таргеты — stm32f1xx, stm32f3xx, stm32f4xx, stm32g0xx, rp2040, nrf528xx, esp32 (отдельный сценарий), gd32vf1xx.

Первое решение по структуре — [docs/adr/0001-merge-based-target-specialization.md](./docs/adr/0001-merge-based-target-specialization.md): каждая Target-ветка отвечает за одно семейство чипов и подливается в main существующего проекта как одноразовая Специализация; повторная подгрузка шаблона не предполагается.

- в ветке main — База: setup-скрипт, targets-шаблоны (memory.x + Cargo.toml + build.rs + .cargo/config.toml), skills-скелет, агенты, инструкция по началу работы
- поддержка таргетов — базовые конфигурации в `targets/<family>/`; Target-ветка уточняет их под конкретное семейство и Board — [ADR-0005](./docs/adr/0005-targets-directory-template.md)
- подстройка под хост-системы (Linux, macOS) — внутри `setup.sh` и skills; Windows не поддерживается в первом заходе
- термины проекта — [CONTEXT.md](./CONTEXT.md)
- системные инструкции для агентов — [AGENTS.md](./AGENTS.md)

## Начало работы (Linux / macOS)

```sh
./setup.sh                 # ставит Rust + embedded-таргеты + probe-rs + GDB (идемпотентно)
./setup.sh --esp32         # дополнительно xtensa-тулчейн + espflash (для ESP32)
```

- **Linux**: Rust (rustup), embedded-таргеты, probe-rs (бинарник), gdb-multiarch (apt), udev-правила probe-rs;
- **macOS**: то же, но GDB через Homebrew (`brew install gdb`).

## Сборка и отладка (probe-rs)

Профиль = Target × Host: семейство задаётся выбранной конфигурацией из `targets/<family>/`, Host определяется автоматически.

```sh
cargo build                              # сборка (локально, на Host)
cargo run                                # probe-rs run: прошивка + запуск
probe-rs gdb --chip <CHIP> target/<triple>/debug/app   # SWD-отладка (gdb-сервер)
```

Точный чип (`--chip`) и memory.x — забота проекта (Board). Детали — в `targets/<family>/README.md`.

## ESP32 — отдельный сценарий

ESP32 (xtensa) не вписывается в общий probe-rs-путь: тулчейн через `espup`, прошивка через `espflash` (UART), линковщик настраивает esp-hal. Описан отдельно в `targets/esp32/README.md` — [ADR-0005](./docs/adr/0005-targets-directory-template.md).
