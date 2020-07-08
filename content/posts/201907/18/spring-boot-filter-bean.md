---
title: Spring Bootは、セキュリティフィルタBeanを作っている分だけ、無料で認証できちまうんだ
date: 2019-07-18T20:34:56Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java]
# images: []
# videos: []
# audio: []
draft: false
---

# 要約

[78.10 Add a Servlet, Filter, or Listener to an Application](https://docs.spring.io/spring-boot/docs/2.1.6.RELEASE/reference/html/howto-embedded-web-servers.html#howto-add-a-servlet-filter-or-listener)曰く。

> any `Servlet` or `Filter` beans are registered with the servlet container automatically.

Spring Security 使った自前の認証フィルタを `@Component` 付けて作ったりなんかした際に意図しない URL path にも認証がかかってしまう。
んゴ。

# 困ってる実例集

- [Add an annotation to exclude Filter @Beans from registration #16500](https://github.com/spring-projects/spring-boot/issues/16500) - spring-projects/spring-boot
- [Spring Boot with Spring Security の Filter 設定とハマりポイント](https://qiita.com/R-STYLE/items/61a3b6a678cb0ff00edf) - Qiita
- サンプルコード: https://github.com/yukihane/hello-java/tree/master/spring/filter-auto-registration-example
  - 手順 4.のコミット時点のコードで既にフィルタが有効化されてしまっている

# 対策

どちらかで対策できる。

- フィルタを Bean として作成しない
- [Disable Registration of a Servlet or Filter](https://docs.spring.io/spring-boot/docs/2.1.6.RELEASE/reference/html/howto-embedded-web-servers.html#howto-disable-registration-of-a-servlet-or-filter)の説明に従う: `FilterRegistrationBean#setEnabled(false)`
  - 前述のコードで[例示](https://github.com/yukihane/hello-java/commit/6f0c001)
