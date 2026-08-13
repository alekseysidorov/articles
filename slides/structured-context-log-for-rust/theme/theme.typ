// ─── Color palette (Nix-inspired, muted) ─────────────────────────────────────
#let bg = rgb("#FAFBFF")
#let surface = rgb("#FFFFFF")
#let text-main = rgb("#111827")
#let text-muted = rgb("#4B5563")
#let accent = rgb("#D34516")
#let accent-soft = rgb("#E6EEFF")
#let accent-purple = rgb("#7C3AED")
#let border = rgb("#E5E7EB")
#let sidebar-fill = rgb("#F0F3FA")

// ─── Fonts ───────────────────────────────────────────────────────────────────
#let font-sans = "Inter"
#let font-mono = "JetBrains Mono"

// ─── Sidebar geometry ────────────────────────────────────────────────────────
// 3.2cm ≈ 12.6% of slide width — enough to feel like a branded panel,
// not so wide that it steals content space.
#let sidebar-w = 4.4cm
#let sidebar-gap = 0.9cm

#let logo-scale = 1.25
#let logo-size = sidebar-w * logo-scale

#let margin-right = 1.8cm
#let margin-top = 1.5cm
#let margin-bottom = 1.2cm
#let page-margins = (
  left: sidebar-w + sidebar-gap,
  right: margin-right,
  top: margin-top,
  bottom: margin-bottom,
)

// Title slide has no sidebar, so symmetrical wide margins.
#let title-margin-x = 2.4cm
#let title-margin-top = 1.8cm
#let title-margin-bottom = 1.5cm
#let title-page-margins = (
  left: title-margin-x,
  right: title-margin-x,
  top: title-margin-top,
  bottom: title-margin-bottom,
)

// ─── Typography scale (tuned for projector at distance) ─────────────────────
#let hero-size = 40pt
#let title-size = 32pt
#let subtitle-size = 20pt
#let body-size = 20pt
#let body-small-size = 18pt
#let code-size = 16pt
#let kicker-size = 14pt
#let page-number-size = 13pt

// ─── Panels ──────────────────────────────────────────────────────────────────
#let panel-radius = 10pt
#let panel-inset = 20pt
#let panel-stroke = border + 0.7pt

// ─── Sidebar placement offsets ───────────────────────────────────────────────
#let sidebar-logo-offset-y = 1.55cm
#let sidebar-page-number-offset-y = -0.55cm

// ─── Sidebar background (placed as page background on content slides) ───────
// Contains: coloured strip, accent border, Nix logo (centred), page number
// (bottom).  The page number lives here so the footer stays empty and content
// can use the full vertical extent of the page.
#let sidebar-bg = context {
  // Coloured strip
  place(
    top + left,
    rect(width: sidebar-w, height: 100%, fill: sidebar-fill),
  )
  // Thin accent line at the right edge
  place(
    top + left,
    dx: sidebar-w,
    line(start: (0pt, 0pt), end: (0pt, 100%), stroke: panel-stroke),
  )
  // Nix logo — выровнен по верхнему ритму заголовков, а не по центру слайда
  place(
    top + left,
    dx: (sidebar-w - logo-size) / 2,
    dy: sidebar-logo-offset-y,
    image(
      "../assets/rust-logo.svg",
      width: logo-size,
      height: logo-size,
      fit: "contain",
    ),
  )
  // Page number — bottom of sidebar, centred horizontally
  place(
    bottom + left,
    dy: sidebar-page-number-offset-y,
    block(width: sidebar-w)[
      #set align(center)
      #text(size: page-number-size, fill: text-muted, weight: "regular")[
        #counter(page).display()
      ]
    ],
  )
}

// ─── Page number helper (used only by the title slide footer) ───────────────
#let page-number = context align(
  right,
  text(size: page-number-size, fill: text-muted, weight: "regular")[
    #counter(page).display()
  ],
)

// ─── Deck show rule (applied via `#show: deck`) ─────────────────────────────
#let deck(doc) = {
  set page(
    paper: "presentation-16-9",
    margin: page-margins,
    fill: bg,
    background: sidebar-bg,
    // No footer — the page number is rendered inside the sidebar background.
  )

  set text(
    font: font-sans,
    size: body-size,
    fill: text-main,
    lang: "ru",
  )

  set par(
    leading: 0.68em,
    justify: false,
  )

  set list(
    marker: text(fill: accent, size: 18pt)[▸],
    indent: 0.9em,
    body-indent: 0.55em,
    spacing: 0.55em,
  )

  doc
}

// ─── Primitive text helpers ──────────────────────────────────────────────────
#let kicker(body) = text(
  size: kicker-size,
  weight: "bold",
  tracking: 0.1em,
  fill: accent,
  upper(body),
)

#let title(body) = text(
  size: title-size,
  weight: "semibold",
  fill: text-main,
  body,
)

#let hero(body) = text(
  size: hero-size,
  weight: "bold",
  fill: text-main,
  body,
)

#let subtitle(body) = text(
  size: subtitle-size,
  fill: text-muted,
  body,
)

#let rule(length: 100%) = line(length: length, stroke: panel-stroke)

// ─── Logo helper ─────────────────────────────────────────────────────────────
#let logo-mark(
  size: logo-size,
  path: "../assets/ferris.png",
) = image(
  path,
  width: size,
  height: size,
  fit: "contain",
)
