---
title: "Gradleプロジェクトではリソースファイルを編集してもAutomatic Restartしてしまう"
description: ""
date: 2024-10-20T14:51:14+09:00
draft: false
weight: 0
enableToc: false
tocLevels: ["h2", "h3", "h4"]
tags: ["gradle", "spring-boot"]
---

- [Devtools always triggers restart if build with gradle - spring-projects/spring-boot #20136](https://github.com/spring-projects/spring-boot/issues/20136)
  - [Delegated build process always triggers Spring-Boot devtools restart - gradle/gradle #12220](https://github.com/gradle/gradle/issues/12220)

にある通りですが。

spring-boot-devtools の説明では、クラスのリロードが必要になった場合それを検知して自動的に再起動するが、Thymeleaf テンプレートや css などの static リソースファイルが変更された場合は再起動しない、とあります。

しかし Gradle プロジェクトの場合、templates や static ディレクトリ以下のファイル変更でも再起動されてしまいます。

Eclipse や IntelliJ IDEA といった IDE を利用している場合、IDE の機能でデバッグ実行時クラスの hot swapping もできますので再起動機能は余計なお世話です。機能を無効化してしまいましょう。
起動時、JVM options に次の引数を追加します:

```
-Dspring.devtools.restart.enabled=false -Dspring.thymeleaf.cache=false
```
(devtools を組み込めばテンプレートのキャッシュはされなくなるように読めましたが、やってみるとキャッシュされてしまっているようなのでキャッシュ無効化オプションも付けています)

開発用にプロファイルを作っているのであれば、 `application-*.yml` に設定してしまっても良いかもしれません。

参考:

- [Hot Swapping :: Spring Boot](https://docs.spring.io/spring-boot/how-to/hotswapping.html)
- [Developer Tools :: Spring Boot](https://docs.spring.io/spring-boot/reference/using/devtools.html)
