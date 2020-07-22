---
title: Java9でJettyでJerseyのMaven
date: 2018-01-28T19:16:07Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java, jetty, jersey]
# images: []
# videos: []
# audio: []
draft: false
---

dependency について、[2.3.2. Servlet based server-side application](https://jersey.github.io/documentation/latest/modules-and-dependencies.html#servlet-app-general)をみると最小構成は`jersey-container-servlet`だけでいいように見える(Servlet3.0 以降の場合)が、実際には`jersey-hk2`も必要。含めない場合次の例外が発生する。

> java.lang.IllegalStateException: InjectionManagerFactory not found.

[1.1. Creating a New Project from Maven Archetype](https://jersey.github.io/documentation/latest/getting-started.html#new-from-archetype)に記載されている archetype を使ってプロジェクトを生成してみても依存関係にちゃっかり入っている。

検索した感じ、バージョン 2.26(これを書いている時点での最新バージョン)以降の症状かも知れない。

    <dependency>
      <groupId>org.glassfish.jersey.containers</groupId>
      <artifactId>jersey-container-servlet</artifactId>
      <version>${jersey.version}</version>
    </dependency>
    <dependency>
      <groupId>org.glassfish.jersey.inject</groupId>
      <artifactId>jersey-hk2</artifactId>
      <version>${jersey.version}</version>
    </dependency>

次に、Java9 では Java EE 関連のモジュールがデフォルトではロードされなくなったため、Jersey を使った JAX-RS(REST)プログラムを`mvn jetty:run`で実行しようとすると次の例外が出る。

> java.lang.NoClassDefFoundError: javax/activation/DataSource

また、次も発生。

> java.lang.NoClassDefFoundError: javax/xml/bind/PropertyException

それぞれ解消するために `--add-modules java.activation,java.xml.bind` オプションを付与する。Maven で実行する場合は、 `MAVEN_OPTS` 環境変数に設定しておけばランタイム実行パラメータとなる。

マイグレーションガイドの[Modules Shared with Java EE Not Resolved by Default](https://docs.oracle.com/javase/9/migrate/toc.htm#JSMIG-GUID-F640FA9D-FB66-4D85-AD2B-D931174C09A3)にある通り、`--add-modules java.se.ee`の方が簡単で覚えやすいかもしれない。

    MAVEN_OPTS="--add-modules java.activation,java.xml.bind" mvn jetty:run
