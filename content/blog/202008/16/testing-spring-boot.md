---
title: "Spring Bootアプリケーションの自動テストを書く"
date: 2020-08-16T08:42:29Z
draft: true
tags:
  - spring-boot
  - testing
---

Spring Boot 2.3.3 を対象に、テストコードの書き方について説明します。

# 参照すべき公式リファレンス

参照すべきリファレンスがSpring Bootのものに留まらない、という点に注意が必要です。

- [4.26. Testing](https://docs.spring.io/spring-boot/docs/2.3.3.RELEASE/reference/htmlsingle/#boot-features-testing) - Spring Boot Reference Documentation

- [Testing](https://docs.spring.io/spring/docs/5.2.8.RELEASE/spring-framework-reference/testing.html#testing) (Spring Framework リファレンス)

- [3. Testing](https://docs.spring.io/spring/docs/5.2.8.RELEASE/spring-framework-reference/web.html#testing) - Web on Servlet Stack (Spring MVC リファレンス)

- [19. Testing](https://docs.spring.io/spring-security/site/docs/5.3.4.RELEASE/reference/html5/#test) - Spring Security Reference

- [Using @MybatisTest](http://mybatis.org/spring-boot-starter/mybatis-spring-boot-test-autoconfigure/) - `mybatis-spring-boot-test-autoconfigure` リファレンス

# 自動テストの種類

ここで自動テストを分類する目的は次の通りになります:

- 実行にかかる時間が長いものと短いものを分けて管理したい。

  - テストに時間がかかるようになると億劫になって全てスキップしてしまいがち。

  - 全テストを毎回通すのが困難でも、即終わるテストセットだけ分離しておけば、最低限それは通す、というような用法が可能。

- 実行するために特定環境が必要なものを分けて管理したい。

  - 例えばDBが必要でないテストと必要なテストを分けておけば、DB接続できない環境ではDB不要テストだけ実行する、というような実行方法も可能になる。

上記のような観点を考慮し、テストを実行する上で必要となる環境に応じて、次の通り自動テストを分類することにします [^1]。

## IoC コンテナ外テスト `test`

次の条件を満たすテストをコンテナ外テストと呼称することにします。

- IoC コンテナを利用しない

- DBや外部サービスなどに接続しない(そのようなアクセスはモック化される)

いわゆるユニットテスト(unit testing)に近い概念です。

## IoC コンテナ利用テスト

IoC コンテナを利用するテストは必要な環境に応じて更に次の通り更に分類します。

### 外部サービスモック化テスト `inContainerTest`

テストに必要となる外部サービスをモック化して行うテスト。 外部サービスをモック化するため、実行環境を選びません。

### 外部サービス依存テスト `realEnvTest`

DBや外部サービスに実際に接続して行うテスト。 接続先のサービスが利用可能でなければならないので、実行できる環境が限定されます。

# 各テスト向けセットアップ

次の手順通り作業を進めます。 なお、本節は次のリファレンスを参考にしています:

- [Configuring integration tests](https://docs.gradle.org/current/userguide/java_testing.html#sec:configuring_java_integration_tests) - Testing in Java & JVM projects - Gradle 6.6 User Manual

## `build.gradle` 編集

デフォルトでは `test` のみ認識される状態なので、2種類の追加テストも認識されるように次の記述を追記します [^2]:

<div class="formalpara-title">

**build.gradle**

</div>

``` groovy
sourceSets {
    inContainerTest {
        compileClasspath += sourceSets.main.output
        runtimeClasspath += sourceSets.main.output
    }
    realEnvTest {
        compileClasspath += sourceSets.main.output
        runtimeClasspath += sourceSets.main.output
    }
}

configurations {
    inContainerTestImplementation.extendsFrom implementation
    inContainerTestRuntimeOnly.extendsFrom runtimeOnly
    realEnvTestImplementation.extendsFrom implementation
    realEnvTestRuntimeOnly.extendsFrom runtimeOnly
}
```

## テスト分類ごとにディレクトリを作成

次の3ディレクトリを作成します

- `src/test/java`

- `src/test/`

[^1]: ちなみに、この分類命名は私が考えたものであり、一般的に通用するものではないことに注意してください

[^2]: Spring Boot の `build.gradle` には `configurations` が既に存在するので、実際には既存のものとマージして記述しました。
