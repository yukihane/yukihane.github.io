---
title: "LombokとMapStructをEclipseで併用しようとした際の不具合がMapStruct1.4.0で解消されていた"
date: 2020-07-28T12:06:03Z
draft: false
tags:
  - java
  - eclipse
---

これまで、LombokとMapStructを併用しようとした場合、そのままだと不具合(MapStructのアノテーションプロセッシングが動作しない)があり、ちょっとひと手間かけてその不具合を回避する必要がありました。

- [Lombokプラグインを入れているEclipseでMapStruct自動生成が機能しない](https://himeji-cs.jp/blog2/blog/2019/08/eclipse-lombok-mapstruct.html) - 発火後忘失

この問題について、久しぶりにIssueを確認してみたところ進展がありました。曰く、 `1.4.0.Beta1` で修正された、とのこと。

- [Mapstruct, Lombok, Maven & Eclipse \#1159](https://github.com/mapstruct/mapstruct/issues/1159#issuecomment-643602302)

試しに [現時点での最新リリースバージョンである `1.4.0.Beta3`](https://github.com/mapstruct/mapstruct/releases)を利用してみたところ、確かに記載通りひと手間無しにそのままでLombokもMapStructも想定通り動くようになっていました！

追記: 本文記載からまた状況は変わって、現在は [v1.18.16のchangelog](https://projectlombok.org/changelog)にあるとおり、 [`lombok-mapstruct-binding`](https://search.maven.org/artifact/org.projectlombok/lombok-mapstruct-binding) を依存関係に追加することで問題を解消するような対応になっていました。 [参考]({{< relref"/blog/202011/14/mapstruct-with-spring-boot-2.3.5" >}})
