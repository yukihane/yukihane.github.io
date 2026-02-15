---
title: "${...}と#{...}の違い"
date: 2020-07-02T00:31:47Z
draft: false
tags:
  - spring-boot
---

- [Spring Expression Language (SpEL) with @Value: dollar vs. hash (\$ vs. \#)](https://stackoverflow.com/a/5322737/4506703)

より。

`${…​}` は単なるプロパティのプレースホルダ。

`#{…​}` は [Spring Expression Language(SpEL)](https://docs.spring.io/spring/docs/current/spring-framework-reference/core.html#expressions) の構文。

プレースホルダは置き換えるだけだけれども、SpELはもっと複雑なこともできる(Javaのメソッドを呼び出したりとか)。
