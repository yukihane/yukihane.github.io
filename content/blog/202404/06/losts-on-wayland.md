---
title: "Wayland では gimp でスクリーンショットを撮れなくなったり xeyes が追従しなくなったり"
date: 2024-04-06T06:00:24+09:00
draft: false
tags:
  - linux
---

セキュリティ上の理由っぽいのですが、最近 Ubuntu でやろうとしてできないことが重なり、あれ？ってなりました。

- [Screenshot not capturing 'snapped' window; Screenshot window pops up behind main GIMP window](https://gitlab.gnome.org/GNOME/gimp/-/issues/8510#note_2014569)

ここで "Screenshot portal" を使えと言われてますが、一般名詞過ぎて検索してもなんのこっちゃでしたが、おそらく以下で説明されている `xdg-desktop-portal` のことですかね…？

- [XDG デスクトップ ポータル](https://wiki.archlinux.jp/index.php/XDG_%E3%83%87%E3%82%B9%E3%82%AF%E3%83%88%E3%83%83%E3%83%97_%E3%83%9D%E3%83%BC%E3%82%BF%E3%83%AB)

xeyes の件はこちら。

- [xeyes doesn’t track mouse pointer unless hovered](https://github.com/microsoft/wslg/issues/408#issuecomment-902489025)

この投稿でも言及されていますが、今はむしろ xeyes が動かないことで、ちゃんと Wayland で実行されているねっていう確認が為されているらしいです。
