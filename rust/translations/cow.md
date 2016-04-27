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

There is a way that new can accept both forms with no allocation needed in the case of a String.

Introducing Into

The standard libary has a trait Into which will help our new problem. The trait definition looks like this:

pub trait Into<T> {
    fn into(self) -> T;
}
The into function it defines is pretty straight-forward; it consumes self (the thing implementing Into) and returns a T (note the type parameter on the trait definition). Here’s how it’s used:

impl Token {
    /// Create a new token
    ///
    /// Can be passed either a &str or String
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
There’s a lot going on here. First, the function now has a generic type parameter, S. The argument raw has this type. The line reading where S: Into<String> limits the types of S to anything that implements Into<String>. Since the standard library already provides Into<String> for &str and for String, our use case is handled. 1

Although the ergonomics have been greatly improved, there’s still an issue with this API. Passing a &str to new requires an allocation to store the value as a String.

Cow to the rescue

The standard library has a type std::borrow:Cow which enables us to keep the ergonomics of the Into<String> API while also allowing for borrowed values like a &str.

Here’s the scary-looking definition of Cow:

pub enum Cow<'a, B> where B: 'a + ToOwned + ?Sized {
    Borrowed(&'a B),
    Owned(B::Owned),
}
Let’s break that down.

Cow<'a, B> has two generic parameters; a lifetime 'a, and some type B
B is constrained to 'a + ToOwned + ?Sized
'a - B cannot contain a lifetime shorter than 'a
+ ToOwned - B must implement ToOwned.
+ ?Sized - The size of B can be unknown at compile time. This isn’t relevant for our use case, but it means that trait objects may be used with the Cow type.
There’s two variants
Borrowed(&'a B) - a reference to some object of type B. The lifetime of this reference is the same as the lifetime bound.
Owned(B::Owned) - The ToOwned trait has an associated type Owned. This variant holds that type.
We want to have a Cow<'a, str>, which will look something like this after type substitution.

enum Cow<'a, str> {
    Borrowed(&'a str),
    Owned(String),
}
In short, Cow<'a, str> will be either a &str with the lifetime 'a, or it will be a String which is not bound by that lifetime. This sounds great for the Token type! It will be able to hold either a &str or a String.

struct Token<'a> {
    raw: Cow<'a, str>
}

impl<'a> Token<'a> {
    pub fn new(raw: Cow<'a, str>) -> Token<'a> {
        Token { raw: raw }
    }
}

// Create the tokens.
let token = Token::new(Cow::Borrowed("abc123"));
let secret: String = secret_from_vault("api.example.io");
let token = Token::new(Cow::Owned(secret));
A Token can now be created with either an owned or a borrowed type, but we’ve lost the API ergonomics! Into can do the same thing for our Cow<'a, str> as it did for a simple String earlier. The final Token implementation looks like this:

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

// Create the tokens.
let token = Token::new("abc123");
let token = Token::new(secret_from_vault("api.example.io"));
Now, a token can be created ergonomically from either a &str or a String. The lifetime bound on Token is no longer a problem for escaping stack frames when created with a String or &'static str; it can even be sent across threads!

let raw = String::from("abc");
let token_owned = Token::new(raw);
let token_static = Token::new("123");

thread::spawn(move || {
    println!("token_owned: {:?}", token_owned);
    println!("token_static: {:?}", token_static);
}).join().unwrap();
Trying to send a token with a non-'static ref will fail.

// Make a ref with non-'static lifetime
let raw = String::from("abc");
let s = &raw[..];
let token = Token::new(s);

// This won't work
thread::spawn(move || {
    println!("token: {:?}", token);
}).join().unwrap();
Indeed, the above example fails with

error: `raw` does not live long enough
If you’re hungry for more examples, please check out the PagerDuty API client which uses Cow extensively.

Thanks for reading!

Notes

1

If you were to go looking for the Into<String> impl for &str and String, you wouldn’t find it. This is because there’s a generic implementation of Into for types implementing From. It’s often said that From implies Into, and it’s because of this blanket impl. The whole thing looks like this

impl<T, U> Into<U> for T where U: From<T> {
    fn into(self) -> U {
        U::from(self)
    }
}
