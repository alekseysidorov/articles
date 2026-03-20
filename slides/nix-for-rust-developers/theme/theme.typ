#let bg = rgb("#FAFBFF")
#let surface = rgb("#FFFFFF")
#let text-main = rgb("#111827")
#let text-muted = rgb("#6B7280")
#let accent = rgb("#5277C3")
#let accent-soft = rgb("#E6EEFF")
#let accent-purple = rgb("#7C3AED")
#let border = rgb("#E5E7EB")

#let font-sans = "Inter"
#let font-mono = "JetBrains Mono"

#let page-margins = (
  left: 1.8cm,
  right: 2.2cm,
  top: 1.7cm,
  bottom: 1.5cm,
)

#let title-page-margins = (
  left: 1.8cm,
  right: 2.2cm,
  top: 1.8cm,
  bottom: 1.5cm,
)

#let appendix-page-margins = (
  left: 1.8cm,
  right: 2.2cm,
  top: 1.5cm,
  bottom: 1.3cm,
)

#let sidebar-width = 18%
#let sidebar-gap = 1.05cm
#let content-width = 74%
#let narrow-width = 62%
#let wide-width = 80%
#let appendix-width = 84%

#let hero-size = 40pt
#let title-size = 30pt
#let subtitle-size = 20pt
#let body-size = 20pt
#let body-small-size = 15.5pt
#let code-size = 14pt
#let kicker-size = 12pt

#let panel-radius = 12pt
#let panel-inset = 20pt

#let grid-step = 8pt
#let section-gap = 24pt
#let block-gap = 32pt
#let sidebar-line-stroke = border + 0.8pt

#let deck(doc) = {
  set page(
    paper: "presentation-16-9",
    margin: page-margins,
    fill: bg,
  )

  set text(
    font: font-sans,
    size: body-size,
    fill: text-main,
    lang: "ru",
  )

  set par(
    leading: 0.65em,
    justify: false,
  )

  set list(
    marker: text(fill: accent)[•],
    indent: 1.2em,
    body-indent: 0.6em,
    spacing: 0.45em,
  )

  doc
}

#let appendix-deck(doc) = {
  set page(
    paper: "presentation-16-9",
    margin: appendix-page-margins,
    fill: bg,
  )

  set text(
    font: font-sans,
    size: 17pt,
    fill: text-main,
    lang: "ru",
  )

  set par(
    leading: 0.62em,
    justify: false,
  )

  set list(
    marker: text(fill: accent)[•],
    indent: 1.15em,
    body-indent: 0.55em,
    spacing: 0.35em,
  )

  doc
}

#let kicker(body) = text(
  size: kicker-size,
  weight: "medium",
  tracking: 0.08em,
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
  weight: "semibold",
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

#let strong(body) = text(
  weight: "semibold",
  fill: text-main,
  body,
)

#let accent-text(body) = text(
  fill: accent,
  body,
)

#let rule(length: 100%) = line(
  length: length,
  stroke: border + 0.8pt,
)

#let soft-surface(
  body,
  width: 100%,
  inset: panel-inset,
  radius: panel-radius,
) = block(
  width: width,
  fill: surface,
  stroke: border + 0.8pt,
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

#let logo-mark(
  size: 2.4cm,
  path: "../assets/nixos-logomark-rainbow-gradient-recommended.svg",
) = image(
  path,
  width: size,
  height: size,
  fit: "contain",
)
