---
title: "IntelliJ 最新版(2021.3) で Kotlin と Lombok が共存できない"
date: 2022-01-05T06:38:51+09:00
draft: false
tags:
  - kotlin
---

\[追記 2022-01-17\] 今回リリースされた `213-1.6.10-release-944-IJ6461.79` で修正されたようです(ただし `.idea` ディレクトリを削除してからインポートし直す必要がありました)。

[Kotlin 1.5.20](https://kotlinlang.org/docs/whatsnew1520.html) から [Lombok compiler plugin](https://kotlinlang.org/docs/lombok.html) というものが提供されるようになり、 Kotlin から自動生成される getter などにアクセスできるようになりました(※実験的機能なようですが)。

- [Support for calling Java’s Lombok-generated methods within modules that have Kotlin and Java code](https://kotlinlang.org/docs/whatsnew1520.html#support-for-calling-java-s-lombok-generated-methods-within-modules-that-have-kotlin-and-java-code)

IntelliJ の Kotlin プラグインもこの機能をサポートしているようですが、最新版の IntelliJ (2021.3) では現状うまく動作していないようです。

- [KT-50013 Mixed Java-Kotlin Project with Lombok annotations on Java classes fails to compile.](https://youtrack.jetbrains.com/issue/KT-50013)

IntelliJ 上で実行すると次のようなエラーメッセージが出ます。

    Kotlin: Cannot access 'message': it is private in 'MyJavaClass'

回避策としては、ひとつ前のバージョンの IntelliJ を利用する、ということが挙げられていました。

下のリンクから 2021.2 をダウンロードするか、 [JetBrains Toolbox App](https://www.jetbrains.com/ja-jp/toolbox-app/) を利用すれば良さそうです。

- <https://www.jetbrains.com/ja-jp/idea/download/other.html>
