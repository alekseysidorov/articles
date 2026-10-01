# От println! до контекстного структурного логирования

Алексей Сидоров · Ведущий Rust-разработчик

----

## Что такое log — наивный взгляд

Слово **log** исторически означает **журнал записей**.

- Судовой журнал: корабль плывёт, команда записывает, что произошло
- Журнал дежурств: кто зашёл, когда вышел
- Операционная система ведёт лог — запись о том, что произошло

В программе **log — это запись о событии**.

Не «вывод в консоль». Не «текст». А именно журнал.

```rust
log::info!("server started");
log::warn!("config missing, using defaults");
log::error!("request failed");
```

Каждая строка — событие программы, оставленное для наблюдения.

----

## Отличие от println! и dbg!

**println!** отвечает на вопрос: «что вывести прямо сейчас?»

Это вывод текста. Не журнал событий.

**dbg!** — это стикер разработчика на полях кода: «я хочу посмотреть значение выражения».

Временная отладка. Не часть контракта системы.

```
println!  = вывести текст
dbg!      = посмотреть значение
log       = записать событие
```

Это разные инструменты с разной семантикой, хотя синтаксиса похожи.

----

## Лестница зрелости логирования

```
5. traces / execution tree
4. contextual structured logs  ← здесь мы хотим быть
3. structured logs            ← поля вместо строки
2. leveled logs               ← уровни важности
1. plain text logs            ← текст с уровнем
0. println debugging          ← просто строки
```

Это не про «старое плохо, новое хорошо». Это про семантику записей.

Наша цель — шаг 4: контекстные поля + структурированные события.

----

## Уровень 1: plain text logs

Используем log-facade, но пишем текст:

```rust
log::info!("request finished for user {}", user_id);
```

Вывод: `INFO my_service::http: request finished for user 42`

Стало лучше — появился уровень. Но данные спрятаны внутри строки.

Хотим найти все события для `user_id = 42`? Придётся парсить текст.
Построить агрегацию по status? Нужно договориться о формате строки.

Для человека это одно и то же:
```
request finished for user 42 with status 200
request finished: user=42 status=200
finished request, status: 200, user_id: 42
```

Для машины — три разных формата.

----

## Уровень 2: leveled logs

Уровни дают первую ось классификации:

```rust
log::trace!("polling socket");
log::debug!("cache miss");
log::info!("request finished");
log::warn!("retrying failed request");
log::error!("failed to save result");
```

Теперь можно сказать: в dev покажи debug, в prod — info.
Но level — это только важность. Не структура.

`log::info!("status={}", status)` — всё ещё строка.

----

## Уровень 3: structured logs

Следующий шаг: лог — не строка, а событие с полями:

```rust
log::info!(
    user_id = user_id,
    status = status;
     "request finished"
);
```

JSON-вывод:
```json
{
  "level": "INFO",
  "message": "request finished",
  "user_id": 42,
  "status": 200
}
```

**Message = имя события. Fields = аргументы события.**

Лог становится API — не для другого Rust-кода, а для системы наблюдаемости.

Ищешь `status = 500`? Агрегируешь `count by status`? Индексируешь `user_id`?
Больше не задача для regex — данные сами по себе.

Меняешь текст сообщения — не ломаешь downstream-потребителей.

----

## log: facade для библиотек

В Rust **log** — это фасад, а не полноценный фреймворк.

Документация говорит: *предоставляет единый API, абстрагируясь от конкретной реализации*.
Библиотеки пишут `log::debug!`, а приложение выбирает backend.

Это важно для библиотек:
- Библиотека решает: `log::info!("parsed input")`
- Приложение решает: stdout? файл? journald? JSON? Loki? OpenTelemetry?
- API библиотеки не меняется от выбора логгера

Современный log с feature `kv` умеет и structured logging.
Changelog 0.4.21 содержит пункт «Get structured logging API ready for stabilization».

**log даёт нам:** facade, уровни, targets, структурированные поля.
**Ему не хватает:** scoped контекст для полей.

----

## Проблема: контекст — это не аргумент события

В handler-е у нас много событий с общим контекстом:

```rust
let request_id = ...;
let user_id    = ...;

log::info!(user_id, "validating input");     // request_id тоже нужен
log::info!(user_id, "loading profile");      // request_id тоже нужен  
log::info!(status = 200, user_id, "finished"); // request_id тоже нужен
```

`request_id`, `tenant_id` — это **не аргументы конкретных событий**.
Это **контекст области выполнения**.

Хорошая формула:
```
event fields    = данные конкретного события
context fields  = данные области выполнения
```

Без механизма контекста мы вынуждены повторять поля вручную в каждом вызове.
Когда одно и то же надо копипастить 20 раз, появляются разночтения:
`request_id`, `req_id`, `rid`, `request` — для поискового индекса это разные поля.

----

## Уровень 4: contextual structured logs

Хочется:
```rust
let _scope = context::scope()
    .field("request_id", request_id)
    .field("user_id", user_id)
    .enter();

log::info!("validating input");
log::info!("loading profile");
log::info!(status = 200; "request finished");
```

И получить:
```json
{ "message": "validating input", "request_id": "req-123", "user_id": 42 }
{ "message": "loading profile", "request_id": "req-123", "user_id": 42 }
{ "message": "request finished", "request_id": "req-123", "user_id": 42, "status": 200 }
```

Локальные поля события + контекстные поля области = один enriched record.

**Можно добавить контекст даже в чужие логи**, если они используют `log::`.
Библиотека не знает о context-logger — она просто пишет `log::debug!()`.

----

## Как это решали раньше: slog

В slog контекст живёт в Logger:

```rust
let root = slog::Logger::root(drain, o!("service" => "billing"));
let request_log = root.new(o!("request_id" => "req-123", "user_id" => 42));

info!(request_log, "validating input");
info!(request_log, "loading profile");
```

Модель рабочая: `Logger = sink + context`.
Но Logger становится частью API.

Слог «заражает» код своим Logger:
```rust
fn validate(log: &slog::Logger, req: &Request) { ... }
fn load(log: &slog::Logger, user_id: UserId) { ... }
```

Для приложения — нормально. Для библиотеки — плохо:
- public API зависит от slog
- пользователь теряет свободу выбора backend
- логирование протекает в domain-сигнатуры

**slog решает контекст ценой Logger propagation.**

----

## А как это решает tracing?

tracing вводит **events** и **spans**:

```rust
let span = info_span!("handle_request", request_id, user_id);
let _guard = span.enter();

info!("validating input");
info!(status = 200, "request finished");
```

Семантика:
- **event** — момент времени (сравнимо с log record)
- **span** — период выполнения с begin/end, parent/child отношениями

tracing отвечает на вопрос: *как восстановить поток выполнения программы?*

Это мощно, но более общая задача. Иногда нужна меньшая абстракция:
- не нужен trace tree
- уже есть log-based экосистема
- не хочу менять API чужих библиотек
- нужны только scoped fields для log records

**tracing — это instrumentation model для execution flow.**
**Ему хочется одну идею от него: scoped context — но только для логов.**

----

## Три модели контекста

```
slog:        context lives in Logger
             cost: Logger propagation through APIs

tracing:     context lives in Span
             cost: adopt tracing instrumentation model

context-logger: context lives around log::Record
                cost: install wrapper / logger layer
```

**slog** говорит: «хочешь контекст — создай Logger и передавай дальше»
**context-logger** говорит: «оставь функцию как есть, контекст придёт извне»

Для библиотек это принципиально: они просто пишут `log::info!()`.

----

## Что такое context-logger

Маленький слой для существующей log-экосистемы:

1. Берёт текущий scoped context
2. Добавляет его к обычным log records как structured fields
3. Работает с любым logger-ом, реализующим standard Log trait

```rust
fn handle_request(req: Request) {
    let _scope = context_logger::scope()
        .field("request_id", req.id)
        .field("user_id", req.user_id)
        .enter();

    log::info!("validating input");  // обычный log
    auth::validate(&req);             // тоже через log
}
```

Внутри `auth::validate` — чужой код с `log::debug!()`.
Он получает контекст без изменений в API.

**Это не новый логгер. Это недостающий слой контекста для существующего log facade.**

----

## Итог

- **Log** = журнал событий программы, а не просто вывод текста
- **Structured logs** превращают запись в данные для поиска и агрегации
- **Contextual logs** убирают повторение полей области выполнения
- **slog** решает контекст ценой Logger propagation
- **tracing** решает больше: execution tree через spans
- **context-logger** добавляет scoped context существующему log facade

```
Not a new logging ecosystem.
A context layer for the existing one.
```

Если `log` — общий язык Rust-библиотек, то context-logger добавляет к этому языку область видимости.

----

## Спасибо за внимание!

Telegram: @sauron1987
GitHub: github.com/alekseysidorov

Попробовать live demo — поехали.
