---
title: "Windows11でShift+Spaceで日本語/英語切り替えを行えるようにする"
date: 2025-11-03T05:14:44+09:00
tags: ["windows", "autohotkey"]
draft: false
---

ひとつ前のエントリーに記載した通り、これまでShift+Spaceで日本語と英語の切り替えを行うために「以前のバージョンのMicrosoft IMEを使う」の設定を有効化していましたが、Windows Terminalとの相性が悪いため無効化せざるを得なくなりました。

したがって、Shift+Spaceで切り替えできるようにする代替策を考える必要が出ました。

ChatGPTに聞いてみたところ、 [AutoHotKey](https://www.autohotkey.com/) で解消できましたのでその設定をGitHubに登録しています。

成果物は[こちらのリポジトリー](https://github.com/yukihane/prefs/tree/main/windows) の `ime_toggle.ahk` になります。
利用方法はREADMEを参照してください。
