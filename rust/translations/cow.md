---
title: "От &str к Cow"
categories:обучение
published: true
author: James Lucas (перевел Алексей Сидоров)
excerpt:
    *Эта статья – перевод статьи
    [From &str to Cow](http://blog.jwilm.io/from-str-to-cow)
    за авторством Joe Wilm*

---

*Эта статья – перевод статьи

### От &str к Cow

В одним из первых моих кодов на Rust'е была структура с &str полем. Как вы понимаете, borrow checker не дал сделать мне множество вещей и выразительность API была ограниченой. Эта статья нацелена на демонстрацию проблем, возникающих при хранении сырых &str ссылок в полях структур и показывает некоторое промежуточные API, которые улучшают удобство, но при этом недостаточно эффективны и в конце будет представлена реализация, которая одновременно обладает выразительностью и хорошей эффективностью.

Скажем мы делаем библиотеку для example.com API. Каждый вызов API должен быть подписан токеном. 
Определение токена может выглядить примерно так:

```rust
/// Token для example.io API
pub struct Token<'a> {
    raw: &'a str,
}
```

И должно быть существует метод для создания токена из &str.

```rust
impl<'a> Token<'a> {
    pub fn new(raw: &'a str) -> Token<'a> {
        Token { raw: raw }
    }
}
```

Такой токен работает хорошо лишь для &'static str. Однако, что если пользователь не захочет встраивать свой секретный ключ в бинарник? Быть может ключ загрузили из хранилища в процессе выполнения. Мы могли бы захотеть писать скорее такой код.
```rust
/// Imagine that this function exists
let secret: String = secret_from_vault("api.example.io");
let token = Token::new(&secret[..]);
```

Эта реализация имеет большое ограничение: токен не может пережить секретный ключ и это значит, что токен не может быть извлечен из стека. Что если просто токен будет удерживать String? Это могло бы избавить от указания параметра времени жизни, сделав Token чисто собственным(owned) типом.

Token и его new функция выглядит так после внесения изменений.

```rust
struct Token {
    raw: String,
}

impl Token {
    pub fn new(raw: String) -> Token {
        Token { raw: raw }
    }
}
```

Те места, где используется String должны быть исправлены.

The use case where a String is provided has been fixed.

```rust
// Это работает сейчас
let token = Token::new(secret_from_vault("api.example.io"))
```
Однако это вредит удобству использования &'str. К примеру, это не будет компилироваться:
```rust
// не собирается
let token = Token::new("abc123");
```
Пользователь этого API должен явным образом преобразовать &'str в String.
```rust
let token = Token::new(String::from("abc123"));
```
Можно использовать &str вместо String, срятав String::from в реализацию, однако в случае String это будет менее удобно и потребует дополнительного выделения памяти в куче. Давайте посмотрим как это выглядит. 

```rust
// функция new выглядит как-то так
impl Token {
    pub fn new(raw: &str) -> Token {
        Token(String::from(raw))
    }
}

// &str может передана бесшовно
let token = Token::new("abc123");

// По прежднему можно использовать String, но необходимо пользоваться срезами
// и функция new должна будет скопировать данные из них
let secret = secret_from_vault("api.example.io");
let token = Token::new(&secret[..]); // неэффективно!
```

Существует способ, как заставить new принимать обе формы без необходимости в выделении памяти в случае String.

#### Представляем Into

В стандартной библиотеке существует типаж Into, который поможет решит нашу проблему с new. Определение типажа выглядит так:

```rust
pub trait Into<T> {
    fn into(self) -> T;
}
```
Функция into определяется довольно просто: она забирает self (нечто, реализующее Into) и возвращает T(параметр типа в определении типажа). Здесь показано как это использовать:

```rust
impl Token {
    /// Создание нового токена
    ///
    /// Может принимать как &str так и String
    pub fn new<S>(raw: S) -> Token
        where S: Into<String>
    {
        Token { raw: raw.into() }
    }
}

// &str
let token = Token::new("abc123");

// String
let token = Token::new(secret_from_vault("api.example.io"));
```
Здесь много чего происходит. Во первых, функция сейчас имеет обобщеный параметр S. Аргумент row имеет данный тип. 
Строчка where S: Into<String> ограничивает возможные типы S до тех, которые реализуют Into<String>. Поскольку стандартная библиотека уже предоставляет Into<String> для &str и String наш случай обрабатывается.

Хотя удобство было значительно улучшено, в данном API до сих пор присутствует изъян. Передача &str в new требует выделения памяти для хранения значения как String

### Cow для спасения

В стандартной библиотеке есть тип std::borrow::Cow, который позволяет нам сохранив удобство Into<String> API также разрешая владеть значениями типа &str.

Вот страшно выглядящее определение Cow:

```rust
pub enum Cow<'a, B> where B: 'a + ToOwned + ?Sized {
    Borrowed(&'a B),
    Owned(B::Owned),
}
```

Давайте разберемся.

Cow<'a, B> имеет два обобщенных параметра: время жизни 'a и некоторый тип B, который ограничен до 'a + ToOwned + ?Sized.

 * 'a - B не может иметь время жизни короче, чем 'a
 * ToOwned - B должен реализовывать типаж ToOwned
 * ?Sized - Размер типа B может быть неизвестен во время компиляции. Это не имеет значения в нашем случае, но это означает, что trait object'ы могут использоваться вместе с Cow.

Существует два варианта значения. (? как бы это по русски записать?)
* Borrowed(&'a B) - ссылка на некоторый объект типа B. Время жизни этой ссылки такое же как время жизни связанного значения.
* Owned(B::Owned) - ToOwned типаж имеет ассоциированный типа Owned. Этот вариант сохраняет этот тип. 
Мы же хотим иметь Cow<'a, str>, который бы выглядил примерно так после подстановки типа:

```rust
enum Cow<'a, str> {
    Borrowed(&'a str),
    Owned(String),
}
```

Короче говоря Cow<'a, str> будет либо &str с временем жизни 'a либо он будет представлять собой String, который не связян с этим временем жизни. Это звучит круто для нашего Token'а. Он будет иметь возможность хранить как &str, так и String.

```rust
struct Token<'a> {
    raw: Cow<'a, str>
}

impl<'a> Token<'a> {
    pub fn new(raw: Cow<'a, str>) -> Token<'a> {
        Token { raw: raw }
    }
}

// создание этих токенов
let token = Token::new(Cow::Borrowed("abc123"));
let secret: String = secret_from_vault("api.example.io");
let token = Token::new(Cow::Owned(secret));
```

Теперь Token может быть создан с помощью заимствованного(borrowed) или собственного(owned) типа, но мы потеряли эргономичность API. Into может сделать такие же улучшения для нашего Cow<'a, str>, как сделал для простого String ранее. Финальная реализация Token'а выглядит так:

```rust
struct Token<'a> {
    raw: Cow<'a, str>
}

impl<'a> Token<'a> {
    pub fn new<S>(raw: S) -> Token<'a>
        where S: Into<Cow<'a, str>>
    {
        Token { raw: raw.into() }
    }
}

// создаем токены.
let token = Token::new("abc123");
let token = Token::new(secret_from_vault("api.example.io"));
```

Теперь токен может быть прозрачно создан как из &str так и из String. Связанное с Token'ом время жизни больше не проблема для 
for escaping stack frames when created with a String or &'static str. Можно даже пересылать Token между потоками!

```rust
let raw = String::from("abc");
let token_owned = Token::new(raw);
let token_static = Token::new("123");

thread::spawn(move || {
    println!("token_owned: {:?}", token_owned);
    println!("token_static: {:?}", token_static);
}).join().unwrap();
```
Попытка отправить токен с нестатической ссылкой потерпит неудачу.
```rust
// Сделаем ссылку с нестатическим временем жизни
let raw = String::from("abc");
let s = &raw[..];
let token = Token::new(s);

// Это не будет работать
thread::spawn(move || {
    println!("token: {:?}", token);
}).join().unwrap();
```

Действительно, пример выше не компилируется с ошибкой:
```
error: `raw` does not live long enough
```
Если вы жаждите больше примеров, пожалуйста, посмотрите на PagerDuty API client, который интенсивно использует Cow.

Спасибо за чтение!

Примечания

1

Если вы пойдете искать реализации Into<String> для &str и String, вы не найдете их. Это потому, что существует общая реализация Into для типов, реализующих типаж From. Часто говорят, что From реализует Into and it’s because of this blanket impl. Всё это выглядит следующим образом.

```rust
impl<T, U> Into<U> for T where U: From<T> {
    fn into(self) -> U {
        U::from(self)
    }
}
```
