---
title: "Rust に reduce は、あります"
date: 2021-10-09T02:14:55Z
draft: false
tags:
  - rust
---

ググっていると、ちょくちょく 「Rust に `reduce` は無い、代わりに `fold` を使え」という話が出てくるのが疑問だったのですが、 [`reduce` が導入されたのって `1.51.0`](https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.reduce)([2021-03-25](https://github.com/rust-lang/rust/blob/master/RELEASES.md#version-1510-2021-03-25))と、比較的最近だからなんですね。

しかしリリースノートを見てもこういう変更は載っていないのですね。 細かすぎるから？ 気付いてない人は気付かないまま過ごしてそう…

``` rust
fn main() {
    let v = vec![1, 2, 3, 4, 5];
    let sum = v.into_iter().reduce(|x, y| x + y).unwrap();
    println!("{}", sum); // 15

    // 要素1個
    let v = vec![1];
    let sum = v.into_iter().reduce(|x, y| x + y).unwrap();
    println!("{}", sum); // 1

    // 要素無し
    let v = vec![0; 0];
    let sum = v.into_iter().reduce(|x, y| x + y);
    println!("{:?}", sum); // None
}
```
