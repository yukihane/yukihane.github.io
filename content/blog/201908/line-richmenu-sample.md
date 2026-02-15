---
title: LINE リッチメニューを試してみる
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

- <https://github.com/yukihane/hello-java/tree/master/line/richmenu-sample>

[公式リファレンス](https://developers.line.biz/ja/docs/messaging-api/using-rich-menus/) に書いてある通りですが、リッチメニューを試してみました。 メニューをタップするとPostBackEventを送信します。

botでハンドリングするために、 [前回](https://himeji-cs.jp/blog2/blog/2019/08/line-bot-sample.html) 作成した [bot](https://github.com/yukihane/hello-java/tree/master/line/line-bot-sample) に、PostBackEvent のハンドラを追加しています。
