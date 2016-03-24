---
title: "Машинное обучение в Rust"
categories:обзор
published: true
author: James Lucas (перевел Алексей Сидоров)
excerpt:
    *Эта статья – перевод статьи
    [Machine Learning in Rust](https://athemathmo.github.io/2016/03/07/rusty-machine.html#lets-talk-about-a-machine-learning-problem)
    за авторством James Lucas*

---

*Эта статья – перевод статьи

### Машинное обучение в Rust

Этот пост ориентирован на читателей, которые знакомы с Rust'ом и хотят получить некоторое представление о том, почему он очень хорош для машинного обучения

 * [Проблемы машинного обучения](#Давайте-поговорим-о-проблемах-машинного-обучения)
 * Почему машинное обучение такое трудное?
 * Что такое rusty machine?
 * Что дальше?
 * Краткий взгляд на другие проекты сообщества
 
В статье я подниму конкретную проблему которая может быть решена с помощью машинного обучения и расскажу (кратко) опишу одно решение. Она является учебным пособием по данной методике, но вместе с тем она дает некоторое понимание того, почему машинное обучение такое сложное. 

После чего я кратко расскажу о работе, которую я проделал на rusty-machine. Rusty-machine это библиотека машинного обучения общего назначения реализованная полностью на Rust'е. Эту статью я проиллюстрирую примерами некоторых сильных сторон rusty-machine. Это ни в коем случае не полностью законченная статья, я планирую более детально охватить работу rusty-machine в своих будующих статях.

Я буду рад получить отзывы как о статье, так и о библиотеке.

Замечание: Я планирую написать статью в таком же духе для тех, кто не так хорошо знакомы с Rust'ом. 

### Давайте поговорим о проблемах машинного обучения ##

Если вы знакомы с машинным обучением, то можете пропустить этот раздел и сразу перейти к расскажу о rusty-machine.

Мы рассмотрим проблему классификации того, является ли опухоль злокачественной или доброкачественной. Врачи используют различные меры классификации опухолей, для примера их можно различать по размеру, симметричности, компактности и т.д.
Используя эти меры врачи хотят определить является ли опухоль доброкачественной или злокачественной так, как это определяет наилучшую последовательность действий.

Эту проблему мы можем разрешить с помощью машинного обучения.

"Область исследования, что дает компьютерам способность учиться, не будучи явно запрограммированными." - [Артур Сэмюэл](https://ru.wikipedia.org/wiki/%D0%A1%D1%8D%D0%BC%D1%8E%D1%8D%D0%BB,_%D0%90%D1%80%D1%82%D1%83%D1%80)

Существует множество различных инструментов машинного обучения, которые мы могли бы использовать для решения этой проблемы. Мы предлагаем один из них - логистическую регрессию.

Базовая идея логистической регрессии заключается в том, что мы берем взвешенную сумму признаков опухоли и затем нормируем её в пределах от 0 до 1 так, чтобы мы могли рассматривать её как вероятность того, что опухоль злокачественная. В качестве примера мы имеем измерения для объема и среднего радиуса опухолей (обозначим их x1 и x2 соответственно). 
Пусть β является вектором весовых параметров, тогда наша взвешенная сумма будет вычисляться по формуле:

xTβ = β0 + β1x1 + β2x2.

Вектор β формирует параметры модели логистической регрессии. Обратите внимание, что здесь мы добавили x0 = 1 к нашим признакам. Это обычная практика используется для моделирования свободного члена. Этот метод, который мы используем для масштабирования нашей взвешенной суммы модели логистической регрессии, получил свое имя - логистическая функция.

Логистическая функция

Чтобы решить будь то опухоль злокачественная или нет мы рассчитываем h(xTβ). Она покажет нам вероятность того, что опухоль злокачественная (если вероятность больше 0.5, то опухоль, скорее всего, злокачественная)

Это всё прекрасно, но мы ещё не учимся. Идея логистической регрессии в том, что вы можем узнать, что вектор β должен быть основан на некоторой обучающей выборке. Этот процесс известен как тренировка модели. В общем случае это делается через метод градиентного спуска. Это включает определение весовой функции и поиск параметров, которые минимизируют её вес. 

Почему машинное обучение сложно?

Как я уже говорил выше существует множество различных методик, которые мы можем использовать для классификации опухолей. Даже если мы выбрали бы технику, существует множество других тонкостей. Какой алгоритм мы используем для тренировки модели? Как мы строим нашу весовую функцию? Как мы выбираем лучшее подмножество данных, которое отражает нашу проблему?

Машинное обучение сталкивается с ещё одним вызовом, который связан с предыдущими. Мы довольно часто работает с огромными объемами данных, которые заставляют нашу модель тренироваться очень долгое время. Мы нуждаемся в инструментах, которые улучшат производительность без потери гибкости, необходимой для изучения всех различных вариантов, связаных даже с одной единственной моделью.

Rusty-machine это попытка решить эту проблему. Благодаря использованию высокопроизводительных и высокоуровневых возможностей мы стремимся создать фреймворок для инеративной разработки и скорости.

Немного терминологии

Прежде чем запрыгнуть в "ржавую машину"(rusty-machine) нам нужна некоторая терминология.

В машинном обучение мы имеем модели. Эти модели могут использоваться для разъяснения паттернов, которые присутствуют в некоторых данных. 

In Machine Learning we have Models. These models can be used to explain a pattern which is present in some data. The Logistic Regression model is an example of this. By giving the model some data we can train it and have it learn the underlying pattern. The model can then be used to predict new patterns from data that it hasn’t seen before.

The key take-aways are:

Model : An object representing a set of possible explanations for some data patterns.
Train : The act of teaching a model the best explanation from some data (learning).
Predict : Using the learned model to predict the pattern of unseen data.

Rusty-machine

Rusty-machine is a general purpose machine learning library. Implemented entirely in Rust. It is still very much in the early stages of development and so the following information is likely to be outdated in the future. I hope to provide an overview of what rusty-machine is trying to achieve.

Rusty-machine aims to provide a consistent, high-level API for users without compromising performance. This consistency is achieved through Rust’s trait system.

A consistent API

By using traits we allow users to easily implement a model with clean access to the necessary parts. We hope that we can provide the foundation of each model and make it easy for the user to choose how the learning problem is solved. This could involve choosing from a common set of techniques or alternatively plugging their own tools in. This is in contrast to some (very good) libraries which provide their flexibility through bloated APIs.

```rust
/// Trait for supervised models.
pub trait SupModel<T,U> {

    /// Train the model using inputs and targets.
    fn train(&mut self, inputs: &T, targets: &U);

    /// Predict output from inputs.
    fn predict(&self, inputs: &T) -> U;
}
```

The above is the trait for a specific type of model - a Supervised model. This means that the model is trained using some example outputs (called targets) as well as the inputs. There is also a trait for UnSupervised models which looks very similar (except that we do not have any targets).

When a user wants to use a model they train and predict from the model via this trait. This is the essence of our consistent API - all models are accessed via the same core methods. We balance this rigid access by allowing the models themselves to be very customisable. Let’s consider our Logistic Regression model.

```rust
pub struct LogisticRegressor<A>
    where A: OptimAlgorithm<BaseLogisticRegressor>
{
    base: BaseLogisticRegressor,
    alg: A,
}
```

This looks a little messy… Here A is a generic type. The line beginning where specifies that A must implement the OptimAlgorithm trait. This is the trait for Gradient Descent algorithms (which is poorly named, my apologies!). The BaseLogisticRegressor contains the parameters, β, and other core methods for logistic regression.

The LogisticRegressor struct allows any Gradient Descent algorithm that fits the base struct to be used. There are a number of built-in algorithms (Stochastic GD, etc.) or alternatively the user can create their own and plug them in. This relationship is two-fold - developers can create their own models and utilize the existing gradient descent algorithms.

Of course this doesn’t end with logistic regression and gradient descent. This flexibility and customisation is an aim throughout rusty-machine. Let’s consider a slightly more involved example:

```rust
pub struct GenLinearModel<C: Criterion> {
    parameters: Option<Vector<f64>>,
    criterion: C,
}

pub trait Criterion {
    type Link : LinkFunc;

    /// The variance of the regression family.
     fn model_variance(&self, mu: f64) -> f64;

    // Some other methods ...

}
```

Our Criterion can be used to specify a Generalized Linear Model. We provide a link function and some other functions which are distribution dependent, and the model does the heavy lifting. Of course there are some built in Criterion, e.g. Poisson or Binomial regression. But the primary purpose of this design is to allow the user to have full control over the GLM without needing to write chunks of code to train the model in each case.

Where are we now?

Rusty-machine currently has a fairly comprehensive linear algebra library. This certainly isn’t state of the art but it is working well enough (for now…). The linear algebra library also provides some common data manipulation methods.

In terms of machine learning the library is growing and will continue to do so. Currently there is support for:

Linear Regression
Logistic Regression
Generalized Linear Models
K-Means Clustering
Neural Networks
Gaussian Process Regression
Support Vector Machines
All of the above aim to provide a wealth of customisation. For example, different kernels for GPs, different cost and activation functions for Neural Networks, and more. In addition to those that are built-in it is also easy to create your own kernels/cost functions and use these within the existing models.

Next steps

There is definitely room for improvement on existing algorithms - both for performance and introducing some more modern techniques. There will also need to be:

Some restructuring of the current library.
Separation of linear algebra into a new crate.
Addition of data tools.
Among other things.

In the slightly more distant future we’ll need to decide how to proceed with the linear algebra as well. This will most likely mean using bindings to BLAS and LAPACK - probably via some central community adopted linear algebra library.

The down sides

Maybe this is all sounding great. However, it is still early days and lot’s of work still needs to be done. We haven’t met our goal of complete flexibility and it will be a while before we do.

I think the vision is strong but we’re a long way off and lack a lot of key components for a Machine Learning library. Consistent data handling, visualizations and performance are all core areas that need a lot of work. Even after this many would consider validation and pipelines too important to miss.

I said above that rusty-machine is implemented entirely in Rust. Although this is certainly a positive in a lot of ways there is definitely the need to introduce some foreign language libraries. It will be very difficult to match the performance and care that has gone into many scientific libraries: libsvm, LAPACK, BLAS and many others.

I’d be naive also to ignore the fact that I have been the sole developer on this project for a while*. There’s likely some bad choices that seem good to me - I’d love to have those pointed out!

* I have had some help in places. Thanks raulsi and all of the amazing people at /r/rust and SO!

Call for help

Rusty-Machine is an open-source project and is always looking for more people to jump in. If anything in this post has stood out to you please check out the collaborating page.

I should also emphasize that the project doesn’t just need people with machine learning expertise. There is a need for work on data handling and loading, visualizations, and other things. Even within the machine learning parts it would certainly help if some Rust experts helped out with optimizations.

Rust sounds cool… But rusty-machine not so much

Rusty-machine isn’t the only machine learning tool written in Rust. There are other libraries and tools which you should take a look at.

rustlearn by maciejkula
Leaf by Autumn
ndarray by bluss
And lots of others.
