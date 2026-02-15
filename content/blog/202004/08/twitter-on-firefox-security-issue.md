---
title: "TwitterをFirefoxで利用した際のセキュリティ問題"
date: 2020-04-07T20:15:38Z
draft: false
tags:
  - security
---

- [\>Mozilla Firefoxに保存されているTwitterデータのキャッシュについて](https://privacy.twitter.com/ja/blog/2020/data-cache-firefox)

というリリースが先日出されましたが、具体的にどういう問題なのかが書かれていないので調べてみました。

The Mozilla Blog から詳細を辿れました。

- [What you need to know about Twitter on Firefox - The Mozilla Blog](https://blog.mozilla.org/blog/2020/04/03/what-you-need-to-know-about-twitter-on-firefox/)

  - [Twitter Direct Message Caching and Firefox - Mozilla Hacks - the Web developer blog](https://hacks.mozilla.org/2020/04/twitter-direct-message-caching-and-firefox/)

発生している(た)事象:

- ダイレクトメッセージがローカルキャッシュに保存されたままになるため、他者が(Twitterにログインしなくとも)ダイレクトメッセージを読み取れてしまう状況になる

原因:

- キャッシュしないようにする指示が不適切だった(Web標準に則っておらず、一部ブラウザでのみ効果のある設定( `Pragma: no-cache` )を行っていた)。

  - 今回のような場合は `Cache-Control: no-store` を指定しなければならない。

[Cache-Control の"キャッシュ可能性"](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Cache-Control#Cacheability)の節に説明がありますが、

> no-cache  
> キャッシュコピーをリリースする前に、検証のために元のサーバーへリクエストを送ることをキャッシュに強制します。
>
> no-store  
> クライアントのリクエストであるかサーバーのレスポンスであるかにかかわらず、キャッシュを格納してはいけません。

`no-cache` は **リクエストのみ** をキャッシュしない指示に対し(ただしレスポンスもキャッシュしなくなるブラウザも存在する)、 `no-store` は **リクエストもレスポンスも** キャッシュしない指示なので後者を用いるべきだ、ということのようです。
