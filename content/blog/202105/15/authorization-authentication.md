---
title: "Authorization(認可)リクエストヘッダに設定するのは認証(authentication)情報"
date: 2021-05-15T09:40:22Z
draft: false
tags:
  - http
  - diary
---

今日もOAuthは認証じゃなくて認可の仕組みだ云々という話題でソーシャルネットがもちきりですが、そんなことより表題の方がよっぽど気になりませんか…？

> HTTP の **`Authorization`** リクエストヘッダーは、ユーザーエージェントがサーバーから認証を受けるための証明書を保持し、(後略)
>
> —  [Authorization - HTTP \| MDN](https://developer.mozilla.org/ja/docs/Web/HTTP/Headers/Authorization)

原文の方がどちらも英単語で表れているのでわかりやすいかな？

> The HTTP **`Authorization`** request header contains the credentials to authenticate a user agent with a server,
>
> —  <https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Authorization>

Stack Overflow でも同じ疑問を持ってる方がいらっしゃいました:

- [Why is the HTTP header for Authentication called Authorization?](https://stackoverflow.com/q/30062024/4506703)
