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

// 3. Исправить первые слайды под студентов
#hero-slide(
  title: [Log = журнал событий],
  items: (
    [Запись о событии в хронологическом порядке],
    [Исторически: судовой журнал, бортовой самописец],
    [В программе: не просто текст, а структурированная запись],
    [Хороший лог — это API для наблюдаемости],
  ),
)

#content-slide(
  title: [println! vs dbg! vs log],
  kicker: [Инструменты],
  lead: [У каждого своя задача],
  items: (
    [#strong[`println!`] — вывести текст в консоль. Быстро, просто, неструктурированно.],
    [#strong[`dbg!`] — посмотреть значение при отладке. Временно, для разработки.],
    [#strong[`log`] — оставить запись о событии. Постоянно, для production.],
  ),
)

// 4. Лестница зрелости логирования
#content-slide(
  title: [Лестница зрелости логирования],
  items: (
    [#text(gray)[0. Debug output — `println!`, `dbg!`]],
    [1. Text logs — строка события],
    [2. Leveled logs — `level` + `target`],
    [3. Structured logs — `event` + `fields`],
    [4. Contextual logs — `event` + `fields` + `context`],
    [#text(size: 0.8em, fill: gray)[*Tracing — это другой путь...*]]
  ),
)

// 5. Использовать один сквозной пример
#code-slide(
  title: [Уровень 1-2: Leveled Text Logs],
  kicker: [Пример],
  body: [
    #rust-code(
      ```rust
      log::info!(
        "request finished for user {}",
        42,
      );
      ```.text,
    )
    #bash-code(
      ```log
      INFO main: request finished for user 42
      ```.text,
    )
  ],
  note: [Просто, но сложно парсить и фильтровать.],
)

#code-slide(
  title: [Уровень 3: Structured Logs],
  kicker: [Пример],
  body: [
    #rust-code(
      ```rust
      log::info!(
        user_id = 42, status = 200;
        "request finished",
      );
      ```.text,
    )
    #bash-code(
      ```logfmt
      msg="request finished" level=INFO user_id=42 status=200
      ```.text,
    )
  ],
  note: [Уже можно делать выборки по полям. Но где `request_id`?],
)

#code-slide(
  title: [Уровень 4: Contextual Logs],
  kicker: [Пример],
  body: [
    #rust-code(
      ```rust
      // где-то в middleware
      with_context(request_id, || {
        // ... глубоко внутри
        log::info!(
          status = 200;
          "request finished"
        );
      });
      ```.text,
    )
    #bash-code(
      ```logfmt
      msg="request finished" level=INFO status=200 request_id="req-123"
      ```.text,
    )
  ],
  note: [Контекст добавляется неявно, код остаётся чистым.],
)

// 6. Ecosystem overview
#hero-slide(
  kicker: [Ecosystem],
  title: [Ключевые игроки],
  items: (
    [#strong[slog] — контекст внутри `Logger`],
    [#strong[tracing] — контекст внутри `Span`],
    [#strong[log] — фасад, где не хватало контекста],
  ),
)

// 7. slog slide
#content-slide(
  kicker: [slog],
  title: [Контекст в логгере],
  lead: [slog первым предложил хороший API для контекста, но сделал его частью логгера.],
  items: (
    [Структурное key-value логирование],
    [`Logger` носит с собой контекст],
    [Дочерний `Logger` наследует поля],
    [Цена: явная передача `Logger` в каждую функцию],
    [
          #rust-code(
            ```rust
            // Logger passed as an argument
            fn validate(log: &slog::Logger, ...) {
              info!(log, "validating request");
            }
            ```.text
          )
        ],
    [#strong["Хорошая идея. Инвазивная форма."]]
  ),
)

// 8. tracing slide
#content-slide(
  kicker: [tracing],
  title: [Не только логирование],
  lead: [tracing решает более широкую задачу — распределённую трассировку.],
  items: (
    [`Event` — событие в момент времени],
    [`Span` — интервал выполнения со своими полями],
    [Строит дерево выполнения (execution tree)],
    [Модель может быть избыточной, если нужен только контекст для логов],
    [#strong["Мощный инструмент для телеметрии, но не всегда замена простому логированию."]]
  ),
)

// 9. log slide
#hero-slide(
  kicker: [log],
  title: [Общий язык Rust-библиотек],
  items: (
    [Фасад, а не реализация],
    [Библиотека создаёт `log::Record`],
    [Приложение выбирает, как его обработать],
    [`kv_unstable` API добавляет поля, но не контекст],
    [#strong[Недостающее звено: неявный scoped-контекст]],
  ),
)

// 10. context-logger positioning
#content-slide(
  title: [Идея: контекст вокруг `log::Record`],
  items: (
    [#align(center)[#box(stroke: 1pt, inset: 1em)[`обычный log::Record`]]],
    [#align(center)[#text(2em)[+]]],
    [#align(center)[#box(stroke: 1pt, inset: 1em)[`стек текущего контекста`]]],
    [#align(center)[#text(2em)[=]]],
    [#align(center)[#box(fill: aqua.lighten(80%), stroke: 1pt, inset: 1em)[`обогащённый log::Record`]]],
  ),
)

#code-slide(
  title: [Контекст даже для чужих логов],
  body: [
    #columns(2, gutter: 2em)[
      #rust-code(
        ```rust
        // Код в чужой библиотеке
        fn third_party_lib() {
          log::info!("profile loaded");
        }

        // Код в нашем приложении
        with_context(request_id, || {
          third_party_lib();
        });
        ```.text,
      )
      #bash-code(
        ```json
        {
          "msg": "profile loaded",
          "request_id": "req-123"
        }
        ```.text,
      )
    ]
  ],
  note: [Библиотека ничего не знает о `request_id`, но он появляется в логе.],
)

#hero-slide(
  title: [Не новая экосистема],
  kicker: [context-logger],
  items: (
    [`log` остаётся `log`],
    [Ваш backend остаётся вашим backend],
    [Библиотеки не требуют изменений],
    [Контекст добавляется снаружи, прозрачно для кода],
  ),
)

// 11. Demo transition slide
#hero-slide(
  title: [Live demo: что внутри],
  items: (
    [Обёртка над `log::Log`],
    [Асинхронно-локальный стек контекстов],
    [Наследуемые и локальные поля],
    [Прокидывание контекста через `.await`],
    [Как чужой `log::info!` получает наш контекст],
  ),
)

// 12. Final slide
#hero-slide(
  kicker: [Final thought],
  title: [If `log` is the common language of Rust libraries, `context-logger` adds scope to that language.],
  items: (
    [Telegram — \@sauron1987],
    [GitHub — github.com/alekseysidorov],
  ),
)
