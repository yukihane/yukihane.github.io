---
title: "Hello, Wasm with Rust"
date: 2020-04-07T22:39:49Z
draft: false
tags:
  - rust
  - wasm
---

# はじめに

wasmに挑戦してみようとHello, worldをやってみようとしました。

公式っぽいドキュメントとしてはググると次のものが見つかりました:

- [The Rust and WebAssembly Book](https://rustwasm.github.io/docs/book/) ([GitHub repo](https://github.com/rustwasm/book))

- [Rust から WebAssembly にコンパイルする - WebAssembly \| MDN](https://developer.mozilla.org/ja/docs/WebAssembly/Rust_to_wasm)

最初は1つめのドキュメントを見ながらやり始めたのですが、どうも記述が古いっぽい気がしてリポジトリを見てみると最終コミットが5ヶ月前で、ちょっとどうかと思ったので2つめを見てみたのですが、こちらはこちらで本当にHello, world部分しか説明されておらず先に進めそうもありませんでした。

それ以外のものを探したところ、 <https://rustwasm.github.io/> から辿れる次のドキュメントを見つけました:

- [The wasm-pack Book](https://rustwasm.github.io/docs/wasm-pack/)

- [The wasm-bindgen Guide](https://rustwasm.github.io/docs/wasm-bindgen/)

…がこちらも少し現状に即していないように見えました。

以下、上記のドキュメントを継ぎ接ぎしてHello, worldを作成してみた記録です。

# プロジェクト作成の前に

## ツールの種類と概要

似た名前のツール/コマンドが登場するので最初に一覧を見ておくと良いかと考えます。The Rust Wasm Bookに説明があります。

- [5.1. Crates You Should Know](https://rustwasm.github.io/docs/book/reference/crates.html)

- [5.2. Tools You Should Know](https://rustwasm.github.io/docs/book/reference/tools.html)

- [5.3. Project Templates](https://rustwasm.github.io/docs/book/reference/project-templates.html)

## プロジェクトテンプレート

前述リンク [5.3. Project Templates](https://rustwasm.github.io/docs/book/reference/project-templates.html) 先には3種類のプロジェクトテンプレートが紹介されています。

いろいろなチュートリアルを見ていると、このテンプレートが事前説明無く使われている(あるいはテンプレート無しで進めていく)のでどのチュートリアルを参考にすれば良いのか混乱しました。

ですのでここで簡単に触れておきます。

[wasm-pack-template](https://github.com/rustwasm/wasm-pack-template)  
RustのコードをWasmプロジェクトにパッケージングするためのテンプレート。JavaScriptの世界とは無関係です(ので `package.json` などが含まれない)。

[create-wasm-app](https://github.com/rustwasm/create-wasm-app)  
Rustから生成したWasmのNPMパッケージを利用するようなJavaScriptプロジェクトのテンプレート。Rustの世界とは無関係です(ので `Cargo.toml` などが含まれない)。

[rust-webpack-template](https://github.com/rustwasm/rust-webpack-template)  
JavaScriptプロジェクトですが、一部をRustで実装し、Wasmに変換して利用するようなプロジェクト。

"Hello, worldをWasmでやってみよう！"という場合、おそらく利用することになるのは rust-webpack-template ではないでしょうか。

# プロジェクト作成

The wasm-pack Book の [5.1. Hybrid applications with Webpack](https://rustwasm.github.io/docs/wasm-pack/tutorials/hybrid-applications-with-webpack/index.html) が `rust-webpack-template` を利用したプロジェクト作成チュートリアルになっているのでこれをなぞります。

    npm init rust-webpack wasm-app

( `wasm-pack` のチュートリアルで用いられているのは [`wasm-pack-template`](https://github.com/rustwasm/wasm-pack-template) でなく [`rust-webpack-template`](https://github.com/rustwasm/rust-webpack-template) …​これだけで混乱するには十分です…​)

ちなみに `yarn create rust-webpack` は何故か失敗します([こちら](https://github.com/rustwasm/create-wasm-app/issues/143) と同じ原因でしょうか)。 ですので、 `yarn` を利用する場合もここだけ `npm` コマンドで実行する必要がありそうです。

# Hello, world 加筆

上で参考にしたチュートリアルの続きを進めたいのですが、 [Your Rust Crate](https://rustwasm.github.io/docs/wasm-pack/tutorials/hybrid-applications-with-webpack/using-your-library.html#your-rust-crate) に書かれているコード

<div class="formalpara-title">

**src/lib.rs**

</div>

    // Your code goes here!
    let p: web_sys::Node = document.create_element("p")?.into();
    p.set_text_content(Some("Hello from Rust, WebAssembly, and Webpack!"));

を追加してもコンパイルが通りません。

これを解決するには The `wasm-bindgen` Guide の [1.9. web-sys: DOM hello world](https://rustwasm.github.io/docs/wasm-bindgen/examples/dom.html) に書かれている通り、 `web-sys` の features 設定を行う必要があります。

また、そもそもコード自体も間違っており features 追加した後コード修正も必要になります。これも上記ページが参考になります。

<div class="formalpara-title">

**Cargo.toml**

</div>

    [dependencies.web-sys]
    version = "0.3.22"
    features = ["console", 'Document', 'Element', 'HtmlElement', 'Node', 'Window']

<div class="formalpara-title">

**src/lib.rs**

</div>

    // Your code goes here!
    let window = web_sys::window().expect("no global `window` exists");
    let document = window.document().expect("should have a document on window");
    let body = document.body().expect("document should have a body");

    let val = document.create_element("p")?;
    val.set_text_content(Some("Hello from Rust, WebAssembly, and Webpack!"));

    body.append_child(&val)?;

# サンプル実装リンク

- <https://github.com/yukihane/hello-rust/tree/master/wasm-app>
