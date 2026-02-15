---
title: "`git config pull.ff only` を設定しておこう"
date: 2020-07-19T06:47:48Z
draft: false
tags:
  - git
---

私は普段全く `git pull` は使わず、 `git fetch` で賄ってきたのですが、今日たまたま `git pull` を行ったところ、いつの頃からか次のようなメッセージが出るようになっていることに気づきました:

> warning: Pulling without specifying how to reconcile divergent branches is discouraged. You can squelch this message by running one of the following commands sometime before your next pull:
>
>     git config pull.rebase false  # merge (the default strategy)
>     git config pull.rebase true   # rebase
>     git config pull.ff only       # fast-forward only
>
> You can replace "git config" with "git config --global" to set a default preference for all repositories. You can also pass --rebase, --no-rebase, or --ff-only on the command line to override the configured default per invocation.

この中で推奨されている設定のうち、私のお薦めは

    git config --global pull.ff only

です。

これは、 `git pull` を行ったとき fast-forward でマージできる状況でなければマージを行わず、 fetch だけに留める、というオプションです。ローカルブランチは何も変更されません。

fast-forwardされなかった旨のメッセージが出るので、fetchしたリモートリポジトリをどう取り込むかは改めて考えることができます。

デフォルトだと `merge` なのか `fast-forward` なのか実行時に判明するので、 `fast-forward` されると思ってたのに `merge` になってしまって… というような事態が発生するので `git pull` は面倒、という意識が出来上がってしまい、冒頭の通り `pull` は使わなくなっていました。
