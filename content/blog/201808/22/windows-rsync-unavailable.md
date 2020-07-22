---
title: Windows向けrsyncがなくなったみたい？
date: 2018-08-22T19:48:21Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [windows, scoop]
# images: []
# videos: []
# audio: []
draft: false
---

`vagrant`で`rsync`が使いたくなった。
そこで`scoop`で`rsync`をインストールしようとしたが、見つからない。
おや？と思い検索してみると次の issue が。
[rsync free version is no more #2506](https://github.com/lukesampson/scoop/issues/2506)

つい最近、 https://www.itefix.net/dl/cwrsync_5.7.2_x86_free.zip が無くなったそうだ。

代替策としては、
http://repo.msys2.org/msys/x86_64/rsync-3.1.3-1-x86_64.pkg.tar.xz
を用いるのがよさそうだ。

おそらく早晩`scoop`コマンドで入手可能となろうが。
refs: https://github.com/lukesampson/scoop/pull/2431
