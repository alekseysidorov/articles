#import "theme.typ": *

#let slide(body) = [
  #pagebreak()
  #body
]

#let raw-code(text, lang: none) = raw(
  text,
  block: true,
  lang: lang,
)

#let text-code(text) = raw-code(text, lang: "text")

#let bash-code(text) = raw-code(text, lang: "bash")

#let yaml-code(text) = raw-code(text, lang: "yaml")

#let nix-code(text) = raw-code(text, lang: "nix")



#let content-block(body, width: content-width) = block(
  width: width,
  body,
)

#let body-copy(body) = text(
  size: 15pt,
  fill: text-main,
  body,
)

#let muted-copy(body) = text(
  size: 15pt,
  fill: text-muted,
  body,
)

#let section-kicker(body) = kicker(body)

#let section-title(body) = title(body)

#let hero-title(body) = hero(body)

#let inline-code(body, fill: text-main, size: 15pt, weight: "regular") = text(
  font: font-mono,
  size: size,
  fill: fill,
  weight: weight,
  body,
)

#let command(body, accent-line: false) = inline-code(
  body,
  fill: if accent-line { accent } else { text-main },
  size: 13pt,
)

#let soft-panel(body, width: 100%, inset: 18pt, radius: 12pt) = block(
  width: width,
  fill: surface,
  stroke: border + 0.8pt,
  radius: radius,
  inset: inset,
  body,
)

#let accent-panel(body, width: 100%, inset: 18pt, radius: 12pt) = block(
  width: width,
  fill: accent-soft,
  radius: radius,
  inset: inset,
  body,
)

#let code-block(body, width: 100%) = block(
  width: width,
  fill: surface,
  stroke: border + 0.8pt,
  radius: 12pt,
  inset: 18pt,
  [
    #show raw: set text(font: font-mono, size: 13pt, fill: text-main)
    #body
  ],
)

#let compare-card(label, body) = soft-panel(
  width: 100%,
  [
    #text(size: 11pt, weight: "medium", fill: text-muted, upper(label))
    #v(0.55em)
    #body
  ],
)

#let two-cols(left, right, gutter: 1.4cm) = grid(
  columns: (1fr, 1fr),
  gutter: gutter,
  left,
  right,
)

#let logo-mark(size: 1.8cm) = image(
  "../assets/nixos-logomark-rainbow-gradient-recommended.svg",
  width: size,
  height: size,
  fit: "contain",
)

#let corner-logo(size: 1.8cm) = place(
  top + right,
  dx: -0.1cm,
  dy: 0.05cm,
  box(inset: 0pt)[#logo-mark(size: size)],
)

#let title-slide(
  title: [],
  subtitle: [],
  author: [],
  year: [2025],
  show-logo: true,
) = [
  #if show-logo [
    #corner-logo(size: 2.3cm)
  ]

  #v(1.15fr)
  #content-block(width: 72%)[
    #section-kicker[Nix × Rust]
    #v(0.85em)
    #text(size: 44pt, weight: "semibold", fill: text-main)[#title]
    #v(0.6em)
    #text(size: subtitle-size, fill: text-muted)[#subtitle]
    #v(1.55em)
    #rule()
    #v(1em)
    #text(size: 14pt, fill: text-main)[#author]
    #v(0.35em)
    #text(size: 12pt, fill: text-muted)[#year]
  ]
  #v(1fr)
]

#let big-idea(
  title: [],
  kicker-text: [Big idea],
  width: 68%,
  note: none,
  alignment: left,
  show-logo: false,
) = slide[
  #if show-logo [
    #corner-logo()
  ]
  #v(0.45cm)
  #align(alignment)[
    #content-block(width: width)[
      #section-kicker[#kicker-text]
      #v(0.75em)
      #hero-title[#title]
      #if note != none [
        #v(0.8em)
        #muted-copy[#note]
      ]
    ]
  ]
]

#let explain-slide(
  title: [],
  kicker-text: none,
  lead: none,
  points: (),
  aside: none,
  width: narrow-width,
  show-logo: false,
) = slide[
  #if show-logo [
    #corner-logo()
  ]

  #content-block(width: width)[
    #if kicker-text != none [
      #section-kicker[#kicker-text]
      #v(0.7em)
    ]
    #section-title[#title]
    #if lead != none [
      #v(0.8em)
      #muted-copy[#lead]
    ]
    #if points.len() > 0 [
      #v(1.05em)
      #for point in points {
        list.item(point)
      }
    ]
  ]

  #if aside != none [
    #place(
      right + bottom,
      dx: -0.3cm,
      dy: -0.15cm,
      accent-panel(
        width: 5.9cm,
        [
          #aside
        ],
      ),
    )
  ]
]

#let code-slide(
  title: [],
  kicker-text: [Code],
  body: [],
  note: none,
  width: content-width,
  show-logo: false,
) = slide[
  #if show-logo [
    #corner-logo()
  ]

  #content-block(width: width)[
    #section-kicker[#kicker-text]
    #v(0.7em)
    #section-title[#title]
    #v(0.9em)
    #code-block[#body]
    #if note != none [
      #v(0.8em)
      #muted-copy[#note]
    ]
  ]
]

#let comparison-slide(
  title: [],
  kicker-text: [Comparison],
  left-title: [],
  left-body: [],
  right-title: [],
  right-body: [],
  note: none,
  width: wide-width,
  show-logo: false,
) = slide[
  #if show-logo [
    #corner-logo()
  ]

  #content-block(width: width)[
    #section-kicker[#kicker-text]
    #v(0.7em)
    #section-title[#title]
    #v(1em)
    #two-cols(
      [
        #compare-card(left-title, left-body)
      ],
      [
        #compare-card(right-title, right-body)
      ],
    )
    #if note != none [
      #v(0.95em)
      #muted-copy[#note]
    ]
  ]
]

#let demo-slide(
  title: [],
  steps: (),
  note: none,
  width: content-width,
  show-logo: true,
) = slide[
  #if show-logo [
    #corner-logo(size: 2cm)
  ]

  #v(0.2cm)
  #content-block(width: width)[
    #section-kicker[Live demo]
    #v(0.7em)
    #hero-title[#title]
    #if steps.len() > 0 [
      #v(1em)
      #for step in steps {
        list.item(step)
      }
    ]
    #if note != none [
      #v(1em)
      #muted-copy[#note]
    ]
  ]
]

#let transition-slide(
  title: [],
  note: none,
  alignment: center,
  width: 72%,
  show-logo: false,
) = slide[
  #if show-logo [
    #corner-logo()
  ]

  #v(1fr)
  #align(alignment)[
    #content-block(width: width)[
      #hero-title[#title]
      #if note != none [
        #v(0.85em)
        #muted-copy[#note]
      ]
    ]
  ]
  #v(1fr)
]

#let appendix-divider(
  title: [Дополнительные материалы],
  note: [Дальше — запасные слайды для вопросов и обсуждения.],
  show-logo: true,
) = slide[
  #if show-logo [
    #corner-logo(size: 2.1cm)
  ]

  #v(1fr)
  #content-block(width: 72%)[
    #section-kicker[Appendix]
    #v(0.85em)
    #hero-title[#title]
    #v(0.8em)
    #muted-copy[#note]
  ]
  #v(1fr)
]

#let appendix-slide(
  title: [],
  lead: none,
  body: [],
  width: 76%,
  show-logo: false,
) = slide[
  #if show-logo [
    #corner-logo()
  ]

  #content-block(width: width)[
    #section-kicker[Appendix]
    #v(0.7em)
    #section-title[#title]
    #if lead != none [
      #v(0.75em)
      #muted-copy[#lead]
    ]
    #v(0.9em)
    #body
  ]
]

#let appendix-points(
  title: [],
  lead: none,
  points: (),
  width: 68%,
  show-logo: false,
) = slide[
  #if show-logo [
    #corner-logo()
  ]

  #content-block(width: width)[
    #section-kicker[Appendix]
    #v(0.7em)
    #section-title[#title]
    #if lead != none [
      #v(0.8em)
      #muted-copy[#lead]
    ]
    #if points.len() > 0 [
      #v(1.05em)
      #for point in points {
        list.item(point)
      }
    ]
  ]
]

#let final-slide(
  title: [],
  note: none,
  width: 70%,
  show-logo: true,
) = slide[
  #if show-logo [
    #corner-logo(size: 2cm)
  ]

  #v(0.75cm)
  #content-block(width: width)[
    #section-kicker[Final idea]
    #v(0.8em)
    #hero-title[#title]
    #if note != none [
      #v(0.9em)
      #muted-copy[#note]
    ]
  ]
]
