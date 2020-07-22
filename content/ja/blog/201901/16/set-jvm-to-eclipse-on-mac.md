---
title: Eclipseの起動に使用するJDKを指定する（Mac）
date: 2019-01-16T19:58:26Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [mac, java, eclipse]
# images: []
# videos: []
# audio: []
draft: false
---

最新の JDK をインストールしたが、古いバージョンの Eclipse も利用したい(が最新のバージョンでは起動できない)ような場合に必要となる設定です。

# 設定するファイルと設定方法

`Eclipse.app/Contents/Eclipse`　にある `eclipse.ini` に、所望のバージョンの `java` コマンドが入っているディレクトリを指定します。
`/usr/libexec/java_home -V` で `JAVA_HOME` 候補一覧が参照できますので、このディレクトリ + `/bin` を指定することになります。

例えば

    $ /usr/libexec/java_home -V
    Matching Java Virtual Machines (2):
        11.0.1, x86_64:     "OpenJDK 11.0.1"        /Library/Java/JavaVirtualMachines/openjdk-11.0.1.jdk/Contents/Home
        1.8.0_192, x86_64:  "Java SE 8"     /Library/Java/JavaVirtualMachines/jdk1.8.0_192.jdk/Contents/Home

のような状況で、 バージョン `1.8` を Eclipse を実行する JVM として指定したい場合には、冒頭で説明した `eclipse.ini` に

    -vm
    /Library/Java/JavaVirtualMachines/jdk1.8.0_192.jdk/Contents/Home/bin

と追記します。
なお追記する行は`-vmargs`より上にしてください。

参考: https://wiki.eclipse.org/Eclipse.ini#-vm_value:_Mac_OS_X_Example

# おまけ

## Eclipse がどの JVM で実行されているのかを調べるには？

メニューの Eclipe > Eclipse について で "About Eclipse" ダイアログを開き、"Installation Details"ボタン > "Configuration"タブに表示されている情報から `-vm` オプションを探します。

## `-vm`を明示的に指定しなかった場合には何が使われるの？

> If not specified, the Eclipse executable uses a search algorithm to locate a suitable VM.

参考: [The Eclipse runtime options - Eclipse documentation](https://help.eclipse.org/2018-12/index.jsp?topic=%2Forg.eclipse.platform.doc.isv%2Freference%2Fmisc%2Fruntime-options.html&resultof=%22Runtime%22%20%22runtim%22%20%22Options%22%20%22option%22%20)

## `/usr/bin`を指定しておけば`JAVA_HOME`を切り替えるだけで良いんじゃ？

確かに `java`コマンドを実行したときのバージョンが切り替わるのですが、Eclipse には効かないようです。
このように指定した場合、 `/usr/libexec/java_home` で出力される場所のバージョンを用いるようです。
この出力は通常インストールされているバージョンのうち最新のものとなっているでしょう。

なお、起動に失敗した場合には、その時使用しようとした JVM の情報はエラーログ(場所は起動失敗時のエラーダイアログに示されます)に出力されています。

## `/usr/libexec/java_home` の出力を切り替えることはできるの？

実際には、`/usr/libexec/java_home -V` の最上行が`/usr/libexec/java_home`として出力されているように見えます。

この並びは、 `/Library/Java/JavaVirtualMachines/<それぞれのバージョンディレクトリ>/Contents/Info.plist`　に書かれている `JVMVersion`値の逆順になるようなので、この値を書き換えることにより　`/usr/libexec/java_home`　出力結果をすげ替えることが可能です。
参考: [How can I change Mac OS's default Java VM returned from /usr/libexec/java_home - Stack Overflow](https://stackoverflow.com/a/20994919/4506703)
