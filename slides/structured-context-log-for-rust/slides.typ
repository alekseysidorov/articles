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
    [#strong[`println!`] - это просто вывод произвольной],
    [#strong[`dbg!`] - это печать отладочной информации в процессе разработки. В релизной ветке, его не должно быть],
    [#strong[`log!`] - это журналирование событий. Лог должен иметь обязательные поля],
  ),
)

#code-slide(
  title: [Уровень зрелости логов - println],
  kicker: [println],
  note: [Простой неструктурированный текст как есть без временных меток],
  body: [
    #rust-code(
      ```text
      println!("Request finished for user: {user}");
      ```.text,
    )
    #raw-code(
      ```text
      Request finished for user: aleksey
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
      log::info!("Request finished for user: {user}");
      ```.text,
    )
    #bash-code(
      ```text
      [2026-08-11T19:38:35Z INFO  main] Request finished for user: aleksey
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
      log::info!(user = "aleksey"; "Request finished for user");
      ```.text,
    )
    #bash-code(
      ```text
      [2026-08-11T19:38:35Z INFO  main] Request finished for user: user=aleksey
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
      log::info!(user = "aleksey"; "Request finished for user");
      ```.text,
    )
    #json-code(
      ```text
      {
        "timestamp":1786477876240, "user":"aleksey",
        "message":"Request finished for user"
      }
      ```.text,
    )
  ],
)

#hero-slide(
  kicker: [Ecosystem],
  title: [Обзор экосистемы],
  items: (
    [#strong[`slog`] - структурное и контекстное логирование],
    [#strong[`tracing`] - фреймворк логирования и трассировки от tokio],
    [#strong[`log`] - стандартный фасад для логирования]
  ),
)

#content-slide(
  kicker: [Ecosystem],
  title: [Обзор экосистемы - slog],
  lead: [Старая попытка создать контекстное логирование ],
  items: (
    [Поддерживает структурное и контекстное логирование],
    [Logger явно передается в качестве аргумента],
    [Авторы сами рекомендуют перейти tracing],
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
    [Поддерживает структурное логирование, если включить #strong[`kv`] feature],
    [Повсеместно распространен],
    [Не поддерживает контекстное логирование],
  ),
)

#hero-slide(
  kicker: [context-logger],
  title: [Добавляем контекстное логирование в log],
)

#code-slide(
  title: [Обертка над log],
  kicker: [log],
  note: [Оборачиваем logger, превращая его в контекстный],
  body: [
    #rust-code(
      ```text
      use structured_logger::Builder;

      let level = log::LevelFilter::Info;
      let inner = Builder::default().build();

      ContextLogger::new(inner).init(level);
      ```.text,
    )
  ],
)

#code-slide(
  title: [Базовый пример],
  kicker: [sync],
  note: [Вывод лога будет содержать поля `example` и `user_id`],
  body: [
    #rust-code(
      ```text
      let log_context = LogContext::new()
          .with_inherited_field("example", "sync" )
          .with_local_field    ("user_id", "12345");

      log_context.in_scope(|| {
          log::info!("Logging in");
      });
      ```.text,
    )

  ],
)

#code-slide(
  title: [Асинхронный пример],
  kicker: [async],
  note: [Вывод лога будет содержать поля `thread` и `name`],
  body: [
    #rust-code(
      ```text
      let log_context = LogContext::new()
          .with_inherited_field("thread", "main" )
          .with_local_field    ("name"  , "Alice")

      async move { log::info!("Logging in"); }
        .in_log_context(log_context)
        .await
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

#qr-slide(
  kicker: [Repo],
  title: [context-logger],
  link: [github.com/alekseysidorov/context-logger],
  qr: read("assets/qr-context-logger.png", encoding: none),
  qr-size: 6cm,
)
