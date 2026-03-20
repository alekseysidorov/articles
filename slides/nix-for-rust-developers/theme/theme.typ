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
  left: 2.3cm,
  right: 2.3cm,
  top: 1.6cm,
  bottom: 1.4cm,
)

#let title-page-margins = (
  left: 2.3cm,
  right: 2.3cm,
  top: 1.8cm,
  bottom: 1.5cm,
)

#let appendix-page-margins = (
  left: 2.1cm,
  right: 2.1cm,
  top: 1.4cm,
  bottom: 1.2cm,
)

#let content-width = 68%
#let narrow-width = 60%
#let wide-width = 76%
#let appendix-width = 82%

#let hero-size = 38pt
#let title-size = 28pt
#let subtitle-size = 18pt
#let body-size = 20pt
#let body-small-size = 15pt
#let code-size = 13pt
#let kicker-size = 11pt

#let panel-radius = 12pt
#let panel-inset = 18pt

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
