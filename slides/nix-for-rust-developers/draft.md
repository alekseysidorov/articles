# Nix для Rust-разработчика

## Проблема

Кажется, что для Rust-проекта достаточно:

```bash
cargo build
```

Но в реальности нужно:

- Сам Rust инструментарий: `rustup`, `clippy`.
- Дополнительные утилиты типо `taplo`, `typos`.
- Системные зависиомсти (`openssl`, `protobuf`, `rdkafka`)
- Скрипты для CI
- Git хуки

---

## Типичная структура проекта

```
repo/
 ├ Cargo.toml
 ├ rust-toolchain.toml
 ├ Makefile
 ├ scripts/
 ├ docker/
 ├ .github/workflows/
 ├ README.md
```

**Чаще всего скрипты в `github/workflows` это не тоже самое, что скрипты в `scripts`.**

---

## Реальные примеры

## Tokio

https://github.com/tokio-rs/tokio/tree/master/.github/workflows

- огромный CI (~1200 строк)
- сложная матрица
- множество workflow

**Причем в проекте нет локальных скриптов для проверки пайплайна**

---

### gstreamer-rs

- системные зависимости (GStreamer, pkg-config, meson, ninja)
- platform-specific setup
- отдельные CI скрипты
- длинные руководства по установке зависимостей, сильно отличающиеся для разных операционных систем.

https://github.com/snapview/gstreamer-rs/tree/master/ci  
https://github.com/snapview/gstreamer-rs?tab=readme-ov-file#installation

---

## Проблема архитектурно

Есть несколько источников правды:

```
Cargo.toml        → Rust зависимости
rust-toolchain    → версия Rust
CI yaml           → проверки
Dockerfile        → окружение
scripts           → сопровождение
```

**И все это расходится**

---

## Какие есть инструменты

| инструмент | что фиксирует |
|---|---|
| venv | python deps |
| nvm | node version |
| uv | python env + deps |
| rustup | rust toolchain |

Каждый инструмент работает только для конкретного стека

---

## Идея Nix

> Nix — это описание всей среды разработки как декларативного графа

- `venv` → python env
- `nvm`  → node env
- `rustup` → rust env
- `nix` → *вся среда разработки*

---

## Что такое flake

Упрощённо:

```
flake
 ├ inputs
 ├ outputs
      ├ packages
      ├ checks
      ├ devShell
```

---

## Основные элементы

### devShell

Среда разработки

```bash
nix develop
```

Даёт:

- правильный Rust
- инструменты
- системные зависимости

---

### checks

Герметичные CI проверки

```bash
nix flake check
```

Примеры:

```
cargo test
cargo clippy
cargo doc
```

---

### packages

Команды проекта (task runner)

```bash
nix run .#test
nix run .#lint
```

---

## Сравнение с npm scripts

### npm

```json
{
  "scripts": {
    "test": "vitest",
    "lint": "eslint ."
  }
}
```

### nix

```
nix run .#test
nix run .#lint
```

---

## Очень важно: герметичность

> Сборка не зависит от системы

Nix сборка:

- не видит `/usr/bin`
- не использует системные библиотеки
- получает только объявленные зависимости

---

## Sandbox

- сборка происходит в sandbox
- **без доступа к сети**
- с изолированной файловой системой
- для `checks` используется копия репозитория

👉 почти как Docker, но легче

---

## Воспроизводимость

Если есть:

```
flake.nix
flake.lock
```

то:

```
git clone
nix develop
```

даёт **одинаковую среду**

---

## CI с Nix

До:

```
200+ строк YAML
```

После:

```yaml
run: nix flake check
```

*CI превращяется просто в исполнитель готовых скриптов*

---

## direnv

Автоматическая активация среды

`.envrc`:

```bash
use flake
```

Теперь:

```
cd project → env активируется
```

---

# Nix как launcher инструментов

Можно запускать тулзы без установки:

```bash
nix run nixpkgs#jq
nix run nixpkgs#ripgrep
nix run nixpkgs#node
```

👉 аналог:

- npx
- uvx
- docker run

---

## Для агентов / автоматизации

LLM-агенты могут:

```
nix run nixpkgs#tool
```

без установки и без грязи в системе

---

## Итог

Без Nix:

```
cargo
CI yaml
docker
scripts
toolchain
```

С Nix:

```
flake.nix
```

---

## Установка

Рекомендуемый способ:

```bash
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
```

## Практический пример

А теперь перейдем к разбору реального проекта 

https://github.com/alekseysidorov/tower-http-client

который использует 

https://github.com/alekseysidorov/rust-dev-flake
