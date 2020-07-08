---
title: reqwest使おうとしたけどよくわからん
date: 2020-01-01T20:42:42Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [rust]
# images: []
# videos: []
# audio: []
draft: false
---

# はじめに

年の瀬にスクレイピングしたくなって Rust 勉強し始めたけれど、直前に reqwest ライブラリに更新が入ったみたいでコピペコーディングが阻まれた。

# 知っとかないといけなかったこと

- 今回の更新 [reqwest 0.10.0](https://seanmonstar.com/post/189960517042/reqwest-v010) で async/await がデフォルトになった(ので従来のサンプルコードは動かなくなった)。
- Cargo には [feature flag(feature toggle)](https://doc.rust-lang.org/stable/cargo/reference/manifest.html#the-features-section) 機能があって、reqwest やら(オフィシャルサンプルで利用している)tokio やらもこれを利用している。
  - (async/await を使わない、従来の)blocking 版をどうやって使うのか全然わからなかったけれど、features で明示的に指定する必要があった。
  - [オフィシャルサンプルを動かすにしてもこれを知っておかないといけなかった](https://github.com/seanmonstar/reqwest/issues/755)。
- [tokio](https://crates.io/crates/tokio)を用いる必要があった。
  - 自分が見ていた(古い)サンプルでは[futures](https://crates.io/crates/futures)の`futures::executor::block_on`を利用していたので当初それをコピペったのだが次のエラーが出た: 'not currently running on the Tokio runtime.',
  - async/await 構文が標準に取り込まれた、ということは非同期ランタイムを別のものにすげ替えることが可能、みたいなイメージを持っていたのだが、そうではなさそう。
  - おそらく[自転車本の補遺](https://github.com/ghmagazine/rustbook/pull/2)が言うところの「非同期エコシステム」が関係する話題。

# サンプルを動かすには

https://github.com/seanmonstar/reqwest

```
use std::collections::HashMap;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let resp: HashMap<String, String> = reqwest::get("https://httpbin.org/ip")
        .await?
        .json()
        .await?;
    println!("{:#?}", resp);
    Ok(())
}
```

を動かすためには、 `Cargo.toml` の `[dependencies]` セクションに次のように書く必要があった。

```
[dependencies]
reqwest = {version = "0.10.0", features=["json"]}
tokio = {version = "0.2.6", features = ["macros"]}
```

また、blocking 版

```
use std::collections::HashMap;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let resp: HashMap<String, String> = reqwest::blocking::get("https://httpbin.org/ip")?
        .json()?;
    println!("{:#?}", resp);
    Ok(())
}
```

は、

```
[dependencies]
reqwest = {version = "0.10.0", features=["json","blocking"]}
```

であった。

ちなみに reqwest の feature flag 一覧は

- https://docs.rs/reqwest/0.10.0/reqwest/#optional-features

にある。
