---
title: Java9以降.propertiesファイルをUTF-8で書けるようになった、は正しい？
date: 2019-04-27T20:08:10Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java]
# images: []
# videos: []
# audio: []
draft: false
---

# 解答

正しくない。

- Java9([JEP226](https://bugs.java.com/bugdatabase/view_bug.do?bug_id=8043553))で変わったのはリソースバンドルの取り扱い([PropertyResourceBundle](https://docs.oracle.com/javase/jp/9/docs/api/java/util/PropertyResourceBundle.html)) であって プロパティファイル `.properties` 全般の話ではない。
- プロパティファイル`.properties`の文字エンコーディングについての取り決めはない。それを取り扱うプログラム次第であり`UTF-8`を正しく認識してくれるとは限らない。
  - 標準 API で `UTF-8`として(読もうと思えば)読めるようになったのは **1.6** からであって **9** からではない。ちなみに 1.5 以前は `ISO 8859-1` 前提。

# 背景

私はうろ覚えで何となく、現在の Java では `.properties` ファイルを `UTF-8` で書ける、`ascii2native`は過去の遺物になった、のだと思いこんでいました。
ところが Spring Boot の `application.properties` に `UTF-8` で日本語を書いたところ文字化けしてしまい、あれ、もしかして自分の理解が間違っているのかと思い調べ直したのがこの記事です。

- [Read application.properties using ISO 8859-1 #10565](https://github.com/spring-projects/spring-boot/pull/10565)
  - (このプルリクのコメントでも、まさに私と同じ勘違いをされてる方がいらっしゃいます)

この勘違いはおそらく自分だけではないと考えています。
例えば "JEP226" で検索すると日本語非日本語ともに "**JEP 226: UTF-8 Property Files**" と紹介されている記事がヒットしますし(ちなみに少なくとも現在のオフィシャルなタイトルは "[JEP 226: UTF-8 Property Resource Bundles](https://bugs.java.com/bugdatabase/view_bug.do?bug_id=8043553)"だと思うんだけど、これだけみんな Property Files Property Files 書いてるってことは途中で変わったの？)、 `.properties` ファイルを読み込む API は [ResourceBundle.getBundle](https://docs.oracle.com/javase/jp/9/docs/api/java/util/ResourceBundle.html#getBundle-java.lang.String-)だ、的な説明が検索結果で上位に出たり、ということから想像できます。

# 説明

リソースバンドルを取得する際に用いるメソッド[ResourceBundle#getBundle](<https://docs.oracle.com/javase/jp/12/docs/api/java.base/java/util/ResourceBundle.html#getBundle(java.lang.String)>) では [`InputStream` を引数に取る `PropertyBundle` コンストラクタ](<https://docs.oracle.com/javase/jp/12/docs/api/java.base/java/util/PropertyResourceBundle.html#%3Cinit%3E(java.io.InputStream)>)が用いられますが、このときの `InputStream` の `charset` が `UTF-8` であるとみなすように **バージョン 9** から変更されています。

他方、 [プロパティを`InputStream`からロードするメソッド `Properties#load(InputStream)`](<https://docs.oracle.com/javase/jp/12/docs/api/java.base/java/util/Properties.html#load(java.io.InputStream)>) の `InputStream` の `charset` は従来と変わらず `ISO 8859-1` が前提です。

なおどちらにも `InputStream`型でなく`Reader`型を引数に取るものが **バージョン 1.6** から用意されており、そちらを用いれば JDK に指定されているエンコーディング以外のリソースも読めます。
