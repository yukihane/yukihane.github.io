---
title: "asyncなライブラリー関数のテストを書く"
date: 2024-04-05T05:45:28+09:00
draft: false
tags:
  - rust
---

# 今回解決したい問題

[reqwestのドキュメント](https://docs.rs/reqwest/0.12.2/reqwest/) の最初のサンプルをテスト実行することを考えます。

``` rust
let body = reqwest::get("https://www.rust-lang.org")
    .await?
    .text()
    .await?;

println!("body = {body:?}");
```

まず `Cargo.toml` に依存関係を追加して、

    cargo new --lib test-async
    cd test-async
    cargo add reqwest

冒頭のコードを実行する関数を作ります。

``` rust
fn my_func() {
    let body = reqwest::get("https://www.rust-lang.org")
        .await?
        .text()
        .await?;

    println!("body = {body:?}");
}
```

`cargo check` を実行すると次のエラーが出ます。

>     only allowed inside `async` functions and blocks

関数を `async` で定義することでこのエラーを解消します。

``` rust
async fn my_func() { // <- 頭に async を付与
    let body = reqwest::get("https://www.rust-lang.org")
        .await?
        .text()
        .await?;

    println!("body = {body:?}");
}
```

するとまた別のエラーが出ます。

>     this function should return `Result` or `Option` to accept `?`

戻り値の型を `Result` (もしくは `Option`)にする必要があります。 ところで正常時の戻り値は自分で制御できますが、エラー時は `?` が制御しているので型がわかりません。とりあえず `()` でおいて修正します。

``` rust
async fn my_func() -> Result<String, ()> {
    // <- エラー時の方がわからないので () で仮置き
    let body = reqwest::get("https://www.rust-lang.org")
        .await?
        .text()
        .await?;

    println!("body = {body:?}");

    Ok("OK".to_string()) // <- 正常時は "OK" を返す
}
```

そうすると当然

>     `?` couldn't convert the error to `()`

というエラーが出ます。 そしてよく見るともう少し詳細な出力があります。

>     the trait `From<reqwest::Error>` is not implemented for `()`, which is required by `Result<(), ()>: FromResidual<Result<Infallible, reqwest::Error>>`

このメッセージから察するに、どうもエラーの型は `reqwest::Error` っぽいです。これで書き換えてみます。

``` rust
async fn my_func() -> Result<String, reqwest::Error> {
    // <- エラーの型を reqwest::Error に書き換え
    let body = reqwest::get("https://www.rust-lang.org")
        .await?
        .text()
        .await?;

    println!("body = {body:?}");

    Ok("OK".to_string())
}
```

これでやっとエラーがなくなりました。

この関数に対してテストコードを書いていきましょう。 自動生成されていたテンプレートを書き換えてみます。

``` rust
#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn it_works() {
        // my_func() は Result<String, reqwest::Error> を返しているので unwrap() する
        let result = my_func().unwrap();
        assert_eq!(result, "OK");
    }
}
```

`cargo test` を実行すると次のエラーメッセージ。

>     help: consider `await`ing on the `Future` and calling the method on its `Output`
>     let result = my_func().await.unwrap();
>                         ++++++

言われるまま `.await` を付けてみます。

``` rust
#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    fn it_works() {
        let result = my_func().await.unwrap(); // <- await
        assert_eq!(result, "OK");
    }
}
```

すると次はこんなエラーが。

>     `await` is only allowed inside `async` functions and blocks

`await` が使えるのは `async` な関数の中でだけ、と。

じゃあ `async` 付ければ良いのか、と

``` rust
#[cfg(test)]
mod tests {

    use super::*;

    #[test]
    async fn it_works() { // <- async を付与
        let result = my_func().await.unwrap();
        assert_eq!(result, "OK");
    }
}
```

すると、

>     async functions cannot be used for tests

テストの関数は `async` にできない、と。じゃあどうすれば良いんだというのがわからない、というのが今回の問題です。

# 対応

答えは、「テスト実行用に非同期ランタイムを導入する」ということのようです。

今回は tokio を利用してみます。 ドキュメントを読むとテスト用の説明が書いてあります。 今回利用する tokio であればこのあたり:

- [Attribute Macro tokio::test](https://docs.rs/tokio/1.37.0/tokio/attr.test.html)

- [Unit Testing \| Tokio - An asynchronous Rust runtime](https://tokio.rs/tokio/topics/testing)

というわけでやってみます。

    cargo add --dev tokio --features='macros'

で `dev-dependencies` に tokio を追加し、テストコードを次のように書き換えます。

``` rust
#[cfg(test)]
mod tests {

    use super::*;

    #[tokio::test] // <- test から tokio::test に変更
    async fn it_works() {
        let result = my_func().await.unwrap();
        assert_eq!(result, "OK");
    }
}
```

`cargo test` を実行すると…​テストが pass しました！

今回のコード:

- <https://github.com/yukihane/hello-rust/tree/main/test-async>
