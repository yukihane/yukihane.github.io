---
title: "クッキーの挙動は Same Origin Policy に従う…わけではない"
date: 2020-07-19T11:59:29Z
draft: false
tag:
  - web
---

次のQiitaのコメントを見て、そうなんだ、となりました:

- [Auth TokenをlocalStorageに入れようが、cookieに入れようがどっちもXSS危険性には無防備（同ドメイン内なら …​）](https://qiita.com/github0013@github/items/e57c452de28f3918bf05#comment-4df8a971cd5c8c2d0673)

根拠を探してみたところ、同じくQiitaの記事

- [君はできるかな？Cookie ＆ Same Origin Policyセキュリティークイズ4問](https://qiita.com/kubocchi/items/020352173d014cbf5332#%E5%95%8F2)

の出典として [RFC6265 HTTP State Management Mechanism](https://tools.ietf.org/html/rfc6265)が挙げられており、そちらのドキュメントの冒頭にバッチリ書いてありました:

> (前略)Similarly, cookies for a given host are shared across all the ports on that host, even though the usual "same-origin policy" used by web browsers isolates content retrieved via different ports.
>
> —  [1. Introduction](https://tools.ietf.org/html/rfc6265#section-1)

> Cookies do not provide isolation by port. If a cookie is readable by a service running on one port, the cookie is also readable by a service running on another port of the same server. If a cookie is writable by a service on one port, the cookie is also writable by a service running on another port of the same server. For this reason, servers SHOULD NOT both run mutually distrusting services on different ports of the same host and use cookies to store security- sensitive information.
>
> —  [8.5. Weak Confidentiality](https://tools.ietf.org/html/rfc6265#section-8.5)

ちなみに後続の文章ではスキーマ(`http` とか)が違っても送信されるよ、と書いてありまして、そういやその問題を抑制する方策のひとつとして `secure` があるのだな、と。

逆に言えば、 `secure` 属性みたいなのが必要ってことはcookiesはsame-origin-policyに従っているわけではないのだな、という推測が可能ですね。
