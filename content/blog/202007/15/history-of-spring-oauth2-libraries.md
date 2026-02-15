---
title: "Spring SecurityのOAuth2.0関連の歴史を調査し実装してみた"
date: 2020-07-14T23:47:11Z
draft: false
tags:
  - spring-security
  - oauth
  - spring-boot
---

Qiita に昔(2019年中頃)書いていた資料を転記し忘れていたので構成を見直してアップロードし直します。

2020年現在の状況はまた更新されています。次のURLを参照してください。

- <https://spring.io/blog/2019/11/14/spring-security-oauth-2-0-roadmap-update>

  - 認可サーバのサポートが無くなることが決定した(が、後にこの決定を見直すことも示唆されており、不透明)

  - spring-security-oauth2 の EOL が発表された(2021/5 頃)

# 背景と概要

Spring Boot最新版(2.1.6.RELEASE)でOAuth 2.0 対応のリソースサーバ兼認可サーバを実装する必要に迫られましたが、Spring的にOAuth 2.0 対応が過渡期なようでドキュメントを探したりするのに手間取りました。

本エントリは、ドキュメントの所在のメモと、自分の理解度の確認として冒頭に紹介した [@kazuki43zoo](https://qiita.com/kazuki43zoo) さんのコードを Spring Boot 2.1.6.RELEASE へマイグレーションしてみたのでそれについてもメモするためのものです。

- 元ネタ

  - [Spring Security OAuthで認可コードグラントフローを体感しよう -第２回：とりあえずアプリを作る編](https://qiita.com/kazuki43zoo/items/9cc00f0c92c7b0e1e529) - Qiita

  - <https://github.com/kazuki43zoo/spring-security-oauth-demo>

- 今回作成したソース

  - <https://github.com/yukihane/spring-security-oauth-demo>

  - 差異の詳細は後述

# Spring Boot2.1.6における OAuth 2.0 対応

リファレンス [30.3.3 Authorization Server](https://docs.spring.io/spring-boot/docs/2.1.6.RELEASE/reference/html/boot-features-security.html#_authorization_server) では

> Currently, Spring Security does not provide support for implementing an OAuth 2.0 Authorization Server. However, this functionality is available from the Spring Security OAuth project, which will eventually be superseded by Spring Security completely.
>
> —  Spring Boot 2.1.6.RELEASE リファレンス [30.3.3 Authorization Server](https://docs.spring.io/spring-boot/docs/2.1.6.RELEASE/reference/html/boot-features-security.html#_authorization_server)

と若干引っかかる説明になっています。 これはどういうことかというと、この節のリンクの何クリックか先にあるドキュメント

- [OAuth 2.0 Features Matrix](https://github.com/spring-projects/spring-security/wiki/OAuth-2.0-Features-Matrix)

を見ることで事情が理解できます。 (注: 現在は当時から改訂が入っています)

- OAuth 2.0 は "Spring Security" で実現する方針で、Spring Boot 1.x の頃に利用していた "Spring Security OAuth"(spring-security-oauth\*)はもはやメンテナンスモードである

- とはいえ、Spring Securityにはまだ認可サーバサポートがない

  - (予定では "the end of 2018 or early 2019" に対応、だったようだが)

というわけで、現時点で認可サーバ実装を行おうとした場合には spring-security-oauth2 を利用することになります。

リソースサーバやクライアントはSpring Securityのものが利用できるのかというと、不可能ではないが [何やら面倒そうな気配](https://docs.spring.io/spring-security-oauth2-boot/docs/current-SNAPSHOT/reference/html5/#oauth2-boot-authorization-server-spring-security-oauth2-resource-server) がします。 何か問題が起きたときに解決できる気がしなかったので私は今回Spring Security版を採用するのはやめました。

まとめると、Spring Bootでリソースサーバ兼認可サーバを作る場合、現時点ではSpring Boot 1.x の頃と同じ仕組みを利用するのが無難そう、という結論に至りました。

# リファレンス

- [OAuth 2 Developers Guide](https://projects.spring.io/spring-security-oauth/docs/oauth2.html) - spring-security-oauth2

  - <https://github.com/spring-projects/spring-security-oauth/tree/master/samples/oauth2>

    - (Spring Bootだけでなく)Spring Frameworkのコードが理解できるのならこのサンプルコードは役に立ちそうな気がします。私は理解できません。

    - 正常動作させるために [プルリク#1674](https://github.com/spring-projects/spring-security-oauth/pull/1674) をマージする必要がありました。

- [OAuth2 Autoconfig](https://docs.spring.io/spring-security-oauth2-boot/docs/2.1.6.RELEASE/reference/html5/) - spring-security-oauth2-boot の 2.1.6版

- [OAuth2 Boot](https://docs.spring.io/spring-security-oauth2-boot/docs/current-SNAPSHOT/reference/html5/) - spring-security-oauth2-boot の current-SNAPSHOT版

- [Spring Boot and OAuth2](https://spring.io/guides/tutorials/spring-boot-oauth2/) - 公式チュートリアル

  - <https://github.com/spring-guides/tut-spring-boot-oauth2>

  - ソーシャルログインしたいわけではないので自分にはあまり見どころが無かった

spring-security-oauth2-boot の 2.1.6版だけでなくcurrent-SNAPSHOT版も見ないと情報が出揃わない、というのが罠でした。

# 今回作成したコードについて

- <https://github.com/yukihane/spring-security-oauth-demo>

冒頭で紹介した @kazuki43zoo さんのソースのforkです。 非互換性といくつか本質的でない変更を行っているのでそれについて記載しておきます。

- クライアントにブラウザでアクセスした際の認証は OAuth 2.0 とは無関係かと考えたのでスキップするようにしています。 [98db0dd](https://github.com/yukihane/spring-security-oauth-demo/commit/98db0dd40be08e63ec7e91210c8b0b7ed6f58989)

  - (追記)ワンショットのリクエストならそれで問題ないのですが、 refresh_token のフローを見てみたい場合などはクライアントがセッションを持っている必要がありました(ので後にもとに戻しています)。

- grant_type: passwordが通りませんので「[アクセストークンの取得](https://qiita.com/kazuki43zoo/items/9cc00f0c92c7b0e1e529#%E3%82%A2%E3%82%AF%E3%82%BB%E3%82%B9%E3%83%88%E3%83%BC%E3%82%AF%E3%83%B3%E3%81%AE%E5%8F%96%E5%BE%97)」の動作確認ができません。

  - [このへん](https://projects.spring.io/spring-security-oauth/docs/oauth2.html#grant-types) やってないからかな、と思うのですがあまり興味がなかったのでちゃんとは見ていません。

- 元々 `application.properties` で設定されていたものがJava Configに移っています。リファレンスを真似たためです。 [87ab08](https://github.com/yukihane/spring-security-oauth-demo/commit/87ab086226ffa96946eec1c9c765202835ba9dc9)

- Spring Data JDBCで実行時エラーになるのですが直し方がわからなかったので Spring Data JPA に移し替えました。 [3faf6e](https://github.com/yukihane/spring-security-oauth-demo/commit/3faf6e68f9c5033887b051404dd793cd441cc130)

- Javaバージョンを11に上げています。 [c70a534](https://github.com/yukihane/spring-security-oauth-demo/commit/c70a534bf6ee253f1697973580fe86f315177740)
