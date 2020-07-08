---
title: native-imageコマンドを実行するために行ったWindows10 への GraalVM インストールがエキサイティングな件
date: 2019-11-09T21:57:08Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java, graalvm]
# images: []
# videos: []
# audio: []
draft: false
---

悪い意味で。
なお試した時点での GraalVM 最新リリースバージョンは [19.2.1](https://github.com/oracle/graal/releases/tag/vm-19.2.1)でした。

# GraalVM インストール & 実行

GraalVM のインストール方法はいくつかあるのでお好みで。例えば:

- [GitHub](https://github.com/oracle/graal/releases)から実行バイナリをダウンロード
- [SDKMAN!](https://sdkman.io/)
- [Scoop](https://scoop.sh/)

(なお、SDKMAN!は今回試していないのでちゃんと動くかは知らない)

さて、 PATH が通せたらおもむろに `native-image` コマンドを実行してみよう。結果:

```
Error: Unable to compile C-ABI query code. Make sure GCC toolchain is installed on your system.
Error: Use -H:+ReportExceptionStackTraces to print stacktrace of underlying exception
Error: Image build request failed with exit status 1
```

# トラップ 0: Microsoft Windows SDK for Windows 7 のインストールが必要

上のメッセージでは GCC ツールチェーン入れれ、と出てるけど Windows で必要なのは Windows SDK ね。**Windows 7 向け**の。

ダウンロードはこちらから:

- [Microsoft Windows SDK for Windows 7 and .NET Framework 4 (ISO)](https://www.microsoft.com/en-us/download/details.aspx?id=8442)

オーケー。これくらいなら想定範囲だ。

# トラップ 1: Download ボタン押したら 3 種類選ばされるけどどれが何だよ？

[上で示したダウンロードサイト](https://www.microsoft.com/en-us/download/details.aspx?id=8442)から焦ってダウンロードしようとするとこの罠にはまる。
3 種類の ISO ファイルからダウンロードするものの選択を迫られるがファイル名から何が違うの変わらない。

正解の行動は、説明をちゃんと読んでから Download ボタンを押すこと。
最初の画面の "Install Instructions" を押せば説明が出てくる。

要するにこういうことだ:

- GRMSDK_EN_DVD.iso - x86 用
- GRMSDKX_EN_DVD.iso - x64 用
- GRMSDKIAI_EN_DVD.iso - Itanium 用

今回ダウンロードすべきは 2 番目の **GRMSDKX_EN_DVD.iso** だ。

# トラップ 2: 既にインストールされている Microsoft Visual C++ 2010 Redistributable を先にアンインストールしておく必要がある

実際にはインストール手順をググっているときに知ったので自分はこの罠にはまっていないのだが、どうも **Microsoft Visual C++ 2010 Redistributable** が先にインストールされていると今回のインストーラが起動時にエラーメッセージを出してインストールを進めさせてくれないらしい。
**x64 版と x86 版の 2 種類** インストールされていると思うのでアンインストールしておこう。

ちなみに、自分の環境では 2008, 2012, 2013, 2017 もインストールされていたが、これはこのままで良い(アンインストールする必要はない)。

# トラップ 3: 実行するインストーラは setup.exe ではない

今回 G: ドライブとして ISO をマウントしたがこの場合 **G:\setup.exe** がすぐ見えるのでこれを起動したくなるがこれを実行してインストールを進めると肝心の **Visual C++ Compilers** がグレーアウトしてインストールできない。なんだそれ！

実行すべきは **G:\Setup\SDKSetup.exe** だ。

インストール対象は、多分、**Windows Native Code Development > Visual C++ Compilers** と **Redistributable Packages > Microsoft Visual C++ 2010** の 2 つがあれば良いのかな、とも思ったが、今回はデフォルト指定のままにした。

# トラップ 4: Windows SDK 7.1 Command Prompt で実行しよう

これはトラップというか注意点だが、 `native-image` コマンドは
**スタートメニュー > Microsoft Windows SDK v7.1 > Windows SDK 7.1 Command Prompt**
から起動できるコマンドプロンプトで実行しよう。
さもなくば必要な環境変数などが反映されず、最初のエラーを再び見る羽目になる。

# トラップ 5: native-image が Swing に対応していない

こんだけやって `native-image` 実行してみたのに、敢え無くエラー。

```
Error: Unsupported features in 3 methods
Detailed message:
Error: Detected a started Thread in the image heap. Threads running in the image generator are no longer running at image run time.  To see how this object got instantiated use -H:+TraceClassInitialization. The object was probably created by a class initializer and is reachable from a static field. You can request class initialization at image run time by using the option --initialize-at-build-time=<class-name>. Or you can write your own initialization methods and call them explicitly from your main entry point.
Trace:  object sun.awt.AWTAutoShutdown
        method sun.awt.AWTAutoShutdown.getInstance()
Call path from entry point to sun.awt.AWTAutoShutdown.getInstance():
        at sun.awt.AWTAutoShutdown.getInstance(AWTAutoShutdown.java:133)
        at java.awt.EventQueue.detachDispatchThread(EventQueue.java:1137)
        at java.awt.EventDispatchThread.run(EventDispatchThread.java:88)
        at com.oracle.svm.core.thread.JavaThreads.threadStartRoutine(JavaThreads.java:460)
        at com.oracle.svm.core.windows.WindowsJavaThreads.osThreadStartRoutine(WindowsJavaThreads.java:137)
        at com.oracle.svm.core.code.IsolateEnterStub.WindowsJavaThreads_osThreadStartRoutine_4bc03aa26f8cdfc97ebd54050e8ae4bce1023851(generated:0)
Error: Detected a started Thread in the image heap. Threads running in the image generator are no longer running at image run time.  To see how this object got instantiated use -H:+TraceClassInitialization. The object was probably created by a class initializer and is reachable from a static field. You can request class initialization at image run time by using the option --initialize-at-build-time=<class-name>. Or you can write your own initialization methods and call them explicitly from your main entry point.
Trace:  field sun.java2d.d3d.D3DRenderQueue.rqThread
Error: Detected a started Thread in the image heap. Threads running in the image generator are no longer running at image run time.  To see how this object got instantiated use -H:+TraceClassInitialization. The object was probably created by a class initializer and is reachable from a static field. You can request class initialization at image run time by using the option --initialize-at-build-time=<class-name>. Or you can write your own initialization methods and call them explicitly from your main entry point.
Trace:  object sun.java2d.opengl.OGLRenderQueue
        field sun.java2d.opengl.OGLRenderQueue.theInstance

Error: Use -H:+ReportExceptionStackTraces to print stacktrace of underlying exception
Error: Image build request failed with exit status 1
```

多分これ。

- [[native-image] Windows with a swing application #1327](https://github.com/oracle/graal/issues/1327)

以上。
