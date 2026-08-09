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

#let rhythm = 1em

#let body-copy(body) = text(size: body-small-size, fill: text-main, body)
#let muted-size = body-small-size * 0.89
#let compare-label-size = kicker-size * 0.93
#let title-logo-size = sidebar-w
#let title-block-width = 74%
#let title-size-hero = hero-size + 2pt
#let author-size = body-small-size
#let year-size = body-small-size * 0.89
#let code-note-size = body-small-size * 0.89
#let title-logo-dx = -0.1cm
#let title-logo-dy = 0.05cm

#let body-copy(body) = text(size: body-small-size, fill: text-main, body)
#let muted-copy(body) = text(size: muted-size, fill: text-muted, body)

// ─── Panel primitives ───────────────────────────────────────────────────────
#let soft-panel(body, width: 100%) = block(
  width: width,
  fill: surface,
  stroke: panel-stroke,
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

#let code-block-inset = (
  x: panel-inset * 1.2,
  y: panel-inset,
)

#let code-block(body, width: 100%) = block(
  width: width,
  fill: surface,
  stroke: panel-stroke,
  radius: panel-radius,
  inset: code-block-inset,
  [
    #show raw: set text(font: font-mono, size: code-size, fill: text-main)
    #body
  ],
)

#let compare-card(label, body) = soft-panel(width: 100%, [
  #text(
    size: compare-label-size,
    weight: "bold",
    fill: text-muted,
    tracking: 0.06em,
    upper(label),
  )
  #v(rhythm * 0.65)
  #body
])

#let two-cols(left, right, gutter: sidebar-gap + 0.1cm) = grid(
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
    #place(top + right, dx: title-logo-dx, dy: title-logo-dy)[
      #logo-mark(size: title-logo-size)
    ]

    #v(0.55fr)
    #v(0.2fr)

    #block(width: title-block-width)[
      #section-kicker[Rust meetup SPB]
      #v(rhythm * 0.6)
      #text(size: title-size-hero, weight: "bold", fill: text-main)[#title]
      #v(rhythm * 0.35)
      #text(size: subtitle-size, fill: text-muted, weight: "regular")[#subtitle]
    ]

    #v(0.7fr)

    #block(width: title-block-width)[
      #rule(length: 50%)
      #v(rhythm * 0.35)
      #text(size: author-size, fill: text-main)[#author]
      #h(1.0em)
      #text(size: year-size, fill: text-muted)[#year]
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
        #v(rhythm * 0.6)
      ]
      #hero-title[#title]
      #if note != none [
        #v(rhythm * 0.85)
        #text(size: subtitle-size, fill: text-muted)[#note]
      ]
    ]
  ]
  #if items.len() > 0 [
    #v(rhythm * 0.8)
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
#let content-slide-columns = (1.55fr, 0.95fr)

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
      #v(rhythm * 0.5)
    ]
    #section-title[#title]
    #if lead != none [
      #v(rhythm * 0.6)
      #muted-copy[#lead]
    ]
    #v(rhythm * 0.9)
    #if aside != none [
      #grid(
        columns: content-slide-columns,
        gutter: sidebar-gap,
        [
          #for item in items {
            list.item(item)
          }
        ],
        [
          #accent-panel(width: 100%)[#aside]
        ],
      )
    ] else if items.len() > 0 [
      #for item in items {
        list.item(item)
      }
    ]
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
    #v(rhythm * 0.3)
    #section-title[#title]
    #v(rhythm * 0.2)
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
    #v(rhythm * 0.35)
    #section-title[#title]
    #if note != none [
      #v(rhythm * 0.35)
      #text(size: code-note-size, fill: text-muted)[#note]
    ]
    #v(rhythm * 0.6)
    #code-block[#body]
  ]
]
