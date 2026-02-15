---
title: "Maven Wrapper が Maven3 に正式導入された"
date: 2022-06-11T10:36:51+09:00
draft: false
tags:
  - maven
---

Gradle には [Gradle Wrapper](https://docs.gradle.org/current/userguide/gradle_wrapper.html) といって、 ビルドするためのツールである Gradle の該当バージョンがローカルにインストールされていない場合でも、自動で取得してビルド環境をセットアップしてくれる仕組みがあります。

これに影響を受けて、 [Maven Wrapper](https://github.com/apache/maven-wrapper) というプラグインを作成されていた方がいらっしゃったのですが、 Maven4 で公式に取り込まれることになっていました。

…​が、どうやら前倒しで [Maven3 にも取り込まれる](https://maven.apache.org/wrapper/) ようになったようです。 現時点で次のコマンドでセットアップすることができるようになっています。

    mvn wrapper:wrapper

[Spring Boot Initializr](https://start.spring.io/) で作成したプロジェクトでは昔からテンプレートに含まれていたので存在を知っていた人は多いかと思うのですが、実は Maven 本体の機能では無かったんですよねこれ。

Maven は Gradle ほどツールのバージョン依存性は無い(バージョン間の互換性が高いしメジャーバージョンアップもそんなに無い)ので Gradle ほどの必要性は無いですが、まあ、有ったほうが嬉しいには違いない。
