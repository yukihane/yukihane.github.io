---
title: Rustでライブラリを作成する
date: 2019-12-31
draft: false
tags:
  - rust
:jbake-type: post
:jbake-status: draft
:jbake-tags: rust
:idprefix:
---

# はじめに

他の言語で言うところの"ライブラリ"は、Rustでは "ライブラリクレート"(library crate) と呼ぶようです。

またcrateはmoduleシステムと地続きになっているようで、よくセットで説明されているように見えます。

# 参考

- [Rustのモジュールの使い方 2018 Edition版](https://keens.github.io/blog/2018/12/08/rustnomoju_runotsukaikata_2018_editionhan/) - κeenのHappy Hacκing Blog

  - `mod.rs` は過去の遺物らしい。この文章を見て改めて [TRPL](https://doc.rust-lang.org/book/ch07-05-separating-modules-into-different-files.html) を見直してみたところ、確かに `mod.rs` という単語は登場しなくなっていた。(補足: `cargo build` した時のエラー対処ヒントには登場していた)

- [7. Managing Growing Projects with Packages, Crates, and Modules](https://doc.rust-lang.org/book/ch07-00-managing-growing-projects-with-packages-crates-and-modules.html) - The Rust Programming Language

  - [日本語訳](https://doc.rust-jp.rs/book/second-edition/ch07-00-modules.html) と異なりcrateという単語がタイトルに含まれているが、少なくとも現時点ではcrateに関する記述が無い(!)。日本語訳では第1版の [4.25. クレートとモジュール](https://doc.rust-jp.rs/the-rust-programming-language-ja/1.6/book/crates-and-modules.html) に存在する。

- [11.1. Library](https://doc.rust-lang.org/stable/rust-by-example/crates/lib.html) - Rust by Example

- [2.2. Creating a New Package](https://doc.rust-lang.org/cargo/guide/creating-a-new-project.html) - The Cargo Book

# 実行

    $ cargo new communicator --lib
    $ cd communicator
