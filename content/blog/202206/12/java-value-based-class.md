---
title: "Java における value objects"
date: 2022-06-12T05:56:40+09:00
draft: false
tags:
  - java
---

Java 標準 API のドキュメントには、 "値ベース・クラス" というページがあります:

- <https://docs.oracle.com/javase/jp/17/docs/api/java.base/java/lang/doc-files/ValueBased.html>

機械翻訳っぽくて分かりづらい箇所もあるので、併せて [Java8 版](https://docs.oracle.com/javase/jp/8/docs/api/java/lang/doc-files/ValueBased.html) や [英語版](https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/doc-files/ValueBased.html) も見てみると良いかもです。

現在の Java [^1] における value objects は、この値ベース・クラスの要件に沿ったクラスをインスタンス化したもの、と考えて良さそうに思いました。次の点が注目ポイントでしょうか:

- インスタンスフィールドは `final`

- `==`, `!=` を用いて比較してはいけない。 インスタンスフィールドの値で比較する(`equals()` をそのように実装して、それを用いる)。

[前回]({{< relref"/blog/202206/11/value-object" >}})触れた、 [Wikipedia](https://ja.wikipedia.org/wiki/Value_object#Java) の Java の項に書かれていることですね。

ちなみに、 Java16 以降では、JDK の中の値ベース・クラスに相当するクラスには [`jdk.internal.ValueBased` アノテーション](https://github.com/openjdk/jdk/blob/jdk-17+35/src/java.base/share/classes/jdk/internal/ValueBased.java)が付与されているようです(このアノテーションの目的は [JEP390](https://openjdk.java.net/jeps/390) にあります。 Project Valhalla の準備として、不適切に利用されている箇所でコンパイル時に警告するためのようです)。

[^1]: [Project Valhalla](https://openjdk.java.net/projects/valhalla/) 導入後はまた話が変わるはずです。
