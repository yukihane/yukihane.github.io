---
title: "GWTコンパイル時間増大問題"
date: 2020-07-26T02:22:47Z
draft: false
---

# 問題解説

GWTアプリケーションの規模が大きくなると、コンパイル時間が非常に長くかかってしまうようになる問題。

非常に長くかかる、というのは、自身が関わったプロジェクトの体験で言うと、20分弱程度(当時のかなり高速なCPU/SSDを用いていたにもかかわらず)。

# 対策要旨

アプリケーションを分割する。

エントリポイントを複数に分け、それらを統合して1つのWebアプリケーションとする。

# 参考実装

<https://github.com/yukihane/hello-turducken>

# 参考

- <https://www.slideshare.net/RobertKeane1/turducken-divide-and-conquer-large-gwt-apps-with-multiple-teams>\[Turducken

  - Divide and Conquer large GWT apps with multiple teams\], Robert Keane, GWT.create 2013.

    - Turduckenパターンという命名, パターンの提案
