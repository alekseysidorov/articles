// ─── Color palette (Nix-inspired, muted) ─────────────────────────────────────
#let bg = rgb("#FAFBFF")
#let surface = rgb("#FFFFFF")
#let text-main = rgb("#111827")
#let text-muted = rgb("#6B7280")
#let accent = rgb("#5277C3")
#let accent-soft = rgb("#E6EEFF")
#let accent-purple = rgb("#7C3AED")
#let border = rgb("#E5E7EB")
#let sidebar-fill = rgb("#F0F3FA")

// ─── Fonts ───────────────────────────────────────────────────────────────────
#let font-sans = "Inter"
#let font-mono = "JetBrains Mono"

// ─── Sidebar geometry ────────────────────────────────────────────────────────
// The sidebar is a persistent visual strip on the left of every content slide.
// Its width is ~7.5% of slide width (≈ 1.27cm on 16:9) — enough for a rotated
// label without stealing space from the content zone.
#let sidebar-w = 1.27cm

// ─── Page margins (content slides) ──────────────────────────────────────────
// Left margin = sidebar-w + comfortable gap.
// Right / top / bottom follow 8-pt multiples for grid discipline.
#let page-margins = (
  left: sidebar-w + 1.35cm,
  right: 2.0cm,
  top: 1.6cm,
  bottom: 1.35cm,
)

// Title slide has no sidebar, so symmetrical wide margins.
#let title-page-margins = (
  left: 2.4cm,
  right: 2.4cm,
  top: 1.8cm,
  bottom: 1.5cm,
)

// ─── Content widths (% of text area after margins) ──────────────────────────
#let content-width = 100%
#let narrow-width = 72%
#let wide-width = 92%

// ─── Typography scale ────────────────────────────────────────────────────────
// Based on a ~1.35 ratio.  Headline sizes are intentionally large so that
// even short statements carry visual weight on a 16:9 canvas.
#let hero-size = 42pt
#let title-size = 30pt
#let subtitle-size = 19pt
#let body-size = 19pt
#let body-small-size = 16pt
#let code-size = 15pt
#let kicker-size = 10pt
#let sidebar-label-size = 9pt

// ─── Panels ──────────────────────────────────────────────────────────────────
#let panel-radius = 10pt
#let panel-inset = 20pt

// ─── Sidebar background (placed as page background on content slides) ───────
#let sidebar-bg = context {
  place(
    top + left,
    rect(width: sidebar-w, height: 100%, fill: sidebar-fill),
  )
  // thin accent line at the right edge of the sidebar
  place(
    top + left,
    dx: sidebar-w,
    line(start: (0pt, 0pt), end: (0pt, 100%), stroke: border + 0.7pt),
  )
}

// ─── Deck show rule (applied via `#show: deck`) ─────────────────────────────
#let deck(doc) = {
  set page(
    paper: "presentation-16-9",
    margin: page-margins,
    fill: bg,
    background: sidebar-bg,
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
    marker: text(fill: accent, size: 14pt)[▸],
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

#let body-text(body) = text(
  size: body-small-size,
  fill: text-main,
  body,
)

#let muted(body) = text(
  size: body-small-size,
  fill: text-muted,
  body,
)

#let mono(body, fill: text-main, weight: "regular") = text(
  font: font-mono,
  size: code-size,
  fill: fill,
  weight: weight,
  body,
)

#let accent-text(body) = text(fill: accent, body)

#let rule(length: 100%) = line(length: length, stroke: border + 0.7pt)

// ─── Surface blocks ─────────────────────────────────────────────────────────
#let soft-surface(
  body,
  width: 100%,
  inset: panel-inset,
  radius: panel-radius,
) = block(
  width: width,
  fill: surface,
  stroke: border + 0.7pt,
  inset: inset,
  radius: radius,
  body,
)

#let tint-surface(
  body,
  width: 100%,
  inset: panel-inset,
  radius: panel-radius,
) = block(
  width: width,
  fill: accent-soft,
  inset: inset,
  radius: radius,
  body,
)

// ─── Logo helper ─────────────────────────────────────────────────────────────
#let logo-mark(
  size: 2.2cm,
  path: "../assets/nixos-logomark-rainbow-gradient-recommended.svg",
) = image(
  path,
  width: size,
  height: size,
  fit: "contain",
)
