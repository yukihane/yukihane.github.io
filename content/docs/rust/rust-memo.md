---
title: "Rust学習メモ"
date: 2020-07-24T01:06:39Z
draft: false
---


## リンク

* [Rust Playground](https://play.rust-lang.org/)
* https://imoz.jp/note/rust-functions.html[Rustは何が新しいのか（基本的な言語機能の紹介）
- いもす研 (imos laboratory)]
* [プログラミング言語Rust](http://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/)
  - [原版](https://doc.rust-lang.org/book/)にはhttps://doc.rust-lang.org/book/first-edition/[1st
Edition], https://doc.rust-lang.org/book/second-edition/[2nd
Edition]があるが、そのどちらとも違う模様(和訳されているのは1stの古いバージョンか？)
* [Rust by Example](http://rust-lang-ja.org/rust-by-example/)

## 学習順序

1. [プログラミング言語Rust](http://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/)
[3.1数当てゲーム](http://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/guessing-game.html)までを実行。
1. http://rust-lang-ja.org/rust-by-example/[Rust by
Example]のhttp://rust-lang-ja.org/rust-by-example/hello.html[1Hello
World]を少し読むも、先にテスト方法を見ておいた方がよいかと考える。
1. [プログラミング言語Rust](http://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/)
https://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/testing.html[5.2
テスト]を実行。
* 新用語: *アトリビュート*(`#[test]`, `#[cfg(test)]`), *モジュール*
1. https://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/crates-and-modules.html[4.25
クレートとモジュール]
* クレート(crate):
他の言語における「ライブラリ」や「パッケージ」(Javaでいうところのpackageではないと思う)
* モジュール:
Javaのpackageのようなもの。ただし階層(ディレクトリ)ごとに可視性を設定できる模様
1. https://rust-lang-ja.github.io/the-rust-programming-language-ja/1.6/book/attributes.html[4.27
アトリビュート]
* Javaのアノテーションのようなものか。ただしおそらくコンパイル時に解釈されるもののみ。
* (少なくとも現時点では)アトリビュートの自作はできない。言語仕様で決められているものがすべて。
1. 冒頭リンク
[Rustは何が新しいのか](https://imoz.jp/note/rust-functions.html)を流し読み。わからないこともいくつかあるがとりあえず流す。
* `"hoge".into()`の`into`とは？ (「into() の返り値は result
の型に依存するので、推論には用いられません。」というコメントがあるが…？)
* ジェネリクスの`&'a`？(「'a は寿命を表し、orig
と返り値は同じ寿命であることを表します。」というコメントがあるが…？)
1. Rust by Exampleを再開。
* [3.1構造体](http://rust-lang-ja.org/rust-by-example/custom_types/structs.html)
  - デストラクト単に「分解する」の意味の模様。デストラクタなどの言語仕様的な単語ではない。http://rust-lang-ja.org/rust-by-example/flow_control/match/destructuring.html[7.5.1
デストラクト]に説明がある。なお原文では destructure/destructuring
であり、destructではない。
  - ユニット: 原文ではユニット構造体(unit
structs)。単に「ユニット」と呼ぶとほかの何かと混同してしまうのではないか。
  - 「構造体の定義とインスタンスの作成を同時に行う」は原文では「struct
instantiation is an expression too」となっており全く意味が違う。
* http://rust-lang-ja.org/rust-by-example/custom_types/enum/testcase_linked_list.html[3.2.3
テストケース: 連結リスト]
  - Box:
「Rustにおいて、すべての値はデフォルトでスタックに割り当てられます。Boxを作成することで、値をボックス化、すなわちヒープ上に割り当てることができます。ボックスとは正確にはヒープ上におかれたTの値へのスマートポインタです。」http://rust-lang-ja.org/rust-by-example/std/box.html[17.1
Box, スタックとヒープ] より。
  - やろうとしていることはわかるが各要素が理解できない。後で見直す。
* 変数をアンダーバーから始めると未使用でも警告が出ない。
* 型キャストの仕様は独特だが、必要な時に見直せばよいか。
[5 型キャスティング](http://rust-lang-ja.org/rust-by-example/cast.html)

## 未解決の疑問点など

* メソッドのオーバロードはない？
  - http://rust-lang-ja.org/rust-by-example/fn/methods.html
とかを見ると名前を変えている。
  - https://www.reddit.com/r/rust/comments/2umcxv/wait_rust_doesnt_have_function_overloading/

Rustでオーバーロードが存在すると引数でmoveするのかborrowするのか紛らわしくなるのでそれを嫌っている可能性も？

* 「メソッド」という呼称はなくなった？
  - http://rust-lang-ja.org/rust-by-example/generics/impl.html
のタイトルは「メソッド」だが、英語版では
https://rustbyexample.com/generics/impl.html
"Implementation"(実装)になっている。

