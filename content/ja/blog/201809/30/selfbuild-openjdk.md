---
title: OpenJDK11をWindowsで自前ビルドする
date: 2018-09-30T19:53:56Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [windows, java]
# images: []
# videos: []
# audio: []
draft: false
---

Java の有償化ってより身近なところでは GPL 化と言った方が現状に即してるな、と思っています。

それはともかく、何となく OpenJDK をデバッグ情報付きでビルドしたくなったのでメモ。

# 参考リンク

- Building OpenJDK - http://hg.openjdk.java.net/jdk10/jdk10/raw-file/tip/common/doc/building.html
  - OpenJDK10 のもの。11 のものは(まだ？)無さそう
  - 後述の通り、freetype の指定は不要となっているなど、多少 configure の引数が異なる
- JDK 11 General-Availability Release - http://jdk.java.net/11/
  - OpenJDK11 のリリースページ

# 環境/準備物

- Windows10Pro, 1803 - https://portal.azure.com
  - ビルド環境
  - 今回は Azure の仮想マシンの標準構成を利用
- JDK10 - https://www.oracle.com/technetwork/java/javase/downloads/index.html#JDK10
  - ビルドするのに 1 つ前のメジャーバージョンの JDK が必要。ただし実際には同じメジャーバージョンでも良いと思われる(つまり今回なら 10 か 11 をインストール)
  - 今回は OracleJDK を用いたが、他の JDK でももちろん良いだろう
- Cygwin - https://www.cygwin.com/
  - 導入したパッケージ: mercurial, zip, unzip, make, autoconf
  - 補足すると、上のものに加えて自分は vim も入れた
  - その他 bash, tar も必要とかかれていたが、おそらく初めから入っている
- Visual Studio 2017 Community - https://visualstudio.microsoft.com/ja/downloads/
  - 多分 IDE は必要無く、Windows SDK だけ入れれば良いのだと思うが、詳しくないので分からなかった
  - インストール時オプションは「Desktop development with C++」にのみチェックを入れた

# ビルド手順

## Windows Defender 設定

私自身が下記手順を実施中、タスクマネージャで見ると「Antimalware Service Executable」がかなり CPU を使用していました。

作業高速化を図る場合、必要に応じて、Windows Defender を OFF にしたりチェック対象ディレクトリから今回の作業ディレクトリを除外する設定を行います。

## ビルドに必要なアプリケーションのインストール

上述の通りです。
ただし、次の OpenJDK ソースのチェックアウトに時間がかかるので、cygwin を先にセットアップし、ソースをチェックアウトしながらそれ以外のアプリケーションをインストールするのが良いと思います。

## OpenJDK ソースコードのチェックアウト

今回作業ディレクトリは `/cygdrive/c/openjdk` としました。
また、チェックアウトしたタグ`jdk-11+28`は冒頭に記載した OpenJDK リリースページに書いてあったものです(結果的には、HEAD のソースのようでした)。

    mkdir /cygdrive/c/openjdk
    cd /cygdrive/c/openjdk
    hg clone http://hg.openjdk.java.net/jdk/jdk11 -r jdk-11+28

ダウンロードに 30 分強、ローカルファイルシステムへの展開に 30 分強、合計で 1 時間以上かかりました。

## configure

    cd /cygdrive/c/openjdk/jdk11
    bash configure --disable-warnings-as-errors --enable-debug

### configure オプション等説明

#### --enable-debug

今回自分はデバッグ情報が欲しかったので`--enable-debug`を付与しています。不要であれば取り除きます。

#### --disable-warnings-as-errors

`--disable-warnings-as-errors`は本来不要だと思うのですが、現状のコードではこのオプションが無い場合次の警告でビルドがストップしてしまいます。

- [jvmFlagRangeList.cpp(341): warning C4305: 'argument': truncation from 'const intx' to 'double'](http://openjdk.5641.n7.nabble.com/jvmFlagRangeList-cpp-341-warning-C4305-argument-truncation-from-const-intx-to-double-td343912.html)

#### freetype について

OpenJDK10 のビルドドキュメントでは freetype を何らかの形で指定する必要があるよう書かれていますが、OpenJDK11 では freetype ソースもバンドルされているようで、Windows ビルドではデフォルトでそれが用いられるようになっています。
従って特に何か行う必要はありません。

## make

    make

ちょうど 30 分ほどかかりました。

正常終了すると、`build/windows-x86_64-normal-server-fastdebug/jdk`に成果物一式が出来上がっています。

`java -version`の出力は次の通り:

    openjdk version "11-internal" 2018-09-25
    OpenJDK Runtime Environment (fastdebug build 11-internal+0-adhoc.yukihane.jdk11)
    OpenJDK 64-Bit Server VM (fastdebug build 11-internal+0-adhoc.yukihane.jdk11, mixed mode)
