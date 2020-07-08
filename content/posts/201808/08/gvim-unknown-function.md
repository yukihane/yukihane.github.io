---
title: vim で E117 未知の関数です
date: 2018-08-08T19:43:44Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [windows, vim]
# images: []
# videos: []
# audio: []
draft: false
---

vim は `~/.vim` ディレクトリを読むのに対し gvim は`~/vimfiles`ディレクトリを読むためだそうです。Windows ならジャンクションを作りましょう。

    cd /d %homepath%
    mklink /j vimfiles .vim

参考:

- [neovim Unknown function: plug#begin](https://github.com/junegunn/vim-plug/issues/245)
- [gvim on windows](https://github.com/avelino/vim-bootstrap/issues/205)
