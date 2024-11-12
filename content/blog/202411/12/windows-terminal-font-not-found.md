---
title: "Windows Terminal を起動するとフォントが無いというエラーが出た"
date: 2024-11-12T20:59:43+09:00
draft: false
tags: ["windows"]
---

久しぶりにWSL2で作業をしようとWindows Terminalを起動するとフォントが存在しない旨のエラーが出ました。

[Cicaフォント](https://github.com/miiton/Cica/releases)を指定しているのですが、以前はこの設定で起動していたし、フォントをアンインストールした記憶もないし...と思ったものの検索してみたところ同じような症状の記事が見つかりました。

- [Windows Terminalのフォントがありません問題の回避｜Re*Index. (ot_inc)](https://note.com/reindex/n/n066a0adffe54)
- [Windows Terminalで選択されたフォントが見つからない | がぶろぐ](https://tech.ateruimashin.com/blog/2021/03/windows-terminal-font/)

取り敢えず対処としては「すべてのユーザーに対してインストール」を実行すれば良さそうなのでフォントファイルを右クリックしたところ、該当メニューが現れませんでした。ちなみにWindows11です。

Windows11では `Shift + 右クリック` で旧来のコンテキストメニューが表示できる、というのをどこかで読んで知っていたので試してみたところ、無事該当の選択肢が現れました。

これで無事エラー無くWindows Terminalが起動するようになりましたが、罠過ぎる...

あと余談ですがこのエントリーをWSL2で書くために[Hugoをsnapでインストール](https://gohugo.io/installation/linux/#snap)したのですが、zshでpathが通らないという問題がありました。

こちらは次のエントリーを参考にして解消しました:
- [snapでインストールしたコマンドがzshでPATH通ってない #Ubuntu - Qiita](https://qiita.com/sameyasu/items/072882ee92bca54906d8)
    - bug report: [Bug #1640514 “/snap/bin is not added to the PATH when using zsh” : Bugs : snapd package : Ubuntu](https://bugs.launchpad.net/ubuntu/+source/snapd/+bug/1640514)
