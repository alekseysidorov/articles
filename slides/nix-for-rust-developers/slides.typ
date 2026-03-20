#let nix-blue = rgb("#5277C3")
#let nix-dark = rgb("#3B5998")
#let sidebar-width = 1.2cm

// Sidebar background for content slides
#let slide-bg = context {
  place(left, rect(width: sidebar-width, height: 100%, fill: nix-blue))
}

// Title slide
#set page(
  paper: "presentation-16-9",
  margin: 0pt,
  fill: nix-blue,
)
#set text(font: "Libertinus Serif", size: 24pt, fill: white)

#align(horizon + center)[
  #v(1fr)
  #text(size: 40pt, weight: "bold")[Nix для Rust-разработчиков]
  #v(0.6em)
  #line(length: 60%, stroke: white.transparentize(40%))
  #v(0.6em)
  #text(size: 22pt)[Алексей Сидоров]
  #v(0.2em)
  #text(size: 18pt, style: "italic")[Ведущий Rust разработчик]
  #v(1fr)
  #text(size: 16pt, fill: white.transparentize(30%))[2025]
]

// Content slides
#set page(
  paper: "presentation-16-9",
  margin: (left: sidebar-width + 1.2cm, right: 1.5cm, top: 1.2cm, bottom: 1cm),
  fill: white,
  background: slide-bg,
)
#set text(font: "Libertinus Serif", size: 20pt, fill: black)

// Slide 1 — Проблема
#pagebreak()

#text(size: 30pt, weight: "bold", fill: nix-blue)[Проблема]
#v(0.4em)
#line(length: 100%, stroke: nix-blue.transparentize(60%))
#v(0.6em)

#text(size: 21pt, style: "italic")[У проекта нет единого описания среды разработки]

#v(0.8em)

#set text(size: 19pt)
- `rustup` — управляет toolchain
- `cargo install` — глобальные инструменты
- `brew` / `apt` — системные зависимости
- CI YAML — своя логика сборки
- `scripts/` — разрозненные скрипты
- `README` — "установи вот это и вот это..."

#v(1fr)
#text(size: 16pt, fill: gray)[Всё это живёт в разных местах и расходится со временем]

// Slide 2 — Что даёт Nix
#pagebreak()

#text(size: 30pt, weight: "bold", fill: nix-blue)[Что даёт Nix]
#v(0.4em)
#line(length: 100%, stroke: nix-blue.transparentize(60%))
#v(0.6em)

#text(size: 21pt, style: "italic")[Один декларативный слой для всей среды разработки]

#v(0.8em)

#set text(size: 19pt)
- `venv` решает окружение Python
- `nvm` / `rustup` решают версию языка
- Nix решает *весь* dev environment: toolchain, системные зависимости, checks, команды проекта

#v(0.8em)
#line(length: 100%, stroke: nix-blue.transparentize(70%))
#v(0.4em)

- *Воспроизводимость* — одинаково работает у всех и в CI
- *Герметичность* — сборка не зависит от того, что установлено в системе
- Nix не требует NixOS

// Slide 3 — Структура flake
#pagebreak()

#text(size: 30pt, weight: "bold", fill: nix-blue)[Структура flake.nix]
#v(0.4em)
#line(length: 100%, stroke: nix-blue.transparentize(60%))
#v(0.6em)

#text(size: 21pt, style: "italic")[Это не страшная магия — просто описание входов и выходов]

#v(0.8em)

#set text(size: 18pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 1.2em,
  [
    *`inputs`* \
    #text(fill: gray, size: 16pt)[Зависимости: nixpkgs, инструменты]

    #v(0.6em)
    *`devShells`* \
    #text(fill: gray, size: 16pt)[`nix develop` — среда разработки]
  ],
  [
    *`checks`* \
    #text(fill: gray, size: 16pt)[`nix flake check` — hermetic CI checks]

    #v(0.6em)
    *`packages`* \
    #text(fill: gray, size: 16pt)[`nix build` / `nix run` — команды проекта]
  ]
)

#v(1fr)
#text(size: 16pt, fill: gray)[CI should be an executor, not the source of truth]

// Slide 4 — UX + live demo
#pagebreak()

#text(size: 30pt, weight: "bold", fill: nix-blue)[UX и переход к демо]
#v(0.4em)
#line(length: 100%, stroke: nix-blue.transparentize(60%))
#v(0.6em)

#set text(size: 19pt)
#grid(
  columns: (1fr, 1fr),
  gutter: 1em,
  [
    *Войти в среду:*
    #v(0.3em)
    `nix develop`

    #v(0.6em)
    *Запустить проверки:*
    #v(0.3em)
    `nix flake check`
  ],
  [
    *Запустить команду:*
    #v(0.3em)
    `nix run .#lint`

    #v(0.6em)
    *Любой инструмент:*
    #v(0.3em)
    `nix run nixpkgs#jq`
  ]
)

#v(0.6em)
#line(length: 100%, stroke: nix-blue.transparentize(70%))
#v(0.4em)

`direnv` делает это автоматически при входе в папку

#v(1fr)
#align(center)[
  #text(size: 28pt, weight: "bold", fill: nix-blue)[→ live demo]
]
