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

#hero-slide(
  kicker: [Thesis],
  title: [У проекта должен быть один источник правды.],
  note: [
    Проблема обычно уже не в коде.
    Проблема в среде вокруг этого кода.
  ],
)

#content-slide(
  kicker: [Problem],
  title: [Проект живёт сразу в нескольких описаниях],
  lead: [
    `Cargo.toml` — это только часть картины. Остальное быстро расходится.
  ],
  items: (
    [`Cargo.toml` знает только про crates],
    [toolchain, system deps и scripts живут отдельно],
    [CI часто проверяет не то же самое, что запускаете локально],
  ),
)

#content-slide(
  kicker: [Symptoms],
  title: [Типичные симптомы],
  items: (
    [onboarding дорогой],
    [README устаревает],
    [локально работает — в CI падает],
  ),
)

#comparison-slide(
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
    Nix — описывает среду, в которой эта сборка вообще возможна.
  ],
)

#content-slide(
  kicker: [Definition],
  title: [Что такое Nix],
  lead: [
    Nix — это среда разработки как код.
  ],
  items: (
    [dev/build environment описывается явно, а не собирается руками],
    [не только crates, но и toolchain, system deps, tools, команды и checks],
    [одно и то же описание работает локально, в CI и на новой машине],
  ),
)

#comparison-slide(
  title: [Воспроизводимая среда],
  kicker: [Definition],
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
    Nix описывает среду проекта.
    Flake делает это описание стандартным и воспроизводимым.
  ],
)

#code-slide(
  title: [Структура flake],
  kicker: [Definition],
  note: [Одно описание среды и точек входа проекта.],
  body: [
    #nix-code(
      ```text
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

#comparison-slide(
  title: [`nix develop` — точка входа],
  kicker: [devShell],
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
  note: [Одна нормальная точка входа вместо длинного README.],
)

#code-slide(
  title: [`nix develop`],
  kicker: [Workflow],
  note: [
    `nix develop` поднимает dev-среду проекта.
    После этого вы работаете обычными командами.
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
  title: [`direnv` для ежедневной работы],
  kicker: [Daily use],
  note: [
    Автоматический вход в ту же среду без ручного `nix develop`.
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

#content-slide(
  kicker: [CI],
  title: [CI — исполнитель, а не источник правды],
  lead: [
    CI не описывает проект.
    Он его исполняет.
  ],
  items: (
    [CI ставит Nix],
    [CI запускает `nix flake check`],
    [CI запускает скрипты из `nix develop`],
    [логика остаётся в проекте, а не в YAML],
  ),
)

#code-slide(
  title: [checks — один набор локально и в CI],
  kicker: [Checks],
  note: [Те же проверки локально и в CI.],
  body: [
    #nix-code(
      ```text
      checks = {
        fmt     = ...
        clippy  = ...
        test    = ...
      }
      ```.text,
    )
  ],
)

#code-slide(
  title: [Минимальный CI],
  kicker: [Workflow],
  note: [
    CI перестаёт быть вторым местом,
    где руками живёт логика проекта.
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

#code-slide(
  title: [`nix run` как launcher для команд],
  kicker: [Commands],
  note: [
    Проект экспортирует явные команды,
    а не shell-скрипты.
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

#comparison-slide(
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
    Главная разница — сколько мест
    хранит правду о проекте.
  ],
)

#hero-slide(
  kicker: [Live demo],
  title: [Дальше важнее не теория, а demo.],
  note: [
    Посмотрим на реальный проект.
  ],
)

#hero-slide(
  kicker: [Final],
  title: [Если вокруг `cargo` уже отдельный мир, Nix быстро окупается.],
  note: [native deps, несколько платформ, сложный CI, кросс-компиляция],
)

// ═══════════════════════════════════════════════════════════════════════════════
// APPENDIX — дополнительные материалы для вопросов и углубления
// ═══════════════════════════════════════════════════════════════════════════════

#hero-slide(
  kicker: [Appendix],
  title: [Appendix],
  note: [Дополнительные материалы.],
)

#comparison-slide(
  title: [Где Nix окупается быстрее всего],
  kicker: [Trade-offs],
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
    тем быстрее окупается Nix.
  ],
)

#comparison-slide(
  title: [Nix ≠ NixOS],
  kicker: [FAQ],
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

#comparison-slide(
  title: [Nix vs Docker],
  kicker: [FAQ],
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

#comparison-slide(
  title: [`flake.lock` важен не меньше, чем `Cargo.lock`],
  kicker: [Lockfile],
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

#content-slide(
  kicker: [Architecture],
  title: [Почему это воспроизводимо],
  lead: [
    Воспроизводимость следует из модели сборки.
  ],
  items: (
    [зависимости описаны явно],
    [артефакты живут в `/nix/store/...`],
    [сборка идёт в sandbox, без сети],
    [checks запускаются на копии репозитория],
  ),
)

#content-slide(
  kicker: [Build model],
  title: [Что это значит на практике],
  lead: [
    Сборка видит только явно описанные входы.
  ],
  items: (
    [меньше скрытых зависимостей от машины разработчика],
    [результат меньше зависит от случайного состояния системы],
    [локальная сборка и CI работают по одной модели],
    [по эффекту это похоже на лёгкий Docker для сборки],
  ),
)



#code-slide(
  title: [Nix как universal launcher],
  kicker: [Tooling],
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

#hero-slide(
  kicker: [Final],
  title: [Спасибо за внимание],
  items: (
    [Telegram — \@sauron1987],
    [GitHub — github.com/alekseysidorov],
  ),
)
