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
  title: [Что же такое лог],
  items: (
    [Судовой журнал - исторический пример лога из жизни],
    [Журнал посещений - кто зашел, кто вышел],
    [Лог — это запись о событии программы],
    [Должны проектироваться как API]
  ),
)

#content-slide(
  kicker: [Tooling],
  title: [В чем отличие от println! или dbg!],
  lead: [
    Разница прежде всего в намерении
  ],
  items: (
    [`println` - это просто вывод произвольной],
    [`dbg` - это печать отладочной информации в процессе разработки. В релизной ветке, его не должно быть],
    [`log` - это журналирование событий. Лог должен иметь обязательные поля],
  ),
)

#code-slide(
  title: [Уровень зрелости логов - println],
  kicker: [println],
  note: [Просто не структурированный текст как есть без временных меток],
  body: [
    #rust-code(
      ```text
      println!("Something happened");
      ```.text,
    )
    #bash-code(
      ```text
      Something happened
      ```.text,
    )
  ],
)

#code-slide(
  title: [Уровень зрелости логов - текстовые],
  kicker: [текст],
  note: [Текстовые логи с временными метками без полей],
  body: [
    #rust-code(
      ```text
      log::info!("Something happened");
      ```.text,
    )
    #bash-code(
      ```text
      [2026-08-11T19:38:35Z INFO  main] Something happened
      ```.text,
    )
  ],
)

#code-slide(
  title: [Уровень зрелости логов - структурные],
  kicker: [структура],
  note: [Логи, где каждое событие - это полноценный объект],
  body: [
    #rust-code(
      ```text
      log::info!(answer = 42; "Something happened");
      ```.text,
    )
    #bash-code(
      ```text
      [2026-08-11T19:38:35Z INFO  main] Something happened answer=42
      ```.text,
    )
  ],
)

#code-slide(
  title: [Уровень зрелости логов - контекстные],
  kicker: [контекст],
  note: [Помимо явно указанных полей, добавляются еще поля из контекста],
  body: [
    #rust-code(
      ```text
      log::info!(answer = 42; "Something happened");
      ```.text,
    )
    #json-code(
      ```text
      {
        "timestamp":1786477876240, "user":"aleksey",
        "answer":42, "message":"Something happened"
      }
      ```.text,
    )
  ],
)

#hero-slide(
  kicker: [Ecosystem],
  title: [Обзор экосистемы],
  items: (
    [slog - структурное и контекстное логирование],
    [tracing - фреймворк логирования и трассировки от tokio],
    [log - де-факто стандартный фреймворк для логирования]
  ),
)

#content-slide(
  kicker: [Ecosystem],
  title: [Обзор экосистемы - slog],
  lead: [Очень старая попытка создать контекстное логирование ],
  items: (
    [Поддерживает структурное и контекстное логирование],
    [Logger явно передается в качестве аргумента],
    [Признан устаревшим - авторы рекомендуют tracing],
    [
      #rust-code(
        ```text
        let log = root.new(o!("child" => 1));
        info!(log, "subthread"; "stage" => "start");
        ```.text,
      )
    ]
  ),
)

#content-slide(
  kicker: [Ecosystem],
  title: [Обзор экосистемы - tracing],
  lead: [Популярный фреймворк от создателей tokio],
  items: (
    [Поддерживает структурное и контекстное логирование],
    [Является фреймворком для distributed tracing],
    [Используется активно],
    [Имеет ряд особенностей и недостатков]
  ),
)

#content-slide(
  kicker: [Ecosystem],
  title: [Недостатки tracing],
  items: (
    [Смешивает логирование и трассировку],
    [Структурное логирование сложных объектов - unstable],
    [Не поддерживает динамическое добавление полей в логах],
    [Использует свой синтаксис макросов, не совпадающий с `log`]
  ),
)

#content-slide(
  kicker: [Ecosystem],
  title: [Обзор экосистемы - log],
  lead: [Фактически, стандартная экосистема логирования],
  items: (
    [Поддерживает структурное логирование, если включить `kv` feature],
    [Повсеместно распространен],
    [Не поддерживает контекстное логирование],
  ),
)

#hero-slide(
  kicker: [context-logger],
  title: [Добавляем контекстное логирование в log],
)


#hero-slide(
  kicker: [Final],
  title: [Спасибо за внимание],
  items: (
    [Telegram — \@sauron1987],
    [GitHub — github.com/alekseysidorov],
  ),
)
