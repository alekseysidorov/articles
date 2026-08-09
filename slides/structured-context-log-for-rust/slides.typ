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

#code-slide(
  title: [Nix как universal launcher],
  kicker: [Tooling],
  note: [
    Локально, в CI и в автоматизации без глобальной установки.
  ],
  body: [
    #rust-code(
      ```text
      log::info!("Hello world")
      ```.text,
    )
  ],
)

#hero-slide(
  kicker: [Final],
  title: [Спасибо за внимание],
  items: (
    [Telegram — \@sauron1987],
    [GitHub — github.com/alekseysidorov],
  ),
)
