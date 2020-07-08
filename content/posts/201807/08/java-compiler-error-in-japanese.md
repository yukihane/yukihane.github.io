---
title: エラーメッセージでググろうと思ったんだけど日本語だからかヒットしない
date: 2018-07-08T19:30:29Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java]
# images: []
# videos: []
# audio: []
draft: false
---

# Java でメッセージを英語にする

環境変数 [`JAVA_TOOL_OPTIONS`](https://docs.oracle.com/javase/jp/8/docs/technotes/guides/troubleshoot/envvars002.html) に設定しよう。

    export JAVA_TOOL_OPTIONS="-Duser.language=en -Duser.country=US"
