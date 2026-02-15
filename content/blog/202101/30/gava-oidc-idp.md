---
title: "ガバガバOIDCモックサーバを作る"
date: 2021-01-30T06:29:06Z
draft: false
tags:
  - oidc
  - spring-boot
---

OIDCフローの調査などで本物でないOIDC IdP Mock Serverが欲しくなったので検索してみました。

[世に数多あるよう](https://www.google.com/search?q=oidc+mock+server)に見えたのですが、結構真面目に認証処理してたりして、ちょっとオーバースペックだと感じたので自作することにしました。

- [gava-idp](https://github.com/yukihane/gava-idp)
