---
title: "Spring BootのGradleでのデバッグ実行方法"
date: 2020-06-15T07:42:25Z
draft: false
tags:
  - spring-boot
  - gradle
---

    gradle bootRun --debug-jvm

というように、`--debug-jvm` オプションを付与すれば良いようです。 これで、デバッガ接続の待受状態で起動します。

[`BootRun`](https://docs.spring.io/spring-boot/docs/current/gradle-plugin/api/org/springframework/boot/gradle/tasks/run/BootRun.html) は [`JavaExec`](https://docs.gradle.org/current/javadoc/org/gradle/api/tasks/JavaExec.html) を継承していますが、この `--debug-jvm` は後者のリファレンスで言及されています。

なおMavenでの方法は [こちら](https://docs.spring.io/spring-boot/docs/2.2.4.RELEASE/maven-plugin/examples/run-debug.html) 。

関連リンク:

- [IDEなしでKotlinで書いたSpring Bootをデバッグしたい](https://ja.stackoverflow.com/q/67681/2808) - スタック・オーバーフロー
