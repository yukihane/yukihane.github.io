---
title: "WSL2環境にwslu(wslview)をインストールしよう"
date: 2025-05-20T12:50:13+09:00
tags: ["wsl", "rust"]
draft: false
---

久しぶりに Rust の学習を行っています。

URL をウェブブラウザーで開くのに [open](https://crates.io/crates/open) というクレートがあるのを見つけ、add してみました。

依存関係で [is-wsl](https://crates.io/crates/is-wsl) というものも追加されているようだったので、おお、ちゃんと WSL2 環境にも対応しているんだな、と思い利用してみたところ…ブラウザーが開かない。

[検索してみると](https://github.com/Byron/open-rs/blob/f196640a9c0def100401f6e97ebe5dd4b4f2bb0e/src/lib.rs#L80)、WSL 環境では `wslview` というコマンドを使うそう。

それは何だろう、と検索してみたところ、 "wslu - A collection of utilities for WSL" というパッケージに含まれているコマンドのうちのひとつのようでした。

```
sudo apt install wslu
```

でインストールできます。

ただ、メンテナンスはもうされてなさそうです...

- https://github.com/wslutilities/wslu
