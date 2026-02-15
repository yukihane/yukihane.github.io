---
title: "Rust 勝手に FAQ"
date: 2020-07-24T01:08:11Z
draft: false
---

自身の勉強中にまとめているページなので誤っている可能性も大きいです。

# 簡単に実行できる環境が欲しい

Webブラウザ上で実行結果が確認できます:

<https://play.rust-lang.org/>

# 変数束縛の方が知りたい

その変数の存在しないフィールドアクセスなどを行ってコンパイルエラーを起こさせるのが簡単そう。

- [How do I print the type of a variable in Rust? - Stack Overflow](https://stackoverflow.com/q/21747136/4506703)

# to_string() と to_owned() どちらを使うのが正しいのか

どちらでもよい。

- [&str を String に変換する4つの方法 - Qiita](http://qiita.com/uasi/items/3b08a5ba81fede837531)

- [How do I convert a &str to a String in Rust?](https://mgattozzi.github.io/2016/05/26/how-do-i-str-string.html)

# crate_type とは？

- [Rust の crate_type をまとめてみた - Qiita](http://qiita.com/etoilevi/items/4bd4c5b726e41f5a6689)

- [Linkage - The Rust Reference](https://doc.rust-lang.org/reference/linkage.html)

# トレイト(trait)とは？

> トレイト(trait)とは任意の型となりうる\`Self\`に対して定義されたメソッドの集合のことです。

- <http://rust-lang-ja.org/rust-by-example/trait.html>

# "?"とは？

\`Result\`に対するエラー伝播のためのショートカット(糖衣構文)。 \`Ok\`なら内容を取得し、\`Err\`ならその\`Err\`でリターンする。 戻り値が\`Result\`であるような関数内で使用できる。

ありがちなのは、`` main`関数の中で使用しようとしてコンパイルエラーになること。 (`main`は戻り値が ``()\`であり、上の条件を満たさないので使用できない)

参考: [Recoverable Errors with `Result` - The Rust Programming Language](https://doc.rust-lang.org/book/second-edition/ch09-02-recoverable-errors-with-result.html)
