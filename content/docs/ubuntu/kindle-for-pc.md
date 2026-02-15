---
title: "UbuntuでKindle for PCを使う"
date: 2020-07-26T01:57:49Z
draft: false
---

<div id="header">

</div>

<div id="content">

<div class="paragraph">

書きかけのページです。次のリンク先が参考になります。

</div>

<div class="ulist">

- <a href="https://qiita.com/giwagiwa/items/d2e447af5225c1ce9800" class="bare">https://qiita.com/giwagiwa/items/d2e447af5225c1ce9800</a>

</div>

<div class="paragraph">

Ubuntu16.04上で、PlayOnLinxで管理されたWine環境でKindle for PCを動作させる手順です。

</div>

<div class="sect1">

## Wine インストール

<div class="sectionbody">

<div class="paragraph">

PlayOnLinuxを動作させるのに先立ってWineが必要らしいのでインストールします。 なお**このWineはKindleを動作させるものではない**ので、最新安定版をインストールしておけば良いようです。 (後述しますが、**Kindleを動作させるWine**は相性問題で必ずしも最新版が良いとは限らないようです。)

</div>

------------------------------------------------------------------------

<div class="paragraph">

古い記事では ppa:wine/wine-builds を使用するよう書かれているが、これは既にdeprecatedです(リポジトリ追加時に警告も出る)。

</div>

<div class="paragraph">

<a href="https://launchpad.net/~wine/+archive/ubuntu/wine-builds" class="bare">https://launchpad.net/~wine/+archive/ubuntu/wine-builds</a>

</div>

<div class="quoteblock">

> <div class="paragraph">
>
> !!! PLEASE NOTE THAT THIS REPOSITORY IS DEPRECATED !!!
>
> </div>
>
> <div class="paragraph">
>
> For more information, please see:
>
> </div>
>
> <div class="paragraph">
>
> ``    `https://www.winehq.org/pipermail/wine-devel/2017-March/117104.html[`https://www.winehq.org/pipermail/wine-devel/2017-March/117104.html ``\]
>
> </div>
>
> <div class="paragraph">
>
> The following commands can be used to add the new repository:
>
> </div>
>
> <div class="paragraph">
>
> ``    wget `https://dl.winehq.org/wine-builds/Release.key[`https://dl.winehq.org/wine-builds/Release.key ``\]  
> `   sudo apt-key add Release.key`  
>
>    sudo apt-add-repository ‘[\`https://dl.winehq.org/wine-builds/ubuntu/](https://dl.winehq.org/wine-builds/ubuntu/)’\`
>
> </div>

</div>

<div class="paragraph">

というわけで、ここに書かれているとおり、代わりに新しいリポジトリを用います。 …と、以前はそれでよかったのですが、2018年末、ここから更に公開鍵が変わったようなので、次のコマンドを実行する必要があります([参考](https://wiki.winehq.org/Ubuntu))。

</div>

<div class="literalblock">

<div class="content">

    wget -nc https://dl.winehq.org/wine-builds/winehq.key
    sudo apt-key add winehq.key

</div>

</div>

<div class="paragraph">

リポジトリを追加します。Ubuntuのバージョンごとに異なりますのでhttps://wiki.winehq.org/Ubuntu\[リンク先\]を参照してください。下は18.04の例です。

</div>

<div class="literalblock">

<div class="content">

    sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

</div>

</div>

<div class="paragraph">

リポジトリを追加したら、次のコマンドでWineのstable版をインストールします。

</div>

<div class="literalblock">

<div class="content">

    sudo apt-get install --install-recommends winehq-stable

</div>

</div>

</div>

</div>

<div class="sect1">

## PlayOnLinux インストール

<div class="sectionbody">

<div class="paragraph">

Ubuntuのリポジトリにも playonlinux は存在するが、オフィシャルサイトにある方がバージョンが新しかったのでそちらを用いることにします。

</div>

<div class="ulist">

- <a href="https://www.playonlinux.com/en/download.html" class="bare">https://www.playonlinux.com/en/download.html</a>

</div>

<div class="paragraph">

に書かれているとおりにインストール。\`playonlinux_xenial.list\`の部分はバージョンによって異なるので適宜読み替えます。

</div>

<div class="literalblock">

<div class="content">

    wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -
    sudo wget http://deb.playonlinux.com/playonlinux_xenial.list -O /etc/apt/sources.list.d/playonlinux.list
    sudo apt-get update
    sudo apt-get install playonlinux

</div>

</div>

<div class="paragraph">

なお、このページに以下の通り書かれているのが確認できるはず。実際にwineをインストールせずにplayonlinuxを起動するとwineが必要という警告ダイアログが出ます。

</div>

<div class="quoteblock">

> <div class="paragraph">
>
> Ubuntu Precise (and superior) users : You must install the package wine:i386 to get PlayOnLinux working
>
> </div>

</div>

</div>

</div>

<div class="sect1">

## インストールするWineとKindleのバージョンの選定

<div class="sectionbody">

<div class="paragraph">

冒頭でも少し触れましたが、WineとKindle for PCは最新版のほうが良いとは限らず、相性があるようです。 次のページに動作検証結果が書かれています。

</div>

<div class="ulist">

- <a href="https://appdb.winehq.org/objectManager.php?sClass=application&amp;iId=10597" class="bare">https://appdb.winehq.org/objectManager.php?sClass=application&amp;iId=10597</a>

</div>

<div class="paragraph">

*Latest Rating* の項目が Platinum か Gold になっているものを選んでおけばよいかと思います。 今回はPlatinumとされている Kindle for PCのバージョン 1.17.x , Wine のバージョン 2.15 を選ぶこととしました。

</div>

</div>

</div>

<div class="sect1">

## Kindle for PC(.co.jp対応版) ダウンロード

<div class="sectionbody">

<div class="paragraph">

Kindle for PCについて、PlayOnLinuxからダウンロードはできるものは.co.jpアカウントでログイン出来ないようですので、別途入手します。 参考にした [こちら](https://qiita.com/giwagiwa/items/d2e447af5225c1ce9800)のページでは [このサイト](https://kindle-for-pc.en.uptodown.com/windows)から入手していました。

</div>

</div>

</div>

<div class="sect1">

## PlayOnLinxにKindle環境を構築

<div class="sectionbody">

<div class="sect2">

### PlayOnLinux起動

<div class="paragraph">

`playonlinux` コマンドで起動できます。

</div>

</div>

<div class="sect2">

### Kindleを動作させるWineのインストール

<div class="paragraph">

ツール \> Wineのバージョンを管理 メニューを選択し、前述の通り決定したバージョン 2.15 をインストールします。

</div>

</div>

<div class="sect2">

### Kindle for PC のインストール

<div class="paragraph">

ファイル \> インストール メニューを選択します。(本来ならここでインストール可能なアプリ一覧が表示されるようですが、私が今回インストールしたバージョンでは読み込み中表示のまま止まっています)

</div>

<div class="paragraph">

画面下部の"*リストにないプログラムをインストールする*"を選択します。

</div>

<div class="paragraph">

"*Install a program in a new virtual drive*"を選択します。

</div>

<div class="paragraph">

好きな名前を入力します。(私は *for_kindle* と入力しました)

</div>

<div class="paragraph">

"*Use another version of Wine*" と "*Configure Wine*" にチェックを入れます。

</div>

<div class="paragraph">

Kindle for PCを動作させるWineのバージョンである *2.15* を選択します。

</div>

<div class="paragraph">

"*32bits windows installation*" を選択します。

</div>

<div class="paragraph">

MonoインストールとGeckoインストールを促されますが、両方キャンセルします。

</div>

<div class="paragraph">

"アプリケーション"タブの "Windowsバージョン" を **Windows 8.1** に設定します。

</div>

<div class="paragraph">

install file の選択に置いて、先にダウンロードしておいた Kindle for PCのインストーラexeを指定します。

</div>

</div>

<div class="sect2">

### 文字化けの解消

<div class="paragraph">

ここまでの設定でKindleは起動できるようになります。 が、起動してみると分かる通りメニューの日本語が豆腐表示になっています。 これを解消します。

</div>

<div class="ulist">

- 参考: [LubuntuにplayonlinuxでKindleをインストール](https://pri-light.hatenadiary.org/entry/20170723/p1) - Jiyu na Blog

</div>

<div class="paragraph">

今回は [Cicaフォント](https://github.com/miiton/Cica)(`Cica-Regular.ttf`)を利用しました。他のフォントを利用する場合は適宜読み替えてください。

</div>

<div class="sect3">

#### フォントを配備

<div class="paragraph">

`~/PlayOnLinux’s virtual drives/for_kindle/drive_c/windows/Fonts` にフォントファイル `Cica-Regular.ttf` を置きます。

</div>

</div>

<div class="sect3">

#### レジストリファイル作成

<div class="paragraph">

`~/Documents/kindle_font.reg` というファイル名で次の内容を保存します。 エンコーディングはShift JISとします。(なお、改行コードは今回LFで行いましたが、これで問題ありませんでした。)

</div>

<div class="listingblock">

<div class="content">

``` highlight
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
"Andale Mono"="Cica"
"Arial Unicode MS"="Cica"
"Batang"="Cica"
"Dotum"="Cica"
"MS Gothic"="Cica"
"MS Mincho"="Cica"
"MS PGothic"="Cica"
"MS PMincho"="Cica"
"MS UI Gothic"="Cica"
"Tahoma"="Cica"
"ＭＳ ゴシック"="Cica"
"ＭＳ 明朝"="Cica"
"ＭＳ Ｐゴシック"="Cica"
"ＭＳ Ｐ明朝"="Cica"
```

</div>

</div>

<div class="paragraph">

PlayOnLinuxのランチャー画面でKindleアイコンを右クリックし、コンテキストメニューからレジストリエディタを起動します。

</div>

<div class="paragraph">

レジストリエディタのメニューから「レジストリのインポート」を選択し、上記で作成したファイルを選択するとフォント置換設定がインポートされ、上の設定の通りCicaフォントで表示されるようになります。

</div>

</div>

</div>

</div>

</div>

</div>

<div id="footer">

<div id="footer-text">

Last updated 2026-02-15 15:48:52 +0900

</div>

</div>
