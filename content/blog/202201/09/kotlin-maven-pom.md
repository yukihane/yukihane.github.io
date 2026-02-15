---
title: "Kotolin のプロジェクトを Maven で作成する"
date: 2022-01-09T14:41:04+09:00
draft: false
tags:
  - kotlin
---

入門書を一通り読み終えたのでサンプルプロジェクトを作成しようと思いました。

JetBrains がメンテナンスしている archetype が利用できそうです。

- <https://search.maven.org/artifact/org.jetbrains.kotlin/kotlin-archetype-jvm>

<!-- -->

    mvn archetype:generate -DarchetypeGroupId=org.jetbrains.kotlin -DarchetypeArtifactId=kotlin-archetype-jvm

IntelliJ IDEA から作成した場合も似た感じの `pom.xml` が作成されるかなと思います。

Java と併存する場合は、公式リファレンスの記述が参考になります:

- [Maven \> Compile Kotlin and Java sources](https://kotlinlang.org/docs/maven.html#compile-kotlin-and-java-sources)

JDK17を利用して開発する場合、次の設定変更を `pom.xml` 対して行います:

1.  [`maven-compiler-plugin`](https://maven.apache.org/plugins/maven-compiler-plugin/) のバージョンを最新版に上げます。

    - この記事を書いた時点の最新バージョンは `3.10.1` でした

    - 前述Kotlin公式サイトに書かれているサンプルは `3.5.1` とかなり古く、 Java17 に対応していません

2.  `properties` セクションに次を追記します。

        <properties>
            <java.version>17</java.version>
            <maven.compiler.target>${java.version}</maven.compiler.target>
            <maven.compiler.source>${java.version}</maven.compiler.source>
            <kotlin.compiler.jvmTarget>${java.version}</kotlin.compiler.jvmTarget>
        </properties>

    - 参考

      - [IntelliJ: Error:java: error: release version 5 not supported](https://stackoverflow.com/a/59607812/4506703)

      - [Attributes specific to JVM](https://kotlinlang.org/docs/maven.html#attributes-specific-to-jvm)

また、 [Spring Initializr](https://start.spring.io/) の Kotlin 用プロジェクト雛形も参考になります。 次のリンク先に解説もあります:

- [Building web applications with Spring Boot and Kotlin](https://spring.io/guides/tutorials/spring-boot-kotlin/)

書いてあることを要約すると:

- Kotlin クラスをデフォルトで 非 `final` にする ([all-open compiler plugin](https://kotlinlang.org/docs/all-open-plugin.html))

  - クラスのプロキシ化するのには継承可能でなければいけない。 AOP や mocking で必要。

  - test のときだけ mocking 用に非 `final` にする、みたいな使い方はできなさそう…？

- 特定のアノテーション(例えば JPA の `@Entity`)が付与されたクラスに引数なしコンストラクタを生成する([no-arg compiler plugin](https://kotlinlang.org/docs/no-arg-plugin.html))

- `-Xjsr305=strict` で null 可能性に関するアノテーション有効化 ([JSR-305 support](https://kotlinlang.org/docs/java-interop.html#jsr-305-support))

- Kotlin 用の Mockito ライクなライブラリ [SpringMockK](https://github.com/Ninja-Squad/springmockk/) というものがあり、 Spring ではこれを推している(※ Spring 公式ライブラリではない)
