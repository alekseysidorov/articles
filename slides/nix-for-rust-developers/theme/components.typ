#import "theme.typ": *

// ─── Raw code helpers (safe from Typst parsing) ─────────────────────────────
#let raw-code(text, lang: none) = raw(text, block: true, lang: lang)
#let text-code(text) = raw-code(text, lang: "text")
#let bash-code(text) = raw-code(text, lang: "bash")
#let yaml-code(text) = raw-code(text, lang: "yaml")
#let nix-code(text) = raw-code(text, lang: "nix")

// ─── Typography primitives ──────────────────────────────────────────────────
#let body-copy(body) = text(size: body-small-size, fill: text-main, body)
#let muted-copy(body) = text(size: body-small-size, fill: text-muted, body)
#let note-copy(body) = text(size: 14pt, fill: text-muted, body)

#let section-kicker(body) = kicker(body)
#let section-title(body) = title(body)
#let hero-title(body) = hero(body)

#let inline-code(
  body,
  fill: text-main,
  size: body-small-size,
  weight: "regular",
) = text(
  font: font-mono,
  size: size,
  fill: fill,
  weight: weight,
  body,
)

#let command(body, accent-line: false) = inline-code(
  body,
  fill: if accent-line { accent } else { text-main },
  size: code-size,
)

// ─── Panel primitives ───────────────────────────────────────────────────────
#let soft-panel(
  body,
  width: 100%,
  inset: panel-inset,
  radius: panel-radius,
) = block(
  width: width,
  fill: surface,
  stroke: border + 0.7pt,
  radius: radius,
  inset: inset,
  body,
)

#let accent-panel(
  body,
  width: 100%,
  inset: panel-inset,
  radius: panel-radius,
) = block(
  width: width,
  fill: accent-soft,
  radius: radius,
  inset: inset,
  body,
)

#let code-block(body, width: 100%) = block(
  width: width,
  fill: surface,
  stroke: border + 0.7pt,
  radius: panel-radius,
  inset: (x: 22pt, y: 18pt),
  [
    #show raw: set text(font: font-mono, size: code-size, fill: text-main)
    #body
  ],
)

#let compare-card(label, body) = soft-panel(width: 100%, [
  #text(
    size: 10pt,
    weight: "bold",
    fill: text-muted,
    tracking: 0.06em,
    upper(label),
  )
  #v(0.65em)
  #body
])

#let two-cols(left, right, gutter: 1.0cm) = grid(
  columns: (1fr, 1fr),
  gutter: gutter,
  left, right,
)

// ─── Page-level helpers ─────────────────────────────────────────────────────
#let slide(body) = [
  #pagebreak()
  #body
]

// ═════════════════════════════════════════════════════════════════════════════
// TITLE SLIDE — no sidebar, full-bleed, golden-ratio vertical position
// ═════════════════════════════════════════════════════════════════════════════
#let title-slide(
  title: [],
  subtitle: [],
  author: [],
  year: [2026],
) = {
  set page(
    paper: "presentation-16-9",
    margin: title-page-margins,
    fill: bg,
    background: none,
    footer: page-number,
  )

  [
    // Large logo in the top-right corner
    #place(top + right, dx: 0.5cm, dy: -0.3cm)[
      #logo-mark(size: 3.5cm)
    ]

    // Golden-ratio positioning: title block
    #v(1fr)
    #v(0.5fr)

    #block(width: 78%)[
      #section-kicker[Nix × Rust]
      #v(0.6em)
      #text(size: 48pt, weight: "bold", fill: text-main)[#title]
      #v(0.35em)
      #text(size: 22pt, fill: text-muted, weight: "regular")[#subtitle]
    ]

    #v(1fr)

    // Author line anchored to the bottom — cannot overflow
    #block(width: 78%)[
      #rule(length: 50%)
      #v(0.35em)
      #text(size: 15pt, fill: text-main)[#author]
      #h(1.0em)
      #text(size: 13pt, fill: text-muted)[#year]
    ]
  ]
}

// ═════════════════════════════════════════════════════════════════════════════
// BIG IDEA — one strong statement, centred both axes
// ═════════════════════════════════════════════════════════════════════════════
#let big-idea(
  title: [],
  kicker-text: [Big idea],
  note: none,
  width: 80%,
) = slide[
  #v(1fr)
  #align(center)[
    #block(width: width)[
      #set align(center)
      #section-kicker[#kicker-text]
      #v(0.6em)
      #hero-title[#title]
      #if note != none [
        #v(0.85em)
        #text(size: subtitle-size, fill: text-muted)[#note]
      ]
    ]
  ]
  #v(1fr)
]

// ═════════════════════════════════════════════════════════════════════════════
// EXPLAIN SLIDE — kicker + title + lead + bullet points + optional aside
// ═════════════════════════════════════════════════════════════════════════════
#let explain-slide(
  title: [],
  kicker-text: none,
  lead: none,
  points: (),
  aside: none,
  width: 82%,
) = slide[
  #block(width: width)[
    #if kicker-text != none [
      #section-kicker[#kicker-text]
      #v(0.5em)
    ]
    #section-title[#title]
    #if lead != none [
      #v(0.6em)
      #muted-copy[#lead]
    ]
    #if points.len() > 0 [
      #v(0.9em)
      #for point in points {
        list.item(point)
      }
    ]
  ]

  #if aside != none [
    #place(
      right + bottom,
      dx: -0.2cm,
      dy: -0.15cm,
      accent-panel(width: 6.0cm)[#aside],
    )
  ]
]

// ═════════════════════════════════════════════════════════════════════════════
// CODE SLIDE — kicker + title + note + code block (hero element)
// ═════════════════════════════════════════════════════════════════════════════
#let code-slide(
  title: [],
  kicker-text: [Code],
  body: [],
  note: none,
  width: 78%,
) = slide[
  #block(width: width)[
    #section-kicker[#kicker-text]
    #v(0.5em)
    #section-title[#title]
    #if note != none [
      #v(0.5em)
      #muted-copy[#note]
    ]
    #v(0.85em)
    #code-block[#body]
  ]
]

// ═════════════════════════════════════════════════════════════════════════════
// COMPARISON SLIDE — two balanced columns with cards
// ═════════════════════════════════════════════════════════════════════════════
#let comparison-slide(
  title: [],
  kicker-text: [Comparison],
  left-title: [],
  left-body: [],
  right-title: [],
  right-body: [],
  note: none,
  width: 92%,
) = slide[
  #block(width: width)[
    #section-kicker[#kicker-text]
    #v(0.5em)
    #section-title[#title]
    #v(0.85em)
    #two-cols(
      [ #compare-card(left-title, left-body) ],
      [ #compare-card(right-title, right-body) ],
    )
    #if note != none [
      #v(0.7em)
      #muted-copy[#note]
    ]
  ]
]

// ═════════════════════════════════════════════════════════════════════════════
// COMPACT COMPARISON — items as bullet lists inside cards
// ═════════════════════════════════════════════════════════════════════════════
#let compact-comparison-slide(
  title: [],
  kicker-text: [Comparison],
  left-title: [],
  left-items: (),
  right-title: [],
  right-items: (),
  note: none,
  width: 92%,
) = slide[
  #block(width: width)[
    #section-kicker[#kicker-text]
    #v(0.5em)
    #section-title[#title]
    #v(0.85em)
    #two-cols(
      [
        #compare-card(left-title, [
          #for item in left-items {
            list.item(body-copy[#item])
          }
        ])
      ],
      [
        #compare-card(right-title, [
          #for item in right-items {
            list.item(body-copy[#item])
          }
        ])
      ],
    )
    #if note != none [
      #v(0.7em)
      #muted-copy[#note]
    ]
  ]
]

// ═════════════════════════════════════════════════════════════════════════════
// SYMPTOM SLIDE — title + bulleted symptom lines
// ═════════════════════════════════════════════════════════════════════════════
#let symptom-slide(
  title: [],
  lines: (),
  kicker-text: [Symptoms],
  width: 78%,
) = slide[
  #block(width: width)[
    #section-kicker[#kicker-text]
    #v(0.5em)
    #section-title[#title]
    #if lines.len() > 0 [
      #v(1.0em)
      #set list(spacing: 0.7em)
      #for line in lines {
        list.item(text(size: 22pt, weight: "medium", fill: text-main, line))
      }
    ]
  ]
]

// ═════════════════════════════════════════════════════════════════════════════
// DEMO SLIDE — transition to live demo, prominent + nearly empty
// ═════════════════════════════════════════════════════════════════════════════
#let demo-slide(
  title: [],
  note: none,
  steps: (),
  width: 78%,
) = slide[
  #v(1fr)
  #v(0.45fr)
  #block(width: width)[
    #section-kicker[Live demo]
    #v(0.6em)
    #hero-title[#title]
    #if note != none [
      #v(0.75em)
      #muted-copy[#note]
    ]
    #if steps.len() > 0 [
      #v(1.0em)
      #for step in steps {
        list.item(step)
      }
    ]
  ]
  #v(1fr)
]

// ═════════════════════════════════════════════════════════════════════════════
// APPENDIX DIVIDER — section break before appendix slides
// ═════════════════════════════════════════════════════════════════════════════
#let appendix-divider(
  title: [Appendix],
  note: [Запасные слайды для вопросов и спокойного разбора.],
) = slide[
  #v(1fr)
  #v(0.5fr)
  #block(width: 72%)[
    #section-kicker[Appendix]
    #v(0.6em)
    #hero-title[#title]
    #v(0.75em)
    #muted-copy[#note]
  ]
  #v(1fr)
]

// ═════════════════════════════════════════════════════════════════════════════
// FINAL SLIDE — closing statement
// ═════════════════════════════════════════════════════════════════════════════
#let final-slide(
  title: [],
  note: none,
  width: 76%,
) = slide[
  #v(1fr)
  #v(0.5fr)
  #block(width: width)[
    #section-kicker[Final]
    #v(0.6em)
    #hero-title[#title]
    #if note != none [
      #v(0.75em)
      #muted-copy[#note]
    ]
  ]
  #v(1fr)
]
