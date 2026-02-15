---
title: "Ubuntu20.04 で Kindle for PCを使う"
date: 2021-03-07T01:57:49Z
draft: false
---

# はじめに

2021-03-07時点では、 [UbuntuでKindle for PCを使う]({{< relref"kindle-for-pc" >}}) の方法で Ubuntu20.04 に Kindle for PC をインストールして起動すると、次のようなエラーが出てコンテンツにアクセスできなくなってしまっていました:

    接続できません ネットワークの設定とプロキシの構成を確認してください。

そこで、改めてインストール手順を書き直したのが本ドキュメントです。 本ドキュメントで用いた各ソフトウェアのバージョンは次のとおりです(いずれも入手できた最新版を用いました):

- Ubuntu 20.04

- wine-6.0

- playonlinux 4.3.4

- Kindle for PC 1.26.0(55076)

# ちなみに

素のwineの環境は `~/.wine` に、 PlayOnLinux の環境は `~/.PlayOnLinux` にあるので、初期状態に戻したければこれらのディレクトリを削除すればよいでしょう。

また、wineのデフォルト設定ではWindowsのマイドキュメントがUbuntuの `~/Documents` にシンボリックリンクされているようなので、 `~/Documents/My\ Kindle\ Content` にKindleの書籍データが入っています。初期状態に戻したいのであればこれも削除しましょう。

# Wine インストール

今回の手順では PlayOnLinux を利用せず直接このwineを利用して Kindle for PC を起動します。

- 参考: <https://wiki.winehq.org/Ubuntu>

<!-- -->

    sudo dpkg --add-architecture i386

    wget -nc https://dl.winehq.org/wine-builds/winehq.key
    sudo apt-key add winehq.key

リポジトリを追加します。コマンドはUbuntuのバージョンによって異なります。上記リンク先を参照してください(下記の例は20.04のものです)。

    sudo add-apt-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ focal main'

リポジトリを追加したら、次のコマンドでWineのstable版をインストールします。

    sudo apt-get install --install-recommends winehq-stable

今回インストールされたバージョンは `6.0` のようでした。

    $ wine64 --version
    wine-6.0

# 補足: インストールするWineとKindleのバージョンについて

過去の記事(本記事冒頭でリンクしている私自身が書いたものも含む)では、WineとKindle for PCは最新バージョンにすれば良いわけではなく、相性がある、と書かれてきました。

ただ、現時点ではむしろ過去の相性が良いと言われていたバージョンは動かなくなってしまっており、最新を選んだ方が良いようでした。次の不具合が関係していそうです:

- [Is there anyone who use Amazon Kindle for PC via Wine?](https://forum.manjaro.org/t/is-there-anyone-who-use-amazon-kindle-for-pc-via-wine/46560)

- [Bug 50471 Kindle for PC 1.16.0 can’t connect](https://bugs.winehq.org/show_bug.cgi?id=50471)

解決策は、 [このコメント](https://bugs.winehq.org/show_bug.cgi?id=50471#c9)にある通り

    Now I can connect kindle for PC to amazon with Kindle version 1.30.0.
    What I did are following.
    1. uninstall old kindle with command "wine64 uninstaller"
    2. mkdir -p ${WINEPREFIX:-$HOME/.wine}/drive_c/users/$USER/AppData/Local/Amazon/Kindle
    3. install Kindle for PC version 1.30.0.

を実行すれば良いです。

以下、具体的な手順を記述します。

# cjkフォントインストール

素の状態だと日本語メニューが文字化けするのでフォントをインストールしておきます。 [`winetricks`](https://wiki.winehq.org/Winetricks) というパッケージを追加でインストールします:

    sudo apt install winetricks

`winetricks` コマンドを実行するとウィザードダイアログが出るので、次のとおり進めていきます:

- Select the default wineprefix \> Install a font \> cjk fonts

実行するとエラーダイアログが複数回出ますが、無視してOKボタンを押せばよいです。

完了するとウィザードダイアログに戻ります。キャンセルボタンを押して終了します。

# 手動で必要なディレクトリ作成

前述のコメントに書かれているコマンドをそのまま実行します:

    mkdir -p ${WINEPREFIX:-$HOME/.wine}/drive_c/users/$USER/AppData/Local/Amazon/Kindle

# Kindle for PC インストーラダウンロード & 実行

最新版を用意すれば良いので、公式サイトからダウンロードしましょう:

- <https://www.amazon.co.jp//dp/B011UEHYWQ>

ちなみに現時点で 1.30.0 がリリースされているはずなのですが、私がインストールを実行したところ 1.26.0 がインストールされました。

インストールコマンド:

    wine64 <ダウンロードしたexeファイル>

これでインストール完了です。

# 実行

    wine64 ~/.wine/drive_c/Program\ Files\ \(x86\)/Amazon/Kindle/Kindle.exe

コマンドで起動できます。毎回打つのは面倒なのでalias設定しておけばよいでしょう:

    echo 'alias kindle="wine64 $HOME/.wine/drive_c/Program\ Files\ \(x86\)/Amazon/Kindle/Kindle.exe"' >> ~/.bashrc
