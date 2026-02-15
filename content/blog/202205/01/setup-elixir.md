---
title: "Elixir 開発環境をセットアップする"
date: 2022-05-01T12:47:31+09:00
draft: false
tags:
  - elixir
---

# はじめに

[改訂新版 Elixir/Phoenix 初級①: はじめの一歩](https://www.amazon.co.jp/dp/4908829306/) という書籍で Phoenix というウェブフレームワークの勉強をはじめました。

Elixir という言語で実装していくことになりますが、本書籍は Elixir 言語入門としても優れているので、少なくとも本書を読み進めていくに当たって、言語仕様のことで困ることは無さそうです。

さて、本書は Elixir 実行環境として Docker を用いるようになっており、これはこれですぐ始められて良いのですが、写経をしているとコード補完とかもしたくなり、ローカルに Elixir 開発&実行環境をセットアップすることにしました。

いくつかやり方はあるようなのですが、最もメジャーな方法だと思われる手順でセットアップします。

本手順は Ubuntu 20.04 LTS で行ったものの記録ですが、記憶している限り、先立って行った WSL2 上のセットアップも同様の手順でOKでした。

# セットアップ手順

## Elixir のセットアップ

[公式サイト](https://elixir-lang.org/install.html) にOSごとの説明があります。

`.deb` パッケージでインストールする方法もありますが、今回は [`asdf`](https://github.com/asdf-vm/asdf) を利用してインストールします。

### asdf 本体インストール

[Getting Started](http://asdf-vm.com/guide/getting-started.html) の説明に従って進めれば良いです。

    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.10.0

でダウンロードした後、(自分は `zsh` を利用しているので) `~/.zshrc` に次を追記します。

    . $HOME/.asdf/asdf.sh

次の手順に進む前に、新しいターミナルを起動して上の設定を反映しておきます。

### 必要な asdf プラグインインストール

`erlang` と `elixir` のプラグインをインストールします。

    asdf plugin-add erlang
    asdf plugin-add elixir

### Erlang と Elixir のインストール

まず、 `erlang` をビルドするのに必要なパッケージを先にインストールしておきます。 [asdf-erlang の README](https://github.com/asdf-vm/asdf-erlang#ubuntu-2004-lts) に記載があります。

    sudo apt-get install build-essential autoconf m4 libncurses5-dev libwxgtk3.0-gtk3-dev libwxgtk-webview3.0-gtk3-dev libgl1-mesa-dev libglu1-mesa-dev libpng-dev libssh-dev unixodbc-dev xsltproc fop libxml2-utils libncurses-dev openjdk-11-jdk

実際には JDK は必須ではないようです。 ビルド時のオプションに `--without-javac` を加えることで該当機能を無効化した状態でビルドできます(具体的な方法は前述の README を参照してください)。

続いて `erlang` と `elixir` を実際にビルド、インストールします。

    asdf install erlang latest

    asdf install elixir latest

上のコマンドは `latest` を指定して最新安定版をインストールしています。 特定のバージョンをインストールしたい場合は代わりに `asdf install erlang <version>` のように指定します。 このとき、指定できるバージョンは `asdf list-all erlang` コマンドで一覧できます。

続いて、今回インストールしたバージョンを利用するように設定します。

    asdf global erlang latest
    asdf global elixir latest

これで `elixir` 実行環境が整いました。

`elixirc` コマンドのパスが通っていることを確認して完了です。

    elixirc --version

## VSCode のセットアップ

marketplace で検索すると色々出てきますが、現時点では [ElixirLS](https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls) (LS は Language Server のことのようです)だけ入れておけば良さそうです。
