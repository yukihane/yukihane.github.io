---
title: LINEログイン機能を試してみる(Spring Boot 2.1.7/Spring Security 5.1.6)
date: 2019-08-25
draft: false
tags:
  - java
  - spring-boot
  - line
:jbake-type: post
:jbake-status: published
:jbake-tags: java,springboot,line
:idprefix:
---

<div class="important">

本ページは Spring Boot 2.1.7 の頃のものですが、後続として 2.4.5 対応版があります: [LINEログインを試してみる(Spring Boot 2.4.5/Spring Security 5.4.6)]({{< relref"/blog/202105/06/ling-login-202105" >}}) – 発火後忘失

</div>

Spring SecurityのOAuth実装は [こちらに書いたとおり](https://qiita.com/yukihane/items/fc97f888ecb6a6850ea7) 歴史的経緯により複数存在しますが、 <https://start.spring.io/> の Dependencies で "OAuth2 Client" を選択した場合に追加されるものは一番新しいSpring Securityの [`spring-security-oauth2-client`](https://docs.spring.io/spring-security/site/docs/5.1.6.RELEASE/reference/html/modules.html#spring-security-oauth2-client) (及び `spring-security-oauth2-jose`)でした。

というわけでSpring Securityのリファレンス [6.7 OAuth 2.0 Login](https://docs.spring.io/spring-security/site/docs/5.1.6.RELEASE/reference/html/jc.html#oauth2login) を参 照しながら実装していきます。

リファレンスを見るとSpring Bootがauto-configurationを提供してくれているようですので、クラスを探してみます[^1]。

- [`OAuth2ClientAutoConfiguration`](https://github.com/spring-projects/spring-boot/blob/v2.1.7.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/servlet/OAuth2ClientAutoConfiguration.java)

そしてこのクラスで `@Import` している2クラス+1プロパティ

- [`OAuth2ClientRegistrationRepositoryConfiguration`](https://github.com/spring-projects/spring-boot/blob/v2.1.7.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/servlet/OAuth2ClientRegistrationRepositoryConfiguration.java)

  - プロパティクラス [`OAuth2ClientProperties`](https://github.com/spring-projects/spring-boot/blob/v2.1.7.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/OAuth2ClientProperties.java) を利用

- [`OAuth2WebSecurityConfiguration`](https://github.com/spring-projects/spring-boot/blob/v2.1.7.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/servlet/OAuth2WebSecurityConfiguration.java)

あたりで設定が行われているのがわかります。

# コード

- <https://github.com/yukihane/hello-java/tree/master/line/sample-line-webapp>

# メモ

## 設定が間違っていても何が原因かログ等に出ない

設定が誤っていると、見た目はログイン画面のループになり、原因がさっぱりわからないことがままあります。 Spring Securityあるあるですが、ログにも大した情報は出ません。 ですので、とりあえず小さな動くサンプルを作ってから、動かしながら機能をつけ足していくのが無難かと思います。

## 参照すべきリファレンスなど

- [LINEログイン \> ウェブアプリにLINEログインを組み込む](https://developers.line.biz/ja/docs/line-login/web/integrate-line-login/)

- [Social API v2.1](https://developers.line.biz/ja/docs/social-api/)

- <https://access.line.me/.well-known/openid-configuration>

LINEログインのリファレンスだけでなく、Social APIの方にしか書かれていない情報があるし、更に言うとそこにも書かれていない情報がありました。

最後のリンクは OpenID Provider Configuration Document を返すエンドポイントです。

- [4.1. OpenID Provider Configuration Request](https://openid.net/specs/openid-connect-discovery-1_0.html#ProviderConfigurationRequest)

## `jwk-set-uri` 設定がリファレンスに明記されていない

上記の OpenID Provider Configuration Documentに載っていました。

<div class="formalpara-title">

**application.properties**

</div>

    spring.security.oauth2.client.provider.line.jwk-set-uri=https://api.line.me/oauth2/v2.1/certs

## `issuer-uri` 設定を行ってはいけない

本来 `https://access.line.me` を設定するのが良さそうに思われますが、LINEの提供している OpenID Provider Configuration Document は本ライブラリの期待する情報種類を満たしておらず、設定すると `NPE` が発生しました。

## scopeの区切り文字

[リファレンスの説明](https://developers.line.biz/ja/docs/line-login/web/integrate-line-login/#scopes) によると

> URLエンコードされた空白文字（%20）で区切って、複数のスコープを指定できます。

とのことですが、 `application.properties` で空白で区切って設定値を書くと `+` (`%2B`)になってしまってどうしたものかと思いましたが、LINE側はこれでも受け付けてくれているようなので良しとしています。

[^1]: ところでいつもこの作業は何となく名前でそれっぽいクラス…というふうに探しているのですが、ちゃんとした調べ方ってあるんでしょうかね…？
