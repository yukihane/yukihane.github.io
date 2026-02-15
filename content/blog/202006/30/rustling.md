---
title: "rustlingをやってて詰まったところメモ"
date: 2020-06-30T03:26:59Z
draft: true
tags:
  - rust
---

# `exercises/structs/structs2.rs`

struct の update syntax というのが何のことかわからなかった。

- <https://doc.rust-lang.org/book/ch05-01-defining-structs.html#creating-instances-from-other-instances-with-struct-update-syntax>

# `exercises/test2.rs`

`"nice weather".into()` は `&str` にも `String` にもなれる。ので `string_slice` の引数としても `string` の引数としても妥当。

    error[E0282]: type annotations needed
      --> exercises/test2.rs:24:21
       |
    24 |     ("nice weather".into());
       |     ----------------^^^^---
       |     |               |
       |     |               cannot infer type for type parameter `T` declared on the trait `Into`
       |     this method call resolves to `T`

- <https://qiita.com/uasi/items/3b08a5ba81fede837531#strinto>

( `std::convert::Into<T>` トレイトに従って &str が間接的に実装、というのが脚注を含めても理解できていない…多分 [ここ](https://qiita.com/hadashiA/items/d0c34a4ba74564337d2f#intot)で言っている " `From<T>` を実装しておけば、自動で逆の変換も実装される" ということだと思う。)

"conversions" セクションにも from や into は出てくるようなのでそちらで確認できるのかも。

# `exercises/error_handling/errorsn.rs`

さっぱりわからない。 [他の人の回答](https://github.com/rizaudo/rustlings-answers/blob/8b3409501504ea85658f5d721047a9336b256755/exercises/error_handling/errorsn.rs#L24)と [この解説](https://qiita.com/legokichi/items/d4819f7d464c0d2ce2b8#stderrorerror-%E3%83%88%E3%83%AC%E3%82%A4%E3%83%88%E3%81%A8%E3%81%AF) を見て何となくといた感じ。

`Box<dyn Error>` の `Box` も `dyn` も理解できていない。
