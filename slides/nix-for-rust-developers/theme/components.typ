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

// ─── Sidebar section label ──────────────────────────────────────────────────
// Placed inside the sidebar strip area using `place`.
// The label sits near the top of the sidebar, aligned to top-left,
// with a small inset so it doesn't touch the edge.
#let sidebar-section(label) = place(
  top + left,
  dx: 0.35cm,
  dy: 1.55cm,
  block(width: sidebar-w - 0.4cm)[
    #text(
      font: font-sans,
      size: sidebar-label-size,
      weight: "bold",
      fill: text-muted,
      tracking: 0.1em,
    )[#upper(label)]
  ],
)

// ─── Page-level helpers ─────────────────────────────────────────────────────
#let slide(body) = [
  #pagebreak()
  #body
]

#let corner-logo(size: 2.2cm) = place(
  top + right,
  dx: -0.3cm,
  dy: 0.35cm,
  box(inset: 0pt)[#logo-mark(size: size)],
)

// ═════════════════════════════════════════════════════════════════════════════
// TITLE SLIDE — no sidebar, full-bleed, golden-ratio vertical position
// ═════════════════════════════════════════════════════════════════════════════
#let title-slide(
  title: [],
  subtitle: [],
  author: [],
  year: [2025],
  show-logo: true,
) = {
  // Override page settings: no sidebar background, wide symmetrical margins.
  set page(
    paper: "presentation-16-9",
    margin: title-page-margins,
    fill: bg,
    background: none,
  )

  [
    #if show-logo [
      #corner-logo(size: 2.5cm)
    ]

    // Golden ratio: content starts at ~38% from the top.
    #v(1fr)
    #v(0.62fr)

    #block(width: 78%)[
      #section-kicker[Nix × Rust]
      #v(1.0em)
      #text(size: 48pt, weight: "bold", fill: text-main)[#title]
      #v(0.5em)
      #text(size: 22pt, fill: text-muted, weight: "regular")[#subtitle]
      #v(1.8em)
      #rule(length: 50%)
      #v(0.9em)
      #text(size: 15pt, fill: text-main)[#author]
      #h(1.5em)
      #text(size: 13pt, fill: text-muted)[#year]
    ]

    #v(1fr)
  ]
}

// ═════════════════════════════════════════════════════════════════════════════
// BIG IDEA — one strong statement, optional supporting line
// ═════════════════════════════════════════════════════════════════════════════
#let big-idea(
  title: [],
  kicker-text: [Big idea],
  note: none,
  width: 80%,
  show-logo: false,
) = slide[
  #sidebar-section(kicker-text)
  #if show-logo [ #corner-logo() ]

  // Vertically centered, slightly above middle (golden ratio).
  #v(1fr)
  #v(0.5fr)
  #block(width: width)[
    #hero-title[#title]
    #if note != none [
      #v(0.85em)
      #text(size: subtitle-size, fill: text-muted)[#note]
    ]
  ]
  #v(1fr)
]

// ═════════════════════════════════════════════════════════════════════════════
// EXPLAIN SLIDE — title + lead + points + optional aside panel
// ═════════════════════════════════════════════════════════════════════════════
#let explain-slide(
  title: [],
  kicker-text: none,
  lead: none,
  points: (),
  aside: none,
  width: 82%,
  show-logo: false,
) = slide[
  #if kicker-text != none [ #sidebar-section(kicker-text) ]
  #if show-logo [ #corner-logo() ]

  #block(width: width)[
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
// CODE SLIDE — title + note above code block (code = hero element)
// ═════════════════════════════════════════════════════════════════════════════
#let code-slide(
  title: [],
  kicker-text: [Code],
  body: [],
  note: none,
  width: 78%,
  show-logo: false,
) = slide[
  #sidebar-section(kicker-text)
  #if show-logo [ #corner-logo() ]

  #block(width: width)[
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
  show-logo: false,
) = slide[
  #sidebar-section(kicker-text)
  #if show-logo [ #corner-logo() ]

  #block(width: width)[
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
// COMPACT COMPARISON — items as simple text lists inside cards
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
  show-logo: false,
) = slide[
  #sidebar-section(kicker-text)
  #if show-logo [ #corner-logo() ]

  #block(width: width)[
    #section-title[#title]
    #v(0.85em)
    #two-cols(
      [
        #compare-card(left-title, [
          #for item in left-items [
            #body-copy[#item]
            #v(0.4em)
          ]
        ])
      ],
      [
        #compare-card(right-title, [
          #for item in right-items [
            #body-copy[#item]
            #v(0.4em)
          ]
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
// SYMPTOM SLIDE — title + large-ish statement lines (not bullets)
// ═════════════════════════════════════════════════════════════════════════════
#let symptom-slide(
  title: [],
  lines: (),
  kicker-text: [Symptoms],
  width: 78%,
  show-logo: false,
) = slide[
  #sidebar-section(kicker-text)
  #if show-logo [ #corner-logo() ]

  #block(width: width)[
    #section-title[#title]
    #if lines.len() > 0 [
      #v(1.0em)
      #for line in lines [
        #text(size: 26pt, weight: "medium", fill: text-main)[#line]
        #v(0.6em)
      ]
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
  show-logo: true,
) = slide[
  #sidebar-section([Live demo])
  #if show-logo [ #corner-logo() ]

  #v(1fr)
  #v(0.45fr)
  #block(width: width)[
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
  show-logo: true,
) = slide[
  #sidebar-section([Appendix])
  #if show-logo [ #corner-logo() ]

  #v(1fr)
  #v(0.5fr)
  #block(width: 72%)[
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
  show-logo: true,
) = slide[
  #sidebar-section([Final])
  #if show-logo [ #corner-logo() ]

  #v(1fr)
  #v(0.5fr)
  #block(width: width)[
    #hero-title[#title]
    #if note != none [
      #v(0.75em)
      #muted-copy[#note]
    ]
  ]
  #v(1fr)
]
