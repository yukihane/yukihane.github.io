---
title: "GradleでSpring Bootプロジェクトを作成してSTS(Eclipse)でインポートする手順"
date: 2020-07-25T18:11:15Z
draft: false
tags:
  - spring-boot
  - eclipse
  - gradle
---

# はじめに

[Spring Initializr](https://start.spring.io/)を使ってGradle形式でプロジェクトを作成した場合、どうやってSTS(Eclipse)へインポートするのか逡巡しました。

[公式](https://github.com/eclipse/buildship/wiki/Migration-guide-from-STS-Gradle-to-Buildship)では Buildship 推しのように見えるのですが、Buildshipを使うと[annotation processorの設定がまるっと落ちてしまい](https://github.com/eclipse/buildship/issues/329)Eclipse上で改めて手動設定が必要になってしまいます。

結局、上記リンク先でも示唆されている通り、 [`com.diffplug.eclipse.apt`](https://plugins.gradle.org/plugin/com.diffplug.eclipse.apt) プラグインを利用するのが最も無難なように思われます。(なお、 `net.ltgt.apt-eclipse` を薦めている記事などが存在しますが、これはもはやdeprecatedで、代わりにforkしてメンテが続けられているのが `com.diffplug.eclipse.apt` らしいです)

# 手順

[Spring Initializr](https://start.spring.io/) で作成した `build.gradle` を開き、冒頭の `plugins` セクションに [`eclipse`](https://docs.gradle.org/current/userguide/eclipse_plugin.html) と [`com.diffplug.eclipse.apt`](https://plugins.gradle.org/plugin/com.diffplug.eclipse.apt) を追加します。

    plugins {
      id 'org.springframework.boot' version '2.3.2.RELEASE'
      id 'io.spring.dependency-management' version '1.0.9.RELEASE'
      id 'java'
      id 'eclipse'
      id 'com.diffplug.eclipse.apt' version '3.23.0'
    }

次に下記コマンドを実行し、Eclipseのプロジェクト構成ファイル群を生成します。

``` bash
gradle build cleanEclipse eclipse
```

`eclipse` プラグインは、実行した時点で存在しないディレクトリは無視するようになっているようです。そのため上記では一旦 `build` を行って自動生成ディレクトリなどを確実に作成するようにしています。

そして、Eclipseでインポートします。このとき選択するのは **Existing Projects into Workspace** です。Existing Gradle Projectではないことに注意してください(こちらを選ぶとBuildshipでインポートされ、annotation processorの設定が行われません)。

Gradleの設定を変更した場合は、 `gradle cleanEclipse eclipse` コマンドを実行し直し、インポートし直せばよいかと思います。

なお、Gradleが出力するディレクトリ(`/build`)と、Eclipseが出力するディレクトリ(`/bin`, `.apt_generated` など)が異なるのは敢えてそうなっているようです。 Maven を利用し続けてきた身からすると違和感がありますが、問題が起きたときの切り分けのしやすさ的にはこちらの方が良いですよね。

# サンプルコード

MapStructを利用し、アノテーションプロセッサにオプションを渡すサンプルです。

- <https://github.com/yukihane/hello-java/tree/master/spring/gradle-eclipse-example>
