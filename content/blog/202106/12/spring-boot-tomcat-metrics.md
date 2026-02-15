---
title: "Spring Boot で Tomcat のメトリクスを出力する"
date: 2021-06-12T10:07:19Z
draft: false
tags:
  - spring-boot
  - tomcat
---

Spring Boot アプリケーションの性能評価を行っているのですが、実装したアプリケーション部分ではなく、webサーバかどこかがパフォーマンスボトルネックになっているように思われる事象に直面し、その原因を調べたいと思っています。

- [【真夏の夜のミステリー】Tomcatを殺したのは誰だ？：現場から学ぶWebアプリ開発のトラブルハック（6）（2/3 ページ） - ＠IT](https://www.atmarkit.co.jp/ait/articles/0708/27/news098_2.html)

に書かれていることに近い状況になっているのでは、と考えたのですが、実際どういう状況なのか確認したい、メトリクスをログ出力したい、と調べたところ、同じように考えられている記事がありました。

- [Spring Boot Actuatorで、Micrometerで収集したメトリクスをログに出力する - CLOVER🍀](https://kazuhira-r.hatenablog.com/entry/2021/05/03/230700)

[`LoggingMeterRegistry`](https://github.com/micrometer-metrics/micrometer/blob/main/micrometer-core/src/main/java/io/micrometer/core/instrument/logging/LoggingMeterRegistry.java) というクラスがビルトインされているので、これを利用すれば良いです。

なお、 `LoggingMeterRegistry` に対するプロパティ設定は [用意されていない](https://micrometer.io/docs/ref/spring/1.5#_application_properties) ようでした(ので必要に応じて自前で用意します)。

あとは、Tomcatのメトリクスを出力するために、プロパティに以下の設定を行えばOKです。

    # https://docs.spring.io/spring-boot/docs/2.5.1/reference/html/actuator.html#actuator.metrics.supported.tomcat
    server.tomcat.mbeanregistry.enabled=true

サンプル実装はこちら: <https://github.com/yukihane/hello-java/tree/master/spring/tomcat-monitoring-example>
