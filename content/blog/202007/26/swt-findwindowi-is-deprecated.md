---
title: "SWTのFindWindowはもはや存在しない"
date: 2020-07-25T23:42:57Z
draft: false
tags:
  - java
---

元ネタ:

- [古い Eclipse の起動時に UnsatisfiedLinkError が発生する - スタック・オーバーフロー](https://ja.stackoverflow.com/q/68951/2808)

いにしえのJava世界では、Win32APIにアクセスするためにSWTを利用していたそうです(リンク先のエントリは2005年のもの。私がJava始めるまえの話だ…)。

冒頭リンク先で触れられている `org.eclipse.swt.internal.win32.OS.FindWindow` というメソッドもそういったもののひとつで、 [`FindWindow`](https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-findwindowa) を呼び出すのに昔は利用されていたようです。

しかし、このSWTのメソッドは2018年に削除されており、もはや現代では利用することはできません。下記のissue/commitで削除されています。

- [Bug 531097 - \[Win32\] Remove support for Windows versions older than Vista](https://bugs.eclipse.org/bugs/show_bug.cgi?id=531097)

  - [コード差分](https://github.com/eclipse/eclipse.platform.swt/commit/36a2cde49563bc13e65b5b03e811641de522f240#diff-bb4584995e162b851fafacf3b046cc35)

現代では、Win32APIを利用したい場合の定番は [JNA](https://github.com/java-native-access/jna)([Wikipedia](https://ja.wikipedia.org/wiki/Java_Native_Access))であり、私は利用したことがありませんが、 `FindWindow` も[確かに存在しています](https://github.com/java-native-access/jna/blob/5.6.0/contrib/platform/src/com/sun/jna/platform/win32/User32.java#L135)のでこちらを使えば良いのではないでしょうか。
