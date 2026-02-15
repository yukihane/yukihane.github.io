---
title: "LINEログインを試してみる(Spring Boot 2.4.5/Spring Security 5.4.6)"
date: 2021-05-06T10:43:04Z
draft: false
tags:
  - line
  - spring-security
  - oidc
---

# はじめに

- [LINEログイン機能を試してみる]({{< relref"/blog/201908/line-login-sample" >}}) – 発火後忘失

で、 Spring Boot 2.1.7 (Spring Security 5.1.6) を利用してLINEログインを行ってみました。

本ドキュメントは、このコードをそのまま Spring Boot 2.4.5 へアップグレードしたところ上手く動かなかったので修正を行った記録です。

# コード

- <https://github.com/yukihane/hello-java/tree/master/line/sample-line-webapp>

なお、今回の対応前の、 Spring Boot 2.1.7 バージョンは `55b9ea4b2` です。 本文中の「昔のコード」とはこれを指します。

# 対応内容

本質と関係ないものは省略します。

## Support space-delimited oauth2 scope ([spring-projects/spring-boot \#15398](https://github.com/spring-projects/spring-boot/issues/15398))

(表題に反して) scope の指定でスペースが許可されなくなり、カンマ `,` で区切らなければならなくなった模様です。

[`0274a3c`](https://github.com/yukihane/hello-java/commit/0274a3c5e4f22d8bad0cf42fb9f49b9dfcb69cf1#diff-63a1bc38a27210ab764296761255f0acdbf5d8b7fc9e29da0f484ed522d9dfa5)

## Support unsigned ID tokens for OIDC ([spring-projects/spring-security \#9494](https://github.com/spring-projects/spring-security/issues/9494))

デフォルトでは [`RS256` 固定](https://github.com/spring-projects/spring-security/blob/5.4.6/oauth2/oauth2-client/src/main/java/org/springframework/security/oauth2/client/oidc/authentication/OidcIdTokenDecoderFactory.java#L86-L87) なので `HS256` に挿げ替えます。

昔のコードが不都合なく動作していたのは、(ちゃんとは見ていませんが)おそらく署名の検証を行っていないからなのではないかと思います。 OAuath2.0 と共通フローだったのではないかと。

[`bbe79f9`](https://github.com/yukihane/hello-java/commit/bbe79f91803769f871ce1f4a11cc4634c28372f7)

## LINEログイン v2.1 API における userinfo_endpoint の誤解

昔のコードでは userinfo エンドポイントは [`https://api.line.me/v2/profile`](https://developers.line.biz/ja/reference/line-login/#%E3%83%95%E3%82%9A%E3%83%AD%E3%83%95%E3%82%A3%E3%83%BC%E3%83%AB) だと誤解して設定していました。

昔のコードはこれで動作したのですが、Spring Securityのバージョンが上がったことで [検証が厳密になり](https://github.com/spring-projects/spring-security/blob/5.4.6/oauth2/oauth2-client/src/main/java/org/springframework/security/oauth2/client/oidc/userinfo/OidcUserService.java#L112-L113)、通らなくなっているようです。

LINEログイン v2.1 API で [UserInfo レスポンス](https://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html#UserInfoResponse) を満たすものを返してくるのは [`https://api.line.me/oauth2/v2.1/verify`](https://developers.line.biz/ja/reference/line-login/#verify-id-token) だけのようだったので、今回これを指定しました。

ただ、LINEログインのリファレンスにもある通り、これは "IDトークンのペイロード部分" であり、LINE社はひとことも [userinfoエンドポイント](https://openid-foundation-japan.github.io/openid-connect-core-1_0.ja.html#UserInfo) である、とは言っていないんですよね (しかし v2.1 は "[OpenID Connect プロトコルをサポートし](https://developers.line.biz/ja/reference/line-login-v2/)"ていると言っている…じゃあuserinfoエンドポイントはどこなんだっていう)。

また、 `iat` やら `exp` が含まれているのも、UserInfo として妥当であるとは言い難いように思われます(ユーザの属性ではないことは明らか)。

実装においては、APIリファレンスを見れば分かる通り、 `/verify` へのリクエストには `id_token` と `client_id` パラメータが必須なので、少し工夫が必要でした。

[`8cdce2a`](https://github.com/yukihane/hello-java/commit/8cdce2ae55382a06ae11386369e3bdfd08cae63a)

# まとめ

LINE社の主張に反し、 LINEログイン v2.1 API は OpenID Connect プロトコルには準拠していないと考えます。 なぜならば、 userinfo エンドポイントに相当するエンドポイントを備えていないからです。 (LINE社が言うところのOIDCサポートは、発行者を検証できるid tokenを返している、という部分でしょうか。それだけでは片手落ちでしょう。)

Spring Security のデフォルト実装を用いる場合、 `openid` スコープを指定するとうまく動作しません。 本文では `openid` を指定した実装を無理やり行いましたが、指定しない場合の実装(つまりOIDCでなくOAuth2.0として処理する)を [`tags/line-login-without-openid`](https://github.com/yukihane/hello-java/tree/tags/line-login-without-openid/line/sample-line-webapp) タグで行っており、こちらの方が自然だと考えます。
