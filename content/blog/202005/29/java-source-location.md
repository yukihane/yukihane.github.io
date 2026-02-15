---
title: "Javaのソースファイルはpackageに対応したディレクトリ階層に置かなくても良い？"
date: 2020-05-29T08:28:07Z
draft: false
tags:
  - java
---

<https://twitter.com/hishidama/status/1266176675768745984>

> packageの宣言と実際のディレクトリが一致していなくてもmvn compile（やjavac）が成功するんですが、そういうもんでしたっけ？

> classファイルのパッケージと実際のディレクトリーは対応させないといけないんですけど、ソースファイルについてはそういう制限は無いんですよね。でもけっこう勘違いされているような＾＾；

この辺の話が正当かどうか、という話です。

`javac` のリファレンス、 [Arrangement of Source Code](https://docs.oracle.com/en/java/javase/14/docs/specs/man/javac.html#arrangement-of-source-code) セクションには次のように書かれています:

> In the Java language, classes and interfaces can be organized into packages, and packages can be organized into modules. javac expects that the physical arrangement of source files in directories of the file system will mirror the organization of classes into packages, and packages into modules.

また、 [The Java™ Tutorials \> Managing Source and Class Files](https://docs.oracle.com/javase/tutorial/java/package/managingfiles.html) では、

> Many implementations of the Java platform rely on hierarchical file systems to manage source and class files, although The Java Language Specification does not require this.

ちゃんと読んでないですが The Java® Language Specification だと [7.2. Host Support for Modules and Packages](https://docs.oracle.com/javase/specs/jls/se14/html/jls-7.html#jls-7.2) 辺りが該当するのでしょうか。

そんなわけで、(ソースファイルだけでなく)クラスファイルもディレクトリ階層とパッケージを対応付けているのは仕様に拠るものではない、ただし各種実装はそのようにファイルが配置されていることを期待しているのでそれに従いましょう、ということですね。

ソースファイルがどうでもよくてクラスファイルは従わなくてはならないのは「たまたま実装がそうなっているから」だ、ということのようです。

ちなみに `java` コマンドの [source-file mode](https://docs.oracle.com/en/java/javase/14/docs/specs/man/java.html#using-source-file-mode-to-launch-single-file-source-code-programs) については、ディレクトリ階層は関係ないぜ、ってのが例から読み取れますね。
