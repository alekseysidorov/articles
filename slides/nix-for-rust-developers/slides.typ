#import "theme/theme.typ": *
#import "theme/components.typ": *

#show: deck

#title-slide(
  title: [Nix для Rust-разработчика],
  subtitle: [Как сделать среду, команды и CI частью проекта],
  author: [Алексей Сидоров · Ведущий Rust-разработчик],
  year: [2025],
)

#big-idea(
  title: [У проекта должен быть один источник правды.],
  kicker-text: [Thesis],
  note: [
    Для Rust-проекта проблема обычно не в `cargo`.
    Проблема в том, что вокруг него быстро вырастает второй проект — окружение.
  ],
)

#explain-slide(
  kicker-text: [Problem],
  title: [Фрагментированная среда],
  lead: [
    Один проект живёт сразу в нескольких местах.
  ],
  points: (
    [`Cargo.toml` знает про crates],
    [`rust-toolchain`, `brew`, `apt`, `scripts/` живут отдельно],
    [CI проверяет не совсем то же самое, что вы запускаете локально],
  ),
  aside: [
    #text(size: 11pt, weight: "medium", fill: accent, upper([Symptoms]))
    #v(0.45em)
    #body-copy[
      onboarding долгий,
      README устаревает,
      локально работает — в CI падает
    ]
  ],
)

#comparison-slide(
  title: [Cargo vs Nix],
  left-title: [Cargo],
  left-body: [
    #text(size: 18pt, weight: "medium")[Сборка Rust-кода]
    #v(0.5em)
    #muted-copy[
      crates, features, workspace, lockfile
    ]
  ],
  right-title: [Nix],
  right-body: [
    #text(size: 18pt, weight: "medium")[Среда и проверки]
    #v(0.5em)
    #muted-copy[
      toolchain, system libs, команды проекта, CI checks
    ]
  ],
  note: [
    `cargo build` описывает сборку.
    `nix` описывает контекст, в котором сборка вообще возможна.
  ],
)

#big-idea(
  kicker-text: [What is a flake],
  title: [Flake — это воспроизводимая точка входа в проект.],
  note: [
    `flake.nix` описывает, что проект экспортирует.
    `flake.lock` фиксирует входы во времени.
  ],
)

#code-slide(
  title: [`nix develop`],
  kicker-text: [Workflow],
  body: [
    #bash-code(
      ```text
$ git clone <repo>
$ nix develop
$ cargo test
      ```.text,
    )
  ],
  note: [
    Для нового разработчика это означает:
    clone → enter shell → work.
  ],
)

#code-slide(
  title: [Минимальный CI],
  kicker-text: [Workflow],
  body: [
    #yaml-code(
      ```text
- uses: cachix/install-nix-action@v27
- run: nix flake check
      ```.text,
    )
  ],
  note: [
    CI перестаёт быть местом, где руками дублируют логику проекта.
  ],
)

#big-idea(
  kicker-text: [Demo],
  title: [Дальше важнее не теория, а live demo.],
  note: [
    Посмотрим на реальный проект:
    `devShell`, `checks`, `apps` и то, как это упрощает локальную разработку.
  ],
)

#final-slide(
  title: [Reproducibility becomes automated.],
  note: [
    Не “у нас где-то в README написано, как это повторить”,
    а “проект уже умеет поднять среду, запустить команды и прогнать проверки”.
  ],
)

// APPENDIX

#big-idea(
  kicker-text: [Appendix],
  title: [Дополнительные материалы],
  note: [
    Эти слайды не обязательны для основного тайминга.
    Их удобно держать после live demo для вопросов и углубления.
  ],
)

#code-slide(
  title: [Что такое flake на практике],
  body: [
    #nix-code(
      ```text
flake.nix
flake.lock

outputs = {
  devShells = ...
  checks    = ...
  packages  = ...
  apps      = ...
}
      ```.text,
    )
  ],
  note: [
    Важная часть — не синтаксис, а то,
    что у проекта появляется единое описание среды.
  ],
)

#explain-slide(
  kicker-text: [devShell],
  title: [`nix develop` как нормальная точка входа],
  lead: [
    Вместо инструкции “поставь вот это всё руками”
    у проекта появляется одна команда для входа в среду.
  ],
  points: (
    [правильный Rust toolchain],
    [`clippy`, `rustfmt`, `taplo`, `typos`],
    [`openssl`, `protobuf`, `pkg-config`, `clang`],
  ),
)

#explain-slide(
  kicker-text: [apps],
  title: [`nix run` как launcher команд],
  lead: [
    Проект может экспортировать стандартные точки входа,
    а не рассчитывать на набор shell-скриптов и устных договорённостей.
  ],
  points: (
    [`nix run .#lint`],
    [`nix run .#test`],
    [`nix run nixpkgs#jq`],
  ),
)

#comparison-slide(
  title: [Without Nix / With Nix],
  left-title: [Without Nix],
  left-body: [
    #text(size: 18pt, weight: "medium")[Среда описана неявно]
    #v(0.55em)
    #muted-copy[
      README, CI YAML, системные пакеты,
      локальные скрипты и знания команды
    ]
  ],
  right-title: [With Nix],
  right-body: [
    #text(size: 18pt, weight: "medium")[Среда описана в проекте]
    #v(0.55em)
    #muted-copy[
      `devShells`, `checks`, `apps`, `packages`
      становятся частью одного описания
    ]
  ],
)

#comparison-slide(
  title: [Почему это особенно полезно в Rust],
  left-title: [Простые проекты],
  left-body: [
    #text(size: 18pt, weight: "medium")[Иногда можно жить и без этого]
    #v(0.55em)
    #muted-copy[
      если зависимостей мало,
      CI простой,
      а окружение почти не отличается по платформам
    ]
  ],
  right-title: [Сложные проекты],
  right-body: [
    #text(size: 18pt, weight: "medium")[Окупаемость растёт быстро]
    #v(0.55em)
    #muted-copy[
      `openssl-sys`, `bindgen`, `protobuf`,
      `rdkafka`, `gstreamer`, macOS vs Linux, сложный CI
    ]
  ],
)

#explain-slide(
  kicker-text: [CI],
  title: [Почему Nix хорошо ложится на CI],
  lead: [
    Если проверки вынесены в `checks`,
    CI можно сильно упростить.
  ],
  points: (
    [CI ставит Nix],
    [CI запускает `nix flake check`],
    [логика проверок остаётся в проекте, а не в YAML],
  ),
)

#code-slide(
  title: [Идея checks],
  body: [
    #nix-code(
      ```text
checks = {
  fmt = ...
  clippy = ...
  test = ...
}
      ```.text,
    )
  ],
  note: [
    Один и тот же набор можно запускать локально и в CI.
  ],
)

#explain-slide(
  kicker-text: [Nix vs NixOS],
  title: [Nix не равен NixOS],
  lead: [
    Для Rust-разработчика это важный практический момент.
  ],
  points: (
    [`Nix` — инструмент для пакетов, сред и сборок],
    [`NixOS` — Linux-дистрибутив, построенный вокруг Nix],
    [использовать `nix develop` и flakes можно и на macOS, и на обычном Linux],
  ),
)

#comparison-slide(
  title: [Nix vs Docker],
  left-title: [Docker],
  left-body: [
    #text(size: 18pt, weight: "medium")[Где это запускать]
    #v(0.55em)
    #muted-copy[
      контейнер, образ, упаковка и запуск приложения
    ]
  ],
  right-title: [Nix],
  right-body: [
    #text(size: 18pt, weight: "medium")[Из чего это собирается]
    #v(0.55em)
    #muted-copy[
      входы, toolchain, системные зависимости,
      воспроизводимая dev/build-среда
    ]
  ],
  note: [
    Это разные слои.
    Они не исключают друг друга.
  ],
)

#code-slide(
  title: [`flake.lock` важен не меньше, чем `Cargo.lock`],
  body: [
    #text-code(
      ```text
Cargo.lock  -> фиксирует crates
flake.lock  -> фиксирует dev/build environment
      ```.text,
    )
  ],
  note: [
    По смыслу это lockfile уровнем выше:
    не только зависимости Rust-кода, а вся рабочая среда.
  ],
)

#explain-slide(
  kicker-text: [Architecture],
  title: [Почему это вообще работает],
  lead: [
    Nix делает зависимости явными
    и привязывает результаты к их входам.
  ],
  points: (
    [артефакты живут в `/nix/store/...`],
    [меньше неявных зависимостей от системы],
    [проще получать одинаковую среду на разных машинах],
  ),
)

#code-slide(
  title: [`direnv` для ежедневной работы],
  body: [
    #bash-code(
      ```text
.envrc

use flake
      ```.text,
    )
  ],
  note: [
    Тогда среда активируется автоматически
    при входе в директорию проекта.
  ],
)

#code-slide(
  title: [Nix как launcher инструментов],
  body: [
    #bash-code(
      ```text
nix run nixpkgs#jq
nix run nixpkgs#ripgrep
nix run nixpkgs#nodejs
      ```.text,
    )
  ],
  note: [
    Удобно и для локальной работы,
    и для автоматизации без глобальной установки инструментов.
  ],
)

#final-slide(
  title: [Если `cargo build` — это только верхушка айсберга, Nix быстро окупается.],
  note: [
    Особенно там, где есть системные зависимости,
    несколько платформ, сложный CI и дорогой onboarding.
  ],
)
