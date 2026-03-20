// ─── Официальная палитра NixOS (из branding guide, OKLCH) ───────────────────
#let nix-dark-blue  = oklch(55%, 0.12, 264deg)  // "Afghani Blue"  — тёмный синий логотипа
#let nix-light-blue = oklch(75%, 0.09, 240deg)  // "Argentinian Blue" — светлый синий логотипа
#let nix-white      = white
#let nix-black      = black

// ─── Ширина сайдбара для контентных слайдов ─────────────────────────────────
#let sidebar-w = 1.4cm

// ─── Фон контентного слайда: тёмно-синяя полоса слева ───────────────────────
#let content-bg = context {
  place(
    top + left,
    rect(width: sidebar-w, height: 100%, fill: nix-dark-blue)
  )
}

// ─── Базовый текст ───────────────────────────────────────────────────────────
// Route 159 — официальный шрифт NixOS (есть в nixpkgs как часть пакета route159)
// Если шрифт не найден, Typst молча упадёт на fallback
#let body-font  = "Route 159"
#let label-font = "Jura"          // вспомогательный шрифт из branding guide

// ─── Вспомогательные функции ─────────────────────────────────────────────────

// Заголовок слайда
#let slide-title(content) = {
  text(
    font: label-font,
    size: 28pt,
    weight: "bold",
    fill: nix-dark-blue,
    upper(content)
  )
  v(0.3em)
  line(length: 100%, stroke: nix-light-blue + 1.5pt)
  v(0.5em)
}

// Разделительная линия между блоками
#let divider() = {
  v(0.5em)
  line(length: 100%, stroke: (paint: nix-light-blue, thickness: 0.5pt, dash: "dashed"))
  v(0.5em)
}

// Метка-таг в стиле NixOS (для punchline'ов и терминов)
#let tag(content) = {
  box(
    fill: nix-dark-blue,
    inset: (x: 6pt, y: 3pt),
    radius: 2pt,
    text(font: label-font, size: 10pt, fill: white, weight: "bold", content)
  )
}

// ═══════════════════════════════════════════════════════════════════════════════
// СЛАЙД 0 — ЗАГЛАВНЫЙ (полностью тёмно-синий)
// ═══════════════════════════════════════════════════════════════════════════════
#set page(
  paper: "presentation-16-9",
  margin: 0pt,
  fill: nix-dark-blue,
  background: none,
)
#set text(font: body-font, size: 20pt, fill: nix-white)

#v(1fr)
#align(center)[
  // Светло-синяя декоративная линия сверху
  #line(length: 55%, stroke: nix-light-blue + 1.5pt)
  #v(0.8em)

  // Основной заголовок
  #text(
    font: label-font,
    size: 38pt,
    weight: "bold",
    fill: nix-white,
  )[Nix для Rust-разработчиков]

  #v(0.6em)

  // Подзаголовок
  #text(
    size: 18pt,
    fill: nix-light-blue,
  )[Как один декларативный слой меняет dev experience]

  #v(1.2em)
  #line(length: 55%, stroke: (paint: nix-white, thickness: 0.5pt, dash: "dashed"))
  #v(1.2em)

  // Докладчик
  #text(font: label-font, size: 20pt, fill: nix-white, weight: "bold")[
    Алексей Сидоров
  ]
  #v(0.3em)
  #text(size: 15pt, fill: nix-light-blue)[
    Ведущий Rust разработчик
  ]

  #v(1.2em)
  #line(length: 55%, stroke: nix-light-blue + 1.5pt)
]
#v(1fr)
#align(right)[
  #pad(right: 1.5cm, bottom: 0.6cm)[
    #text(font: label-font, size: 12pt, fill: nix-light-blue)[2025]
  ]
]


// ═══════════════════════════════════════════════════════════════════════════════
// КОНТЕНТНЫЕ СЛАЙДЫ — переключаем set page
// ═══════════════════════════════════════════════════════════════════════════════
#set page(
  paper: "presentation-16-9",
  margin: (
    left:   sidebar-w + 1.4cm,
    right:  1.6cm,
    top:    1.2cm,
    bottom: 0.9cm,
  ),
  fill: nix-white,
  background: content-bg,
)
#set text(font: body-font, size: 18pt, fill: nix-black)
#set list(marker: text(fill: nix-dark-blue)[▸])


// ═══════════════════════════════════════════════════════════════════════════════
// СЛАЙД 1 — ПРОБЛЕМА
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()

#slide-title[Проблема]

#text(size: 19pt, style: "italic", fill: nix-dark-blue)[
  У проекта нет единого описания среды разработки
]

#v(0.7em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1.2em,
  [
    #text(weight: "bold")[Каждый делает по-своему:]
    #v(0.4em)
    - `rustup` — управляет тулчейном
    - `cargo install` — глобальные инструменты
    - `brew` / `apt` — системные зависимости
  ],
  [
    #text(weight: "bold")[И ещё:]
    #v(0.4em)
    - CI YAML — своя логика сборки
    - `scripts/` — разрозненные скрипты
    - `README` — «установи вот это и вот то»
  ],
)

#v(1fr)
#align(right)[
  #text(
    font: label-font,
    size: 13pt,
    fill: nix-light-blue,
    style: "italic",
  )[Всё это расходится со временем]
]


// ═══════════════════════════════════════════════════════════════════════════════
// СЛАЙД 2 — ЧТО ДАЁТ NIX
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()

#slide-title[Что даёт Nix]

#text(size: 19pt, style: "italic", fill: nix-dark-blue)[
  Один декларативный слой для всей среды разработки
]

#v(0.7em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1.4em,
  [
    #text(weight: "bold")[Аналогия:]
    #v(0.4em)
    - `venv` решает окружение Python
    - `nvm` / `rustup` — версию языка
    - *Nix решает весь dev environment*

    #v(0.5em)
    Toolchain, системные зависимости, checks, команды проекта
  ],
  [
    #text(weight: "bold")[Ключевые свойства:]
    #v(0.4em)
    - *Воспроизводимость* — одинаково у всех и в CI
    - *Герметичность* — сборка не зависит от системы
    - Работает без NixOS
    - Работает на macOS и Linux
  ],
)

#v(1fr)
#align(right)[
  #tag[Nix не требует NixOS]
]


// ═══════════════════════════════════════════════════════════════════════════════
// СЛАЙД 3 — СТРУКТУРА FLAKE
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()

#slide-title[Структура flake.nix]

#text(size: 19pt, style: "italic", fill: nix-dark-blue)[
  Это не страшная магия — просто описание входов и выходов
]

#v(0.7em)

#grid(
  columns: (1fr, 1fr),
  gutter: 1.6em,
  [
    #text(font: label-font, size: 17pt, weight: "bold", fill: nix-dark-blue)[`inputs`]
    #text(size: 15pt, fill: rgb("#555"))[Зависимости: nixpkgs, инструменты]

    #v(0.8em)

    #text(font: label-font, size: 17pt, weight: "bold", fill: nix-dark-blue)[`devShells`]
    #text(size: 15pt, fill: rgb("#555"))[`nix develop` — среда разработки]
  ],
  [
    #text(font: label-font, size: 17pt, weight: "bold", fill: nix-dark-blue)[`checks`]
    #text(size: 15pt, fill: rgb("#555"))[`nix flake check` — hermetic CI checks]

    #v(0.8em)

    #text(font: label-font, size: 17pt, weight: "bold", fill: nix-dark-blue)[`packages`]
    #text(size: 15pt, fill: rgb("#555"))[`nix build` / `nix run` — команды проекта]
  ],
)

#divider()

#align(center)[
  #text(size: 15pt, fill: rgb("#444"))[
    CI should be an *executor*, not the source of truth
  ]
]


// ═══════════════════════════════════════════════════════════════════════════════
// СЛАЙД 4 — UX + LIVE DEMO
// ═══════════════════════════════════════════════════════════════════════════════
#pagebreak()

#slide-title[UX и переход к демо]

#grid(
  columns: (1fr, 1fr),
  gutter: 1.4em,
  [
    #text(weight: "bold")[Войти в среду:]
    #v(0.2em)
    #text(font: label-font, fill: nix-dark-blue)[`nix develop`]

    #v(0.6em)
    #text(weight: "bold")[Запустить проверки:]
    #v(0.2em)
    #text(font: label-font, fill: nix-dark-blue)[`nix flake check`]
  ],
  [
    #text(weight: "bold")[Запустить команду проекта:]
    #v(0.2em)
    #text(font: label-font, fill: nix-dark-blue)[`nix run .#lint`]

    #v(0.6em)
    #text(weight: "bold")[Любой инструмент без установки:]
    #v(0.2em)
    #text(font: label-font, fill: nix-dark-blue)[`nix run nixpkgs#jq`]
  ],
)

#divider()

#text(size: 17pt)[
  #tag[direnv] автоматически активирует среду при входе в папку
]

#v(1fr)
#align(center)[
  #text(
    font: label-font,
    size: 34pt,
    weight: "bold",
    fill: nix-dark-blue,
  )[→ live demo]
]
