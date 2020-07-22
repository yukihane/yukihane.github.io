---
title: ワンライナー sudoers 編集
date: 2018-05-09T19:24:15Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [linux]
# images: []
# videos: []
# audio: []
draft: false
---

`Dockerfile` 内で `sudoers` を編集しユーザ情報を追加したかった。

    RUN echo 'myuser ALL=(ALL) NOPASSWD: ALL' | EDITOR='tee -a' visudo

参考: [linux - How do I edit /etc/sudoers from a script? - Stack Overflow](https://stackoverflow.com/a/28382838/4506703)
