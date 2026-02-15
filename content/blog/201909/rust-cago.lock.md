---
title: Cargo.lock をバージョン管理するや否や
date: 2019-09-01
draft: false
tags:
  - rust
:jbake-type: post
:jbake-status: published
:jbake-tags: rust
:idprefix:
---

`cargo new --bin` したパッケージに対して、たまたまデフォルで生成される `.gitignore` を用いずに <https://gitignore.io/> で生成してものを用いていたのですが、 `Cargo.lock` ファイルの扱いが異なるように思われ、あれ？と思って見直してみました。

すると、 gitignore.io で作成した ignore ファイルに、次のようなことが書かれていました。

> \# Remove Cargo.lock from gitignore if creating an executable, leave it for libraries  
> \# More information here <https://doc.rust-lang.org/cargo/guide/cargo-toml-vs-cargo-lock.html> Cargo.lock
>
> —  <https://gitignore.io/api/rust>

`bin` ならバージョン管理し、 `lib` ならバージョン管理しないのが正しいようです。 `cargo new` した場合はそれぞれそのような `.gitignore` が生成されていました。

次のリンクでは 1.3.7.0 以降、 publish 時もそれぞれそういう動作になる、ということを言っているのでしょうかね。

- [Rust 1.37を早めに深掘り - OPTiM TECH BLOG](https://tech-blog.optim.co.jp/entry/2019/08/16/083000)
