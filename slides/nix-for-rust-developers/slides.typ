#import "theme/theme.typ": *
#import "theme/components.typ": *

#show: deck

#title-slide(
  title: [Nix для Rust-разработчика],
  subtitle: [Воспроизводимое окружение локально и в CI],
  author: [Алексей Сидоров · Ведущий Rust-разработчик],
  year: [2026],
)

#big-idea(
  kicker-text: [Thesis],
  title: [У проекта должен быть один источник правды.],
  note: [
    Проблема обычно уже не в коде.

    Проблема в среде вокруг него.
  ],
)

#explain-slide(
  kicker-text: [Problem],
  title: [Проект живёт сразу в нескольких описаниях],
  lead: [
    `Cargo.toml` — это только часть картины.
  ],
  points: (
    [`Cargo.toml` знает только про crates],
    [toolchain, system deps и scripts живут отдельно],
    [CI часто проверяет не совсем то, что можно запустить локально],
  ),
)

#symptom-slide(
  title: [Что ломается дальше],
  lines: (
    [onboarding дорогой],
    [README устаревает],
    [локально работает — в CI падает],
  ),
)

#compact-comparison-slide(
  title: [Cargo vs Nix],
  left-title: [Cargo],
  left-items: (
    [сборка Rust-кода],
    [crates],
    [features],
    [workspace],
    [lockfile],
  ),
  right-title: [Nix],
  right-items: (
    [среда и проверки],
    [toolchain],
    [system libs],
    [команды проекта],
    [CI checks],
  ),
  note: [
    Cargo описывает сборку.
    Nix описывает среду, в которой эта сборка вообще возможна.
  ],
)

#compact-comparison-slide(
  title: [Flake],
  kicker-text: [Definition],
  left-title: [Файлы],
  left-items: (
    [`flake.nix`],
    [`flake.lock`],
  ),
  right-title: [Смысл],
  right-items: (
    [описание проекта],
    [фиксация входов],
    [воспроизводимая точка входа],
  ),
  note: [Не “собери что-нибудь похожее”, а “подними среду из зафиксированных входов”.],
)

#code-slide(
  title: [`nix develop`],
  kicker-text: [Workflow],
  body: [
    #bash-code(
      ```text
      git clone <repo>
      cd <repo>
      nix develop
      cargo test
      ```.text,
    )
  ],
  note: [
    clone → `nix develop` → работаешь
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
    CI перестаёт быть вторым местом, где руками описана логика проекта.
  ],
)

#demo-slide(
  title: [Дальше важнее не теория, а demo.],
  note: [
    Посмотрим на реальный проект.
  ],
  steps: (),
)

#appendix-divider(
  title: [Appendix],
  note: [Спокойный разбор после demo.],
)

#code-slide(
  title: [Что такое flake на практике],
  kicker-text: [Appendix],
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
    Одно описание среды и точек входа.
  ],
)

#compact-comparison-slide(
  title: [`nix develop` как точка входа],
  kicker-text: [devShell],
  left-title: [Что даёт],
  left-items: (
    [Rust toolchain],
    [clippy, rustfmt, taplo, typos],
    [openssl, protobuf, pkg-config, clang],
  ),
  right-title: [Что меняется],
  right-items: (
    [одна команда входа],
    [меньше ручной настройки],
    [одинаковая среда локально и в CI],
  ),
  note: [Вместо README с длинной инструкцией появляется нормальная точка входа.],
)

#code-slide(
  title: [`nix run` как launcher команд],
  kicker-text: [Commands],
  body: [
    #bash-code(
      ```text
      nix run .#lint
      nix run .#test
      nix run nixpkgs#jq
      ```.text,
    )
  ],
  note: [
    Проект экспортирует явные команды, а не shell-скрипты по углам.
  ],
)

#compact-comparison-slide(
  title: [Without Nix / With Nix],
  left-title: [Without Nix],
  left-items: (
    [README],
    [CI YAML],
    [системные пакеты],
    [локальные скрипты],
    [знания команды],
  ),
  right-title: [With Nix],
  right-items: (
    [devShells],
    [checks],
    [apps],
    [packages],
    [одно описание],
  ),
  note: [Главная разница — количество мест, где живёт истина о проекте.],
)

#compact-comparison-slide(
  title: [Где Nix окупается быстрее всего],
  left-title: [Простые проекты],
  left-items: (
    [мало зависимостей],
    [простой CI],
    [одна платформа],
  ),
  right-title: [Сложные проекты],
  right-items: (
    [openssl-sys],
    [bindgen],
    [protobuf],
    [rdkafka],
    [gstreamer],
    [macOS + Linux],
  ),
  note: [Чем больше native deps и платформ, тем быстрее это начинает окупаться.],
)

#explain-slide(
  kicker-text: [CI],
  title: [CI — исполнитель, а не источник правды],
  lead: [
    CI не описывает проект.

    Он его исполняет.
  ],
  points: (
    [CI ставит Nix],
    [CI запускает checks],
    [логика остаётся в проекте],
  ),
)

#code-slide(
  title: [checks = один и тот же набор локально и в CI],
  kicker-text: [Checks],
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
    Не второй список проверок в YAML.

    Те же самые проверки.
  ],
)

#compact-comparison-slide(
  title: [Nix ≠ NixOS],
  kicker-text: [FAQ],
  left-title: [Nix],
  left-items: (
    [инструмент],
    [пакеты и сборки],
    [dev/build environment],
  ),
  right-title: [NixOS],
  right-items: (
    [дистрибутив],
    [Linux вокруг Nix],
    [не обязателен для flakes],
  ),
  note: [`nix develop` и flakes работают и на macOS, и на обычном Linux.],
)

#comparison-slide(
  title: [Nix vs Docker],
  left-title: [Docker],
  left-body: [
    #text(size: 18pt, weight: "medium")[Где это запускать]
    #v(0.55em)
    #muted-copy[
      контейнер
      #linebreak()
      образ
      #linebreak()
      упаковка приложения
    ]
  ],
  right-title: [Nix],
  right-body: [
    #text(size: 18pt, weight: "medium")[Из чего это собирать]
    #v(0.55em)
    #muted-copy[
      входы
      #linebreak()
      toolchain
      #linebreak()
      системные зависимости
      #linebreak()
      dev/build environment
    ]
  ],
  note: [
    Это разные слои.

    Они не обязаны конкурировать.
  ],
)

#compact-comparison-slide(
  title: [`flake.lock` важен не меньше, чем `Cargo.lock`],
  kicker-text: [Lockfile],
  left-title: [Cargo.lock],
  left-items: (
    [crates],
    [Rust dependency graph],
  ),
  right-title: [flake.lock],
  right-items: (
    [dev/build environment],
    [зафиксированные входы проекта],
  ),
  note: [Это lockfile уровнем выше.],
)

#explain-slide(
  kicker-text: [Architecture],
  title: [Почему это воспроизводимо],
  lead: [
    Воспроизводимость здесь не на словах.

    Она следует из модели сборки.
  ],
  points: (
    [зависимости описаны явно],
    [артефакты живут в `/nix/store/...`],
    [сборка идёт в sandbox],
    [без доступа к сети],
  ),
  aside: [
    #text(size: 11pt, weight: "medium", fill: accent, upper([Build model]))
    #v(0.45em)
    #body-copy[
      checks строятся на копии репозитория

      по эффекту это похоже на лёгкий Docker для сборки
    ]
  ],
)

#code-slide(
  title: [`direnv`],
  kicker-text: [Daily use],
  body: [
    #bash-code(
      ```text
      # .envrc
      use flake
      ```.text,
    )
  ],
  note: [
    `cd` в проект → среда активировалась
  ],
)

#code-slide(
  title: [Nix как universal launcher],
  kicker-text: [Tooling],
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
    Локально, в CI и в автоматизации — без глобальной установки.
  ],
)

#final-slide(
  title: [Если вокруг `cargo build` уже вырос отдельный мир, Nix быстро окупается.],
  note: [
    Особенно когда есть native deps, несколько платформ и сложный CI.
  ],
)
