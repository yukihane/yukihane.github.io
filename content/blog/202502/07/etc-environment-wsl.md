---
title: "WSLは /etc/environment を読まない"
date: 2025-02-07T05:47:10+09:00
draft: false
tags: ["ubuntu", "wsl", "windows"]
---

このエントリーを書くためにWSL2に[Hugoをsnapで](https://gohugo.io/installation/linux/#snap)インストールしました。

そして `hugo` コマンドを実行すると...そんなものはないと言われてしまいました。
PATHが通っていないからかな？と思い `/etc/environment` ファイルを見て見たのですが `/snap/bin` は初めから設定されている。むむむと思いググったところ次のような記事がヒットしました:

- [`http_proxy` not showing up with `printenv` on WSL](https://askubuntu.com/a/1046274/460420)
- [bash not picking up /etc/environment #1405](https://github.com/Microsoft/WSL/issues/1405)

WSL2特有の事情で `/etc/environment` が読まれないそうです。

色々workaroundが提示されていたりもしますが、素直に `.bashrc` などでPATHを追加すれば良いでしょう。
