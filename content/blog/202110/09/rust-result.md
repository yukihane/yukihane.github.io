---
title: "Rust の Result を良い感じにまとめるには"
date: 2021-10-08T18:50:43Z
draft: false
tags:
  - rust
---

…というのを検索する用語が "エラーハンドリング(error handling)" だということに気付くまでにも時間がかかるくらいの初級者です。

Rust でのエラーハンドリングについては歴史的変遷があるようで、ググると結局今はどうやったらええねん、という新たな疑問が湧いてきます。

**取り敢えず 2021/10 現在は、 `anyhow`(+ 自分でエラー定義する場合は `thiserror`) を利用するのが良さそうです。** この辺りは README に書きました。

- <https://github.com/yukihane/hello-rust/tree/master/error-handling>

<div class="formalpara-title">

**src/bin/gear07.rs**

</div>

``` rust
use anyhow::Result;

fn get_int_from_file() -> Result<i32> {
    let path = "number.txt";

    let num_str = std::fs::read_to_string(path)?;

    let num = num_str.trim().parse::<i32>().map(|t| t * 2)?;

    Ok(num)
}

fn main() {
    match get_int_from_file() {
        Ok(x) => println!("{}", x),
        Err(e) => println!("{:#?}", e),
    }
}
```

それ以外、外部クレートを利用しない方式としては、

- [The Rust Programming Language \> 9.2. Recoverable Errors with Result](https://doc.rust-lang.org/book/ch09-02-recoverable-errors-with-result.html) (※ [日本語版](https://doc.rust-jp.rs/book-ja/ch09-02-recoverable-errors-with-result.html)にはまだ反映されていないようです)

- [Rust By Example 日本語版 \> 18.4.3. エラーをBoxする](https://doc.rust-jp.rs/rust-by-example-ja/error/multiple_error_types/boxing_errors.html) ([原文](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/boxing_errors.html))

にあるような `Box` 化して取り扱う方式があるようです。

<div class="formalpara-title">

**src/bin/rust-book.rs**

</div>

``` rust
use std::error::Error;

fn get_int_from_file() -> Result<i32, Box<dyn Error>> {
    let path = "number.txt";

    let num_str = std::fs::read_to_string(path)?;

    let res = num_str.trim().parse::<i32>().map(|t| t * 2)?;

    Ok(res)
}

fn main() {
    match get_int_from_file() {
        Ok(x) => println!("{}", x),
        Err(e) => println!("{}", e),
    }
}
```

あるいは別の方法として 自前のエラー型でラップする([18.4.5. エラーをラップする](https://doc.rust-jp.rs/rust-by-example-ja/error/multiple_error_types/wrap_error.html), [原文](https://doc.rust-lang.org/rust-by-example/error/multiple_error_types/wrap_error.html))方法も解説がありました([`src/bin/gear03.rs`](https://github.com/yukihane/hello-rust/blob/master/error-handling/src/bin/gear03.rs))。
