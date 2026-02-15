---
title: "`WebClient` の 覚書"
date: 2020-07-19T23:26:51Z
draft: false
tags:
  - spring-boot
---

`RestTemplateBuilder` の `Bean` がsingleton-socpeかつちょっと変態的なインスタンス生成を行っていたので驚いた、というエントリを昔書きました:

- [RestTemplateBuilderに関する覚書](https://yukihane.github.io/posts/201912/10/resttemplatebuilder/)

ところで、現時点で [`RestTemplate` は既に maintenance mode](https://docs.spring.io/spring-framework/docs/5.2.7.RELEASE/javadoc-api/org/springframework/web/client/RestTemplate.html) なので、新規実装に用いるのは忍びないなあ、と思い、 `WebClient` を利用する前提で薦めることにしました。

- 利用するには `spring-boot-starter-webflux` を依存関係に追加する。([4.16.1. WebClient Runtime](https://docs.spring.io/spring-boot/docs/2.3.1.RELEASE/reference/htmlsingle/#boot-features-webclient-runtime))

  - なお、Spring MVC と Spring WebFlux が同居する場合、デフォルトで Spring MVC が有効化されるhttps://docs.spring.io/spring-boot/docs/2.3.1.RELEASE/reference/htmlsingle/#boot-features-web-environment\[4.1.8. Web Environment\])。

- `RestTemplateBuildr` と異なり `WebClient.Builder` クラスは Spring Boot所属のクラスではない

- `WebClientAutoConfiguration` によってインジェクトされる `Builder` は prototype-scope。

`RestTemplateBuilder` は singlton-scopeで何か設定を与える度にインスタンスを生成し直して…みたいな歪な感じになっていたのに対し、こちらは素直なものになっているようです。
