---
title: "ISO 8601では 24:00 は妥当だったが改訂によりNGになった"
date: 2020-07-13T18:45:43Z
draft: false
tags:
  - programming
  - datetime
---

[moment().isValid()での24時00分00秒の挙動について - スタック・オーバーフロー](https://ja.stackoverflow.com/q/68413/2808) より。

ISO 8601 の以前のspecでは、 `0:00` も `24:00` も両方妥当な表記だったらしいです。 実際、"ISO8601 24:00" みたいなキーワードで検索するとそのように説明しているサイトも複数ヒットします。

しかし、 [Wikipedia](https://en.wikipedia.org/wiki/ISO_8601) の現在の記述によると、

> Midnight is a special case and may be referred to as either "00:00" or "24:00", except in ISO 8601-1:2019 where "24:00" is no longer permitted.
>
> —  [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601#Times) - Wikipedia

ということで、現在は `24:00` は駄目、ということだそうです。 `ISO 8601-1:2019` という付番からして2019年に改訂されたのでしょうか。
