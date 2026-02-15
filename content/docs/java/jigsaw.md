---
title: "Jigsaw"
date: 2020-07-23T18:32:39Z
draft: false
---

# 参考リンク

## Webサイト

- [Project Jigsaw: Quick Start Guide](http://openjdk.java.net/projects/jigsaw/quick-start) - OpenJDKのページ

- [Java 9のモジュール機能「Project Jigsaw」の基本を紹介 (1/2)：CodeZine（コードジン）](https://codezine.jp/article/detail/10524)

- [Java 9 - Jigsaw - Apache Maven - Apache Software Foundation](https://cwiki.apache.org/confluence/display/MAVEN/Java+9+-+Jigsaw) - MavenプラグインのJava9対応状況

## 書籍

- [Java 9 Modularity](http://shop.oreilly.com/product/0636920049494.do) - Oreilly

- [The Java Module System](https://www.manning.com/books/the-java-module-system) - Manning

# 自分が行った学習手順

- [前述OpenJDKサイトのQuick Startのページ](http://openjdk.java.net/projects/jigsaw/quick-start)を見て概要をつかむ。

  - 最初は **Services** 節くらいまで読めば良いように思う(実際のところ **The linker** (jlink)など使用する機会はそう無いのでは)。

- Mavenでの利用方法がわからなかったので書籍http://amzn.to/2CLmjCm\[Java 9 Modularity\]の11章を流し読みする。従来と使用方法は変わらないようだった。

  - コードはhttps://github.com/java9-modularity/examples/tree/master/chapter11\[こちら\]にある。これだけ見ても概ね理解できるはず。

# module-info.java 内で使用するキーワード

JLS 7.7 Module Declarations ([HTML版](https://docs.oracle.com/javase/specs/jls/se9/html/jls-7.html#jls-7.7), [PDF Jigsaw差分表記版](http://cr.openjdk.java.net/~mr/jigsaw/spec/java-se-9-jls-diffs.pdf))より。

既に次のページに日本語解説があったのでそちらも参照のこと。

- [Java9 Project Jigsawのモジュールがわからないので調べた - Qiita](https://qiita.com/skht777/items/81f00f1890a7311b9e07)

- <http://www.torutk.com/projects/swe/wiki/Java%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E3%82%B7%E3%82%B9%E3%83%86%E3%83%A0#%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB%E5%AE%9A%E7%BE%A9%E3%83%95%E3%82%A1%E3%82%A4%E3%83%ABmodule-infojava%E3%81%AE%E4%BB%95%E6%A7%98>\[Javaモジュールシステム

  - ソフトウェアエンジニアリング - Torutk\]

<!-- -->

    ModuleDeclaration:
    {Annotation} [open] module Identifier {. Identifier}
    { {ModuleDirective} }

- \`open\`を指定していない場合(ノーマルモジュールの場合)、コンパイル時、実行時ともに明示的にexportされたパッケージのみ参照を許可する。\`open\`を指定した場合(オープンモジュールの場合)、コンパイル時には明示的にexportされたパッケージのみ参照を許可する(この点はノーマルモジュールと同様)。実行時は、ノーマルモジュールと異なり、全パッケージの参照を許可する。

  - \`open\`はリフレクションによるアクセスを想定した仕様の模様。詳細はJLS 7.7節参照。

  - 後述の\`opens\`モジュールディレクティブはパッケージごとの指定だが、オープンモジュールにすれば全パッケージが対象になる、ということのようだ。

<!-- -->

    ModuleDirective:
    requires {RequiresModifier} ModuleName ;
    exports PackageName [to ModuleName {, ModuleName}] ;
    opens PackageName [to ModuleName {, ModuleName}] ;
    uses TypeName ;
    provides TypeName with TypeName {, TypeName} ;

- モジュールディレクティブについては次節にまとめた。

<!-- -->

    RequiresModifier:
    (one of)
    transitive static

- 後述の\`requires\`モジュールディレクティブ説明の中で言及。

## モジュールディレクティブ

### requires

- 依存先(自身が参照しているモジュール)を指定するディレクティブ。

- \`java.base\`は自動で設定されるので明記してはいけない。

- `transitive`: 自身をrequireしたモジュールは、\`requires transitive\`で指定しておいたモジュールもrequireしたことになる。つまり、\`requires transitive\`で指定したモジュールも暗黙的に使用可能になる。

- `static`: \`requires static\`は、コンパイル時には必要だが実行時には必ずしも必要でないモジュールに対して記述する。

  - 書籍「Java 9 Modularity」5.6.1節 "Compile-Time Dependencies" では、コンパイル時のアノテーションプロセッシング(のみ)に必要なモジュールを指定するような例が書かれていた。

### exports, opens

- \`exports\`にはコンパイル時及び実行時にアクセスを許可するパッケージを記述する。

- \`opens\`には実行時にアクセスを許可するパッケージを記述する。コンパイル時には許可しないのが\`exports\`と異なる。

  - 前述の\`open\`によるオープンモジュール指定の、パッケージ個別指定版のようなものか。

- `exports`, \`opens\`ともに\`to\`で特定のモジュールに対してのみアクセスを許可するような設定が可能。

### uses

- \`java.util.ServiceLoader\`を用いてロード可能なサービスの記述に用いる。

- こちらのサイトが詳しい: <http://d.hatena.ne.jp/bitter_fox/20160720/1469042323>\[JigsawでSPIを使用する

  - きつねとJava！\]

- [ServiceLoaderのJavaDoc](https://docs.oracle.com/javase/jp/9/docs/api/java/util/ServiceLoader.html)も参考になる。

### provides *\[service\]* with *\[service provider\]*

- サービスプロバイダの記述に用いる。

- サービスプロバイダとは、\`uses\`節で記載した、サービスを継承/実装した具象クラス。

- こちらについても\`uses\`節で記載したリンク先を読むべし。

# ビルドツール等の対応

## Maven Compiler Plugin

- configuration で [release](https://maven.apache.org/plugins/maven-compiler-plugin/compile-mojo.html#release) (9のjavacコマンドで使用できるオプション。 [参考](http://vividcode.hatenablog.com/entry/java/javac-release-flag)) が利用できるようになっている。

## Exec Maven Plugin

java9に対応した [modulepathの指定、実行クラスの指定](http://www.mojohaus.org/exec-maven-plugin/examples/example-exec-for-java-programs.html#In_case_of_the_modules_as_supported_since_Java9_the_configuration_looks_like)ができるようになっている。
