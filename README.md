# embed\_rust\_ai\_template

Базовый шаблон для разработки встраиваемых систем в контейнерах docker на языке rust с применением ai-агентов

Окружение для разработки, сборки и отладки  устройств.   
Профили и команды под разные таргеты и разные хост-системы 

Целевые таргеты - stm32f1xx, stm32f3xx, stm32f4xx, stm32g0xx, rp2040, nrf528xx, esp32, gd32vf1xx

Первое решение по структуре — [docs/adr/0001-merge-based-target-specialization.md](./docs/adr/0001-merge-based-target-specialization.md): каждая Target-ветка отвечает за одно семейство чипов и подливается в main существующего проекта как одноразовая Специализация; повторная подгрузка шаблона не предполагается.

- в ветке main — База: docker, Rust toolchain, skills-скелет, агенты, инструкция по началу работы
- поддержка таргетов — в отдельных Target-ветках (по семейству); для специфических devboard допустима отдельная ветка
- подстройка под хост-системы (Linux, macOS) — внутри skills (поиск usb-порта подключённого к целевому устройству); Windows не поддерживается в первом заходе
- термины проекта — [CONTEXT.md](./CONTEXT.md)
- системные инструкции для агентов — [AGENTS.md](./AGENTS.md)

## Docker: сборка и отладка

Образ Базы ставит общий toolchain (Rust, probe-rs, gdb-multiarch) и не знает про Target. Target-специфичные зависимости добавляет Target-ветка файлом `docker/target/install.sh` — [ADR-0002](./docs/adr/0002-target-extension-via-install-hook.md).

```sh
./docker/run.sh build                 # собрать образ embed-rust-ai/base
TARGET=stm32f4xx ./docker/run.sh shell
TARGET=stm32f4xx ./docker/run.sh flash --chip STM32F407VG target/.../app
TARGET=stm32f4xx ./docker/run.sh gdb   --chip STM32F407VG
```

Профиль = Target × Host: `TARGET` задаёт семейство чипов, Host определяется автоматически. Точный чип для probe-rs (`--chip`) остаётся заботой проекта (Board).

Отладка по SWD зависит от Host — [ADR-0003](./docs/adr/0003-swd-debug-host-boundary.md):

- **Linux** — probe-rs работает в контейнере (USB пробрасывается; при необходимости `PRIVILEGED=1`);
- **macOS** — Docker Desktop не пробрасывает USB, поэтому контейнер только собирает, а прошивка/GDB идут с Host (нужен установленный на Host `probe-rs`).

