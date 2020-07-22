---
title: Invoke-WebRequestやCompress-Archiveを使っていると画面上部に一瞬表示される何かの表示を非表示に
date: 2018-09-08T19:50:04Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [windows, pwsh]
# images: []
# videos: []
# audio: []
draft: false
---

進捗状況(progress)が表示されているそうです。少量のデータを扱っている場合には画面の一部がフラッシュしているように見えており、何のための画面効果かさっぱりわかりませんでした(ので検索キーワードすら思い浮かびませんでした)。

    $progressPreference = 'silentlyContinue'

で抑制できるようです。

参考: [powershell - Hide progress of Invoke-WebRequest - Stack Overflow](https://stackoverflow.com/a/18770794/4506703)
