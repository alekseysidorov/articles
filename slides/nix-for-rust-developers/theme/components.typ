#import "theme.typ": *

// ─── Raw code helpers ───────────────────────────────────────────────────────
#let raw-code(text, lang: none) = raw(text, block: true, lang: lang)
#let bash-code(text) = raw-code(text, lang: "bash")
#let yaml-code(text) = raw-code(text, lang: "yaml")
#let nix-code(text) = raw-code(text, lang: "nix")

// ─── Typography aliases (avoid shadowing by slide parameters) ───────────────
#let section-kicker(body) = kicker(body)
#let section-title(body) = title(body)
#let hero-title(body) = hero(body)

#let body-copy(body) = text(size: body-small-size, fill: text-main, body)
#let muted-copy(body) = text(size: body-small-size, fill: text-muted, body)

// ─── Panel primitives ───────────────────────────────────────────────────────
#let soft-panel(body, width: 100%) = block(
  width: width,
  fill: surface,
  stroke: border + 0.7pt,
  radius: panel-radius,
  inset: panel-inset,
  body,
)

#let accent-panel(body, width: 100%) = block(
  width: width,
  fill: accent-soft,
  radius: panel-radius,
  inset: panel-inset,
  body,
)

#let code-block(body, width: 100%) = block(
  width: width,
  fill: surface,
  stroke: border + 0.7pt,
  radius: panel-radius,
  inset: (x: 24pt, y: 20pt),
  [
    #show raw: set text(font: font-mono, size: code-size, fill: text-main)
    #body
  ],
)

#let compare-card(label, body) = soft-panel(width: 100%, [
  #text(
    size: 13pt,
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

// ─── Page helper ────────────────────────────────────────────────────────────
#let slide(body) = [#pagebreak() #body]

// ═════════════════════════════════════════════════════════════════════════════
// TITLE SLIDE — no sidebar, full-bleed
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
    #place(top + right, dx: 0.5cm, dy: -0.3cm)[#logo-mark(size: 3.5cm)]

    #v(1fr)
    #v(0.5fr)

    #block(width: 78%)[
      #section-kicker[Nix × Rust]
      #v(0.6em)
      #text(size: 48pt, weight: "bold", fill: text-main)[#title]
      #v(0.35em)
      #text(size: subtitle-size, fill: text-muted, weight: "regular")[#subtitle]
    ]

    #v(1fr)

    #block(width: 78%)[
      #rule(length: 50%)
      #v(0.35em)
      #text(size: 18pt, fill: text-main)[#author]
      #h(1.0em)
      #text(size: 16pt, fill: text-muted)[#year]
    ]
  ]
}

// ═════════════════════════════════════════════════════════════════════════════
// HERO SLIDE — big centred statement + optional note & items
// (replaces: big-idea, demo-slide, appendix-divider, final-slide)
// ═════════════════════════════════════════════════════════════════════════════
#let hero-slide(
  title: [],
  kicker: none,
  note: none,
  items: (),
  width: 80%,
) = slide[
  #v(1fr)
  #align(center)[
    #block(width: width)[
      #set align(center)
      #if kicker != none [
        #section-kicker[#kicker]
        #v(0.6em)
      ]
      #hero-title[#title]
      #if note != none [
        #v(0.85em)
        #text(size: subtitle-size, fill: text-muted)[#note]
      ]
    ]
  ]
  #if items.len() > 0 [
    #v(0.8em)
    #block(width: width)[
      #for item in items {
        list.item(item)
      }
    ]
  ]
  #v(1fr)
]

// ═════════════════════════════════════════════════════════════════════════════
// CONTENT SLIDE — title + optional lead + bullet items + optional aside
// (replaces: explain-slide, symptom-slide)
// ═════════════════════════════════════════════════════════════════════════════
#let content-slide(
  title: [],
  kicker: none,
  lead: none,
  items: (),
  aside: none,
  width: 92%,
) = slide[
  #block(width: width)[
    #if kicker != none [
      #section-kicker[#kicker]
      #v(0.5em)
    ]
    #section-title[#title]
    #if lead != none [
      #v(0.6em)
      #muted-copy[#lead]
    ]
    #if items.len() > 0 [
      #v(0.9em)
      #for item in items {
        list.item(item)
      }
    ]
  ]

  #if aside != none [
    #place(
      right + bottom,
      dx: -0.2cm,
      dy: -0.15cm,
      accent-panel(width: 7cm)[#aside],
    )
  ]
]

// ═════════════════════════════════════════════════════════════════════════════
// COMPARISON SLIDE — two-column cards with item lists
// (replaces: compact-comparison-slide, comparison-slide)
// Note is pinned to the bottom via `place` so it can never overflow.
// ═════════════════════════════════════════════════════════════════════════════
#let comparison-slide(
  title: [],
  kicker: [Comparison],
  left-title: [],
  left-items: (),
  right-title: [],
  right-items: (),
  note: none,
  width: 92%,
) = slide[
  #block(width: width)[
    #section-kicker[#kicker]
    #v(0.5em)
    #section-title[#title]
    #v(0.7em)
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
  ]

  #if note != none [
    #place(bottom + left)[
      #block(width: width)[
        #muted-copy[#note]
      ]
    ]
  ]
]

// ═════════════════════════════════════════════════════════════════════════════
// CODE SLIDE — title + note + code block
// ═════════════════════════════════════════════════════════════════════════════
#let code-slide(
  title: [],
  kicker: [Code],
  body: [],
  note: none,
  width: 92%,
) = slide[
  #block(width: width)[
    #section-kicker[#kicker]
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
