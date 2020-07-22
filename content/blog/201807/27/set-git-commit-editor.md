---
title: gitで利用するエディタを設定したかった
date: 2018-07-27T19:40:03Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [git]
# images: []
# videos: []
# audio: []
draft: false
---

あるいは vim-plug をセットアップしたら git commit したときに E492: Not an editor command って怒られるようになっちゃった。

Vagrant で CentOS の Box を作るたびにひっかかる。

Git が使う editor を(vi でなく)vim に設定すればよい。

1. `GIT_EDITOR`環境変数
2. `core.editor`設定
3. `VISUAL`環境変数
4. `EDITOR`環境変数
5. コンパイル時の設定(通常`vi`(ただし Ubuntu は`nano`だった))

の優先順位で利用されるエディタが決定する([git-var(1)](https://git-scm.com/docs/git-var))ので、何も設定していなければ(大抵の場合)`vi`が使用される。
`vim`が使われるように設定しておこう。例えば、次のように:

    git config --global core.editor $(which vim)
