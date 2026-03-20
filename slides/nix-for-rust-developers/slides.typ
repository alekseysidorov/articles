#import "theme/theme.typ": *
#import "theme/components.typ": *

#show: deck

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN DECK — короткий доклад, быстрый выход в live demo
// ═══════════════════════════════════════════════════════════════════════════════

#title-slide(
  title: [Nix для Rust-разработчика],
  subtitle: [Воспроизводимое окружение, проверки и команды — как часть проекта],
  author: [Алексей Сидоров · Ведущий Rust-разработчик],
  year: [2026],
)

#big-idea(
  kicker-text: [Thesis],
  title: [У проекта должен быть один источник правды.],
  note: [
    Проблема обычно уже не в коде.
    Проблема в окружении вокруг него.
  ],
)

#explain-slide(
  kicker-text: [Problem],
  title: [Проект живёт сразу в нескольких описаниях],
  lead: [
    `Cargo.toml` — это только часть картины.
    Всё остальное быстро расходится.
  ],
  points: (
    [`Cargo.toml` знает только про crates],
    [toolchain, system deps и scripts живут отдельно],
    [CI часто проверяет не совсем то, что можно запустить локально],
  ),
)

#symptom-slide(
  title: [Типичные симптомы],
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
    [crates, features],
    [workspace],
    [lockfile],
  ),
  right-title: [Nix],
  right-items: (
    [среда и проверки],
    [toolchain, system libs],
    [команды проекта],
    [CI checks],
  ),
  note: [
    Cargo описывает сборку.
    Nix описывает среду, в которой эта сборка вообще возможна.
  ],
)

#compact-comparison-slide(
  title: [Что такое flake],
  kicker-text: [Definition],
  left-title: [Файлы],
  left-items: (
    [`flake.nix` — описание проекта],
    [`flake.lock` — фиксация входов],
  ),
  right-title: [Выходы],
  right-items: (
    [`devShells` — среда разработки],
    [`checks` — проверки],
    [`packages` / `apps` — артефакты],
  ),
  note: [
    Не "собери что-нибудь похожее",
    а "подними среду из зафиксированных входов".
  ],
)

#code-slide(
  title: [`nix develop`],
  kicker-text: [Workflow],
  note: [
    clone → `nix develop` → работаешь
  ],
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
)

#code-slide(
  title: [Минимальный CI],
  kicker-text: [Workflow],
  note: [
    CI перестаёт быть вторым местом,
    где руками описана логика проекта.
  ],
  body: [
    #yaml-code(
      ```text
      - uses: cachix/install-nix-action@v27
      - run: nix flake check
      ```.text,
    )
  ],
)

#demo-slide(
  title: [Дальше важнее не теория, а demo.],
  note: [
    Посмотрим на реальный проект.
  ],
  steps: (
    [как устроен `devShell`],
    [как устроены `checks`],
    [как проект экспортирует команды],
  ),
)

#final-slide(
  title: [Воспроизводимость становится частью проекта.],
  note: [
    Среда, команды и проверки уже описаны и реально исполняются.
  ],
)

// ═══════════════════════════════════════════════════════════════════════════════
// APPENDIX — дополнительные материалы для вопросов и углубления
// ═══════════════════════════════════════════════════════════════════════════════

#appendix-divider()

#code-slide(
  title: [Структура flake на практике],
  kicker-text: [Appendix],
  note: [
    Одно описание среды и всех точек входа.
  ],
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
)

#compact-comparison-slide(
  title: [`nix develop` — нормальная точка входа],
  kicker-text: [devShell],
  left-title: [Что внутри],
  left-items: (
    [Rust toolchain],
    [clippy, rustfmt, taplo, typos],
    [openssl, protobuf, pkg-config],
  ),
  right-title: [Что это меняет],
  right-items: (
    [одна команда для входа],
    [меньше ручной настройки],
    [одинаковая среда у всех],
  ),
  note: [
    Вместо README с длинной инструкцией
    появляется одна нормальная точка входа.
  ],
)

#code-slide(
  title: [`nix run` как launcher команд],
  kicker-text: [Commands],
  note: [
    Проект экспортирует явные команды,
    а не shell-скрипты по углам репозитория.
  ],
  body: [
    #bash-code(
      ```text
      nix run .#lint
      nix run .#test
      nix run nixpkgs#jq
      ```.text,
    )
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
    [знания в головах],
  ),
  right-title: [With Nix],
  right-items: (
    [devShells],
    [checks],
    [apps],
    [packages],
    [одно описание],
  ),
  note: [
    Главная разница — количество мест,
    где живёт правда о проекте.
  ],
)

#compact-comparison-slide(
  title: [Где Nix окупается быстрее всего],
  kicker-text: [Trade-offs],
  left-title: [Простые проекты],
  left-items: (
    [мало зависимостей],
    [простой CI],
    [одна платформа],
  ),
  right-title: [Сложные проекты],
  right-items: (
    [openssl-sys, bindgen],
    [protobuf, rdkafka],
    [gstreamer],
    [macOS + Linux],
    [сложный CI],
  ),
  note: [
    Чем больше native deps и платформ,
    тем быстрее Nix начинает окупаться.
  ],
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
    [CI запускает `nix flake check`],
    [логика проверок остаётся в проекте, а не в YAML],
  ),
)

#code-slide(
  title: [checks = один и тот же набор локально и в CI],
  kicker-text: [Checks],
  note: [
    Не второй список проверок в YAML.
    Те же самые проверки.
  ],
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
)

#compact-comparison-slide(
  title: [Nix ≠ NixOS],
  kicker-text: [FAQ],
  left-title: [Nix],
  left-items: (
    [инструмент],
    [пакеты, среды, сборки],
    [dev/build environment],
  ),
  right-title: [NixOS],
  right-items: (
    [дистрибутив],
    [Linux вокруг Nix],
    [не обязателен для flakes],
  ),
  note: [
    `nix develop` и flakes работают
    и на macOS, и на обычном Linux.
  ],
)

#compact-comparison-slide(
  title: [Nix vs Docker],
  kicker-text: [FAQ],
  left-title: [Docker],
  left-items: (
    [где это запускать],
    [контейнер, образ],
    [упаковка приложения],
  ),
  right-title: [Nix],
  right-items: (
    [из чего это собирать],
    [входы, toolchain],
    [dev/build environment],
  ),
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
    [фиксирует crates],
    [Rust dependency graph],
  ),
  right-title: [flake.lock],
  right-items: (
    [фиксирует dev/build environment],
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
    [сборка идёт в sandbox, без доступа к сети],
    [checks строятся на копии репозитория],
  ),
  aside: [
    #text(size: 10pt, weight: "bold", fill: accent, tracking: 0.06em, upper(
      [Build model],
    ))
    #v(0.4em)
    #body-copy[
      По эффекту это похоже на лёгкий Docker для сборки
    ]
  ],
)

#code-slide(
  title: [`direnv` для ежедневной работы],
  kicker-text: [Daily use],
  note: [
    `cd` в проект → среда поднялась автоматически.
  ],
  body: [
    #bash-code(
      ```text
      # .envrc
      use flake
      ```.text,
    )
  ],
)

#code-slide(
  title: [Nix как universal launcher],
  kicker-text: [Tooling],
  note: [
    Локально, в CI и в автоматизации —
    без глобальной установки.
  ],
  body: [
    #bash-code(
      ```text
      nix run nixpkgs#jq
      nix run nixpkgs#ripgrep
      nix run nixpkgs#nodejs
      ```.text,
    )
  ],
)

#final-slide(
  title: [Если вокруг `cargo build` уже вырос отдельный мир, Nix быстро окупается.],
  note: [
    Особенно когда есть native deps,
    несколько платформ и сложный CI.
  ],
)
