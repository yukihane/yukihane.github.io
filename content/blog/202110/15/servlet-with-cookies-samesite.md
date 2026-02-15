---
title: "Servlet 5.1 で Samesite 属性を設定できるようになる"
date: 2021-10-15T20:31:37+09:00
draft: false
tags:
  - java
---

現在の Servlet API では [`Cookie`](https://jakarta.ee/specifications/platform/8/apidocs/javax/servlet/http/cookie) に [`SameSite` 属性](https://developer.mozilla.org/ja/docs/Web/HTTP/Cookies#samesite_attribute)を設定するメソッドがありません。

そのため、仕様外の、フレームワーク固有の方法だったり、低レイヤーの仕組みを使って設定する必要があります。

- [ServletでSameSite Cookieを設定する - Zenn](https://zenn.dev/backpaper0/articles/b8d624990d09169abf81)

- [JavaでCookieにSameSite属性をつける - Qiita](https://qiita.com/nannou/items/fc86d052e356e095fcbf)

- [`DefaultCookieSerializer#setSameSite()` - spring-session-docs 2.5.2 API](https://docs.spring.io/spring-session/docs/2.5.2/api/org/springframework/session/web/http/DefaultCookieSerializer.html#setSameSite-java.lang.String-)

そういった状況に対して、Servlet 5.1 で、 `Cookie` に `setAttribute` という汎用的な属性設定用のメソッドが追加されることになったようです。

- [SameSite Cookie Support \#175 - eclipse-ee4j/servlet-api](https://github.com/eclipse-ee4j/servlet-api/issues/175)

変更差分を見てみると、 [`setSecure()`](https://github.com/eclipse-ee4j/servlet-api/pull/401/files#diff-efd9fbfb2d16ee6423b8d6c37d235871db13a6cbe03ee41f52900412c67df0b8L285-L299)とか [`setHttpOnly()`](https://github.com/eclipse-ee4j/servlet-api/pull/401/files#diff-efd9fbfb2d16ee6423b8d6c37d235871db13a6cbe03ee41f52900412c67df0b8L417-R446)といった既存のメソッドも今回の仕組みで実装し直されています。
