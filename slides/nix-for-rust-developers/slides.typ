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
    На словах всё просто: `cargo build`.
    Но в реальности основная сложность часто не в коде, а в окружении вокруг него.
  ],
)

#explain-slide(
  kicker-text: [Problem],
  title: [Фрагментированная среда],
  lead: [
    На самом деле один проект начинает жить сразу в нескольких описаниях.
  ],
  points: (
    [`Cargo.toml` знает только про crates],
    [`rust-toolchain`, `brew`, `apt`, `scripts/` живут отдельно],
    [в реальности CI проверяет не совсем то же самое, что вы запускаете локально],
  ),
  aside: [
    #text(size: 11pt, weight: "medium", fill: accent, upper([Symptoms]))
    #v(0.45em)
    #body-copy[
      onboarding дорогой,
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
    Тут важно понять разницу.
    `cargo` описывает сборку, а `nix` — среду, в которой эта сборка вообще возможна.
  ],
)

#big-idea(
  kicker-text: [What is a flake],
  title: [Flake — это воспроизводимая точка входа в проект.],
  note: [
    Если упростить, это стандартная точка входа в Nix-проект.
    `flake.nix` описывает проект, а `flake.lock` фиксирует входы.
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
    На практике это означает простой сценарий:
    clone → `nix develop` → работаешь.
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
    Ключевая идея простая:
    CI перестаёт быть вторым местом, где руками описана логика проекта.
  ],
)

#big-idea(
  kicker-text: [Demo],
  title: [Дальше важнее не теория, а live demo.],
  note: [
    Посмотрим на реальный проект.
    Как устроены `devShell`, `checks` и `apps`, и что это меняет на практике.
  ],
)

#final-slide(
  title: [Воспроизводимость становится частью проекта.],
  note: [
    Не “где-то в README написано, как это повторить”.
    А среда, команды и проверки уже описаны и реально исполняются.
  ],
)

// APPENDIX

#big-idea(
  kicker-text: [Appendix],
  title: [Дополнительные материалы],
  note: [
    Это запасные слайды.
    Их имеет смысл держать после demo для вопросов и спокойного разбора.
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
    Тут важно не само слово `flake`.
    Важно, что у проекта появляется одно описание среды и точек входа.
  ],
)

#explain-slide(
  kicker-text: [devShell],
  title: [`nix develop` как нормальная точка входа],
  lead: [
    Вместо инструкции “поставь вот это всё руками”
    появляется одна нормальная команда входа в среду.
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
    Если посмотреть практично, проект начинает экспортировать явные команды.
    Не shell-скрипты по углам репозитория, а нормальные точки входа.
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
    дальше CI фактически становится просто исполнителем.
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
    Отсюда следует простая вещь:
    один и тот же набор проверок можно запускать и локально, и в CI.
  ],
)

#explain-slide(
  kicker-text: [Nix vs NixOS],
  title: [Nix не равен NixOS],
  lead: [
    Тут важно не путать инструмент и дистрибутив.
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
    Тут речь про разные слои.
    Docker и Nix не конкуренты по умолчанию и вполне могут жить вместе.
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
    Если упростить, это lockfile уровнем выше.
    Не только для Rust-зависимостей, а для рабочей среды целиком.
  ],
)

#explain-slide(
  kicker-text: [Architecture],
  title: [Почему это вообще работает],
  lead: [
    Ключевая идея в том, что зависимости описываются явно.
    А результат привязывается к своим входам.
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
    На практике это просто удобнее.
    Заходишь в директорию — среда поднимается автоматически.
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
    Это удобно и локально, и в автоматизации.
    Особенно когда не хочется ставить инструменты глобально.
  ],
)

#final-slide(
  title: [Если вокруг `cargo build` уже вырос отдельный мир, Nix обычно быстро окупается.],
  note: [
    Особенно если есть системные зависимости,
    несколько платформ, сложный CI и дорогой onboarding.
  ],
)
