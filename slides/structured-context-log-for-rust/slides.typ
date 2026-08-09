#import "theme/theme.typ": *
#import "theme/components.typ": *

#show: deck

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN DECK — короткий доклад, быстрый выход в live demo
// ═══════════════════════════════════════════════════════════════════════════════

#title-slide(
  title: [Добавляем контекст в log::info!],
  subtitle: [Контекстное логирование без смены экосистемы],
  author: [Алексей Сидоров · Ведущий Rust-разработчик],
  year: [2026],
)

#hero-slide(
  kicker: [Thesis],
  title: [У проекта должен быть один источник правды.],
  note: [
    Проблема обычно уже не в коде.
    Проблема в среде вокруг него.
  ],
)

#content-slide(
  kicker: [Problem],
  title: [Проект живёт сразу в нескольких описаниях],
  lead: [
    `Cargo.toml` — это только часть картины. Остальное быстро расходится.
  ],
  items: (
    [`Cargo.toml` знает только про crates],
    [toolchain, system deps и scripts — отдельно],
    [CI часто проверяет не то же самое, что запускаете локально],
  ),
)

#hero-slide(
  kicker: [Final],
  title: [Спасибо за внимание],
  items: (
    [Telegram — \@sauron1987],
    [GitHub — github.com/alekseysidorov],
  ),
)
