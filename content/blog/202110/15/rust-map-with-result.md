---
title: "map で Result を引き回すときに Err を意識したくない その2"
date: 2021-10-15T21:12:09+09:00
draft: false
tags:
  - rust
---

その1はこちらです:

- [map で Result を引き回すときに Err を意識したくない - スタック・オーバーフロー](https://ja.stackoverflow.com/q/82978/2808)

その1では戻り値が `i * 2` の `i32` 型になる話でしたが、その次に考えたかったのは `Result` が返ってくるメソッドで引き回すときの話でした。こんな感じで:

``` rust
// and_then を利用すれば可能だが
// この and_then を省きたい

use anyhow::{anyhow, Result};

fn parse(s: &str) -> Result<i32> {
    let res = s.parse::<i32>()?;
    Ok(res)
}

fn x2(i: i32) -> Result<i32> {
    if i < 50 {
        Ok(i * 2)
    } else {
        Err(anyhow!("too large"))
    }
}

fn main() {
    let strings = vec!["tofu", "93", "18"];
    let numbers: Vec<_> = strings
        .into_iter()
        .map(parse)
        .map(|r| r.and_then(x2))
        .map(|r| r.and_then(x2))
        .collect();
    println!("Results: {:?}", numbers);
    // Results: [Err(invalid digit found in string), Err(too large), Ok(72)]
}
```

`anyhow::Result<i32>` な関数を `map` でつなげて、最終的な結果を `anyhow::Result<i32>` のベクタで得たかったのです。

なんとなくその1の結果からするにイテレータを自作すれば良さそうに思われるのですが、現時点では [実装](https://stackoverflow.com/questions/36368843/whats-the-most-idiomatic-way-of-working-with-an-iterator-of-results/36370251#36370251)がさっぱり理解できないので、将来の自分に任せたいと思います…
