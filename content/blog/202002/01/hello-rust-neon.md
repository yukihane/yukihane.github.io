---
title: "Nodeのnative moduleをRustで書いてみる(Neon)"
date: 2020-02-01T05:09:38Z
draft: false
tags:
  - rust
  - neon
---

RustプログラムのGUIにElectronを使うことを考えています。

その前調査としてNodeのネイティブモジュールとしてRustプログラムを利用できるようにする [Neon](https://neon-bindings.com/) というツールを使ってHello, worldしてみることにしました。

# インストール

## 前提環境

今回、先立ってインストールしていた関連プロダクトは次のとおりです。

- Ubuntu 18.04

- Node 12.14.1 (nvm でインストール)

- Yarn 1.21.1 (apt でインストール)

- Rust 1.41.0 (rustup でインストール)

その他、意識していませんが、Python2.7(not 3.x)、GCCなども必要なようです。詳しくは [Getting Started](https://neon-bindings.com/docs/getting-started)参照。

## Neon インストール

    yarn global add neon-cli

# "Hello World!" の作成と実行

[オフィシャルドキュメント](https://neon-bindings.com/docs/hello-world/) の通り進めていきます。

## プロジェクトを生成して実行してみる

    neon new thread-count
    cd thread-count
    neon build --release

これでテンプレートのビルドができました。

実行するには、これまたリファレンスの通りですが、

    node

コマンドを実行して起動するREPLで

    require('.')

と入力します。あるいは、 `neon new thread-count` コマンドを打ったときに出ていたメッセージの通り、 `node` コマンドに `-e` オプションで実行文を渡す、つまり

    node -e 'require(".")'

でもOKです。

さてここで `require('.')` は何をやっているんだ、ということなんですが、これはNodeのリファレンス [Modules \> All Together…​](https://nodejs.org/docs/latest-v12.x/api/modules.html#modules_all_together)の "LOAD_AS_DIRECTORY(X)"セクションに書いてあることのようです。

具体的には、引数に指定したパスを所定のルールで解釈していって、今回の場合はカレントディレクトリにある `package.json` の `main` フィールドに指定されているファイル `lib/index.js` を実行しているようです。そこで、このファイルを見てみます。

<div class="formalpara-title">

**lib/index.js**

</div>

``` javascript
var addon = require('../native');

console.log(addon.hello());
```

ここでも `require` が出てきました。今度は `../native` が指定されています。 ここでは先程のリファレンスの、 "LOAD_INDEX(X)" の3番、 `native/index.node` がバイナリアドオンとしてロードされる、ということのようです。

Neonのリファレンスに戻ると、次のように説明があります:

> - `native/index.node`: the native module itself, which is loaded by lib/index.js.

## Rustでロジックを実装する

`native` ディレクトリをRustプロジェクトルートディレクトリとみなして作業すれば良さそうです。

1点注意があるとすれば、自動生成された `Cargo.toml` に `edition` の指定が無かったため、自分の見慣れない `exrern` が現れたりして？？？となってしまいました。 `edition = "2018"` は即追加しておきましょう。
