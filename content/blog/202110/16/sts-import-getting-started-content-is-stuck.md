---
title: "STS(Eclipse) で Import Getting Started Content が進まない"
date: 2021-10-16T08:16:59+09:00
draft: false
tags:
  - spring-boot
  - eclipse
  - java
---

[Spring Tools 4 for Eclipse](https://spring.io/tools) を利用していると、バージョンによって？ プロジェクト新規作成時などで "Import Getting Started Content" というタスクが走るのですがこれが全く終わらないことがあります。

Window \> Preference で設定画面を開いて、 General \> Network Connections の設定値を "Native" から "Direct"(プロキシを使用している場合は"Manual"にしてプロキシ設定) へ変更するとスムーズに進むようになる場合があります。

何でうまくいくのかはわかりませんが…(Stack Overflow でも同じような質問が繰り返されていますね)

(追記) …と思ったのですが、設定変えてもやっぱり進まなくなりました。プロジェクト作成はウィザードを使わずに <https://start.spring.io/> を利用するのが良さそう。
