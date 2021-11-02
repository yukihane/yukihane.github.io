---
title: ちょっと待って！そのUserDetails、本当に必要ですか？
date: 2019-07-03T21:55:20Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [spring-security]
# images: []
# videos: []
# audio: []
draft: false
---

# 概要

Spring Boot の認証を実装してみた系のサンプルでよく `UserDetails` や `UserDetailsService` が用いられているが、必然性が不明なものがほとんどである。
(おそらく当の実装者も理解していない[^1]。)

[^1]: もちろん私もそんなコードを理解できません。

ここでは `UserDetails` を使わない、よりシンプルな認証を実装してみた。

# 参考リンク

- [Spring Security Architecture](https://spring.io/guides/topicals/spring-security-architecture/) の Authentication and Access Control
  - [TERASOLUNA のリファレンス](http://terasolunaorg.github.io/guideline/5.5.1.RELEASE/ja/Security/Authentication.html#id3)なら日本語で読める！
- [6.8.4 Overriding or Replacing Boot Auto Configuration](https://docs.spring.io/spring-security/site/docs/5.1.5.RELEASE/reference/htmlsingle/#oauth2resourceserver-sansboot) - Spring Security Reference

# 実装サンプル

- [`tags/simple-authentication-example` タグ](https://github.com/yukihane/hello-java/tree/tags/simple-authentication-example/spring/spring-security-auth-example)
  - user テーブルを select して id/password を検証するバージョンは[`tags/simple-authentication-db-example` タグ](https://github.com/yukihane/hello-java/tree/tags/simple-authentication-db-example/spring/spring-security-auth-example)

# 解説

参考リンク先にある通り、自分で認証処理を作りたい場合、 `AuthenticationProvider` を実装してそれを用いるように設定すれば良い。

サンプルコードでは、 [MyAuthenticationProvider](https://github.com/yukihane/hello-java/blob/tags/simple-authentication-example/spring/spring-security-auth-example/src/main/java/com/github/yukihane/springsecurityauthexample/security/MyAuthenticationProvider.java)が該当の認証プロバイダで、これを用いるように設定しているのが [MyWebSecurityConfigurerAdapter](https://github.com/yukihane/hello-java/blob/tags/simple-authentication-example/spring/spring-security-auth-example/src/main/java/com/github/yukihane/springsecurityauthexample/config/MyWebSecurityConfigurerAdapter.java#L22)である。

(終わり)

# 実行して確認

http://localhost:8080/hello へアクセスすると Basic 認証のダイアログが出るので、 `tags/simple-authentication-example` であれば username に [**myname**](https://github.com/yukihane/hello-java/blob/tags/simple-authentication-example/spring/spring-security-auth-example/src/main/java/com/github/yukihane/springsecurityauthexample/security/MyAuthenticationProvider.java#L17)を(パスワードは何でも良い)、`tags/simple-authentication-db-example`タグのものであれば [username に **user1**, password に**password1**](https://github.com/yukihane/hello-java/blob/tags/simple-authentication-db-example/spring/spring-security-auth-example/src/main/resources/data.sql#L1)を入力すれば認証が通る。

# 追記: んで結局 UserDetails ってなんなのさ

https://docs.spring.io/spring-security/site/docs/5.1.5.RELEASE/reference/htmlsingle/#tech-userdetailsservice

> Think of `UserDetails` as the adapter between your own user database and what Spring Security needs inside the `SecurityContextHolder`.

だって。そんな汎用的に使えるもんかあ？余計なメソッド多すぎじゃね…？

---

spring-security-oauth2 を使ったとき principal を完全に独自の型にしていたらフレームワーク内の [`getName()`呼び出しで`toString()`されて困った](https://github.com/spring-projects/spring-security/blob/5.1.5.RELEASE/core/src/main/java/org/springframework/security/authentication/AbstractAuthenticationToken.java#L93)ので、`UserDetails`は実装しなくとも[AuthenticatedPrincipal](https://github.com/spring-projects/spring-security/blob/5.1.5.RELEASE/core/src/main/java/org/springframework/security/authentication/AbstractAuthenticationToken.java#L86)は実装しといたほうが良さげ。
