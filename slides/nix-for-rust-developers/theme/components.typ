#import "theme.typ": *

#let sidebar-width = 19%
#let sidebar-gap = 1.1cm
#let content-width = 1fr

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

#let body-copy(body) = text(
  size: 16pt,
  fill: text-main,
  body,
)

#let muted-copy(body) = text(
  size: 16pt,
  fill: text-muted,
  body,
)

#let note-copy(body) = text(
  size: 14pt,
  fill: text-muted,
  body,
)

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
  size: 14pt,
)

#let section-kicker(body) = text(
  size: 11pt,
  weight: "medium",
  tracking: 0.06em,
  fill: text-muted,
  upper(body),
)

#let section-title(body) = text(
  size: 34pt,
  weight: "semibold",
  fill: text-main,
  body,
)

#let hero-title(body) = text(
  size: 48pt,
  weight: "semibold",
  fill: text-main,
  body,
)

#let logo-mark(size: 1.8cm) = image(
  "../assets/nixos-logomark-rainbow-gradient-recommended.svg",
  width: size,
  height: size,
  fit: "contain",
)

#let soft-panel(body, width: 100%, inset: 22pt, radius: 12pt) = block(
  width: width,
  fill: surface,
  stroke: border + 0.8pt,
  radius: radius,
  inset: inset,
  body,
)

#let accent-panel(body, width: 100%, inset: 22pt, radius: 12pt) = block(
  width: width,
  fill: accent-soft,
  radius: radius,
  inset: inset,
  body,
)

#let code-block(body, width: 100%) = block(
  width: width,
  fill: accent-soft,
  stroke: border + 0.8pt,
  radius: 14pt,
  inset: 24pt,
  [
    #show raw: set text(font: font-mono, size: 16pt, fill: text-main)
    #body
  ],
)

#let compare-card(label, body) = soft-panel(
  width: 100%,
  [
    #text(size: 11pt, weight: "medium", fill: text-muted, upper(label))
    #v(0.7em)
    #body
  ],
)

#let sidebar(body) = block(
  width: 100%,
  [
    #body
  ],
)

#let sidebar-label(body) = [
  #section-kicker[#body]
]

#let sidebar-meta(body) = [
  #v(0.7em)
  #note-copy[#body]
]

#let sidebar-divider() = line(
  length: 100%,
  stroke: border + 0.8pt,
  angle: 90deg,
)

#let content-block(body) = block(
  width: 100%,
  body,
)

#let two-cols(left, right, gutter: 1.05cm) = grid(
  columns: (1fr, 1fr),
  gutter: gutter,
  left, right,
)

#let shell-lines(lines, accent-index: none) = [
  #for (idx, line) in lines.enumerate() [
    #if accent-index != none and idx == accent-index [
      #command(line, accent-line: true)
    ] else [
      #command(line)
    ]
    #if idx + 1 < lines.len() [#linebreak()]
  ]
]

#let with-sidebar(label, body, sidebar-note: none, show-logo: false) = [
  #if show-logo [
    #place(
      top + right,
      dx: -0.2cm,
      dy: 0.1cm,
      box(inset: 0pt)[#logo-mark(size: 2cm)],
    )
  ]

  #grid(
    columns: (sidebar-width, content-width),
    gutter: sidebar-gap,
    align: top + left,
    [
      #sidebar[
        #sidebar-label[#label]
        #if sidebar-note != none [
          #sidebar-meta[#sidebar-note]
        ]
      ]
    ],
    [
      #content-block[
        #body
      ]
    ],
  )
]

#let title-slide(
  title: [],
  subtitle: [],
  author: [],
  year: [2025],
  show-logo: true,
) = [
  #if show-logo [
    #place(
      top + right,
      dx: -0.15cm,
      dy: 0.05cm,
      box(inset: 0pt)[#logo-mark(size: 2.5cm)],
    )
  ]

  #v(0.45cm)
  #grid(
    columns: (sidebar-width, content-width),
    gutter: sidebar-gap,
    align: top + left,
    [
      #sidebar[
        #section-kicker[Nix × Rust]
        #v(1.2em)
        #note-copy[#year]
      ]
    ],
    [
      #content-block[
        #v(0.5cm)
        #hero-title[#title]
        #v(0.45em)
        #text(size: 23pt, fill: text-main, weight: "medium")[#subtitle]
        #v(1.3em)
        #rule(length: 72%)
        #v(0.9em)
        #text(size: 15pt, fill: text-main)[#author]
      ]
    ],
  )
  #v(1fr)
]

#let big-idea(
  title: [],
  kicker-text: [Big idea],
  note: none,
  width: 78%,
  show-logo: false,
) = slide[
  #with-sidebar(kicker-text, show-logo: show-logo)[
    #block(width: width)[
      #hero-title[#title]
      #if note != none [
        #v(0.85em)
        #subtitle[#note]
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
  width: 78%,
  show-logo: false,
) = slide[
  #with-sidebar(kicker-text, show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #if lead != none [
        #v(0.65em)
        #subtitle[#lead]
      ]
      #if points.len() > 0 [
        #v(1.0em)
        #for point in points [
          #body-copy[#point]
          #v(0.55em)
        ]
      ]
      #if aside != none [
        #v(1.0em)
        #accent-panel(width: 82%)[#aside]
      ]
    ]
  ]
]

#let code-slide(
  title: [],
  kicker-text: [Code],
  body: [],
  note: none,
  width: 82%,
  show-logo: false,
) = slide[
  #with-sidebar(kicker-text, show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #if note != none [
        #v(0.55em)
        #subtitle[#note]
      ]
      #v(0.95em)
      #code-block[#body]
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
  width: 92%,
  show-logo: false,
) = slide[
  #with-sidebar(kicker-text, show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #if note != none [
        #v(0.55em)
        #subtitle[#note]
      ]
      #v(0.95em)
      #two-cols(
        [
          #compare-card(left-title, left-body)
        ],
        [
          #compare-card(right-title, right-body)
        ],
      )
    ]
  ]
]

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
  #with-sidebar(kicker-text, show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #if note != none [
        #v(0.55em)
        #subtitle[#note]
      ]
      #v(0.95em)
      #two-cols(
        [
          #compare-card(left-title, [
            #for item in left-items [
              #body-copy[#item]
              #v(0.45em)
            ]
          ])
        ],
        [
          #compare-card(right-title, [
            #for item in right-items [
              #body-copy[#item]
              #v(0.45em)
            ]
          ])
        ],
      )
    ]
  ]
]

#let symptom-slide(
  title: [],
  lines: (),
  kicker-text: [Symptoms],
  width: 74%,
  show-logo: false,
) = slide[
  #with-sidebar(kicker-text, show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #if lines.len() > 0 [
        #v(1.0em)
        #for line in lines [
          #text(size: 28pt, weight: "medium", fill: text-main)[#line]
          #v(0.55em)
        ]
      ]
    ]
  ]
]

#let transition-slide(
  title: [],
  note: none,
  width: 74%,
  kicker-text: [Transition],
  show-logo: false,
) = slide[
  #with-sidebar(kicker-text, show-logo: show-logo)[
    #block(width: width)[
      #hero-title[#title]
      #if note != none [
        #v(0.8em)
        #subtitle[#note]
      ]
    ]
  ]
]

#let demo-slide(
  title: [],
  steps: (),
  note: none,
  width: 76%,
  show-logo: true,
) = slide[
  #with-sidebar([Live demo], show-logo: show-logo)[
    #block(width: width)[
      #hero-title[#title]
      #if note != none [
        #v(0.8em)
        #subtitle[#note]
      ]
      #if steps.len() > 0 [
        #v(1.0em)
        #for step in steps [
          #body-copy[#step]
          #v(0.5em)
        ]
      ]
    ]
  ]
]

#let faq-slide(
  title: [],
  left: [],
  right: [],
  note: none,
  width: 78%,
  show-logo: false,
) = slide[
  #with-sidebar([FAQ], show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #v(1em)
      #soft-panel(width: 76%)[
        #text(size: 22pt, weight: "semibold", fill: text-main)[#left]
        #v(0.5em)
        #subtitle[#right]
      ]
      #if note != none [
        #v(0.8em)
        #note-copy[#note]
      ]
    ]
  ]
]

#let appendix-divider(
  title: [Appendix],
  note: [Спокойный разбор после demo.],
  show-logo: true,
) = slide[
  #with-sidebar([Appendix], sidebar-note: note, show-logo: show-logo)[
    #block(width: 74%)[
      #hero-title[#title]
    ]
  ]
]

#let appendix-slide(
  title: [],
  lead: none,
  body: [],
  width: 84%,
  show-logo: false,
) = slide[
  #with-sidebar([Appendix], show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #if lead != none [
        #v(0.6em)
        #subtitle[#lead]
      ]
      #v(0.95em)
      #body
    ]
  ]
]

#let appendix-points(
  title: [],
  lead: none,
  points: (),
  width: 78%,
  show-logo: false,
) = slide[
  #with-sidebar([Appendix], show-logo: show-logo)[
    #block(width: width)[
      #section-title[#title]
      #if lead != none [
        #v(0.65em)
        #subtitle[#lead]
      ]
      #if points.len() > 0 [
        #v(0.95em)
        #for point in points [
          #body-copy[#point]
          #v(0.5em)
        ]
      ]
    ]
  ]
]

#let final-slide(
  title: [],
  note: none,
  width: 76%,
  show-logo: true,
) = slide[
  #with-sidebar([Final], show-logo: show-logo)[
    #block(width: width)[
      #hero-title[#title]
      #if note != none [
        #v(0.8em)
        #subtitle[#note]
      ]
    ]
  ]
]
