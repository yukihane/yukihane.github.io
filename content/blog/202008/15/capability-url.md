---
title: "ランダム文字列URL生成に関するメモ"
date: 2020-08-15T10:26:40Z
draft: false
tags:
  - web
---

推測されないような文字列を動的に生成しURLに利用できるような仕組みを調べていますが、その調査メモです。

ちょうど私が調べている時期と重なって、関心対象が同じ資料がアップロードされていました:

- [API Meetup Online \#3で限定公開URL（Capability URLs）について話をしてきました。 \| フューチャー技術ブログ](https://future-architect.github.io/articles/20200809/)

  - Googleスライド資料: [認証しないWeb認証 - 限定公開URLのセキュリティについて考える -2020/8/7 API Meetup Online \#3-](https://docs.google.com/presentation/d/1aZ4zGNoD-PYElGmWJwRyW-8TNcXheNMuyPvQIUOt-VE/edit#slide=id.p)

上記資料によると、W3Cのドキュメントでは **capability URLs** と呼称されてているようです。 下記が参考資料のようです:

- [Good Practices for Capability URLs (W3C Editor’s Draft 23 July 2014)](https://w3ctag.github.io/capability-urls/2014-07-23.html) ([GitHub](https://github.com/w3ctag/capability-urls))

ただし、例えば Stack Overflow で capability url を検索しても全くヒットせず、浸透している用語とは言い難いように感じます(Stack Overflow では generate random string url 等で検索するほうがまだヒットした)。

- [How to generate a random alpha-numeric string? - Stack Overflow](https://stackoverflow.com/a/41156/4506703)

の回答によると、 UUID は推測困難な文字列を生成するとは言えず、冒頭に記載した用途としては不向きなようです。

次のように、RFCにがっつり明記してあります。

> Do not assume that UUIDs are hard to guess; they should not be used as security capabilities (identifiers whose mere possession grants access), for example. A predictable random number source will exacerbate the situation.
>
> —  6.Security Considerations [RFC4122 A Universally Unique IDentifier (UUID) URN Namespace](https://tools.ietf.org/html/rfc4122#section-6)

- [Java UUID.randomUUID() or SecureRandom for id segment on URL? - Information Security Stack Exchange](https://security.stackexchange.com/a/140753)

の回答にあるように、Javaの場合、重複しないことが重要なようなら UUID, 推測されないことが重要なら SecureRandom を用いるのが良いのかなと思いました(冒頭の要件なら SecureRandom ですね)。

ちなみに Docker で `/dev/random` を使うと、起動してからエントロピーが貯まるまで処理がブロックされる、みたいな問題も何回か聞いたことがあります

- [Not enough entropy to support /dev/random in docker containers running in boot2docker - Stack Overflow](https://stackoverflow.com/q/26021181/4506703)

ので、その辺りも確認しておいたほうが良いかも知れません。 `SecureRandom` は、インスタンスの取得方法によって `/dev/urandom`, `/dev/random` のどちらを使うかが変わるようです。

- [The Right Way to Use SecureRandom · Terse Systems](https://tersesystems.com/blog/2015/12/17/the-right-way-to-use-securerandom/)

(そして上記リンクによれば、特に `/dev/random` を使うメリットは無い、という話も)

ちなみに Ruby には [SecureRandom.urlsafe_base64](https://docs.ruby-lang.org/ja/latest/method/SecureRandom/s/urlsafe_base64.html) なんていう今回の目的そのまんまっぽい名前のメソッドがありました。
