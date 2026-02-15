---
title: "Kubernetes the hard wayを試すためのtmux基礎知識"
date: 2020-04-25T02:43:13Z
draft: false
tags:
  - tmux
  - kubernetes
---

[Kubernetes the hard wayをやる](https://github.com/yukihane/kubernetes-the-hard-way)のに\`tmux\`の操作を覚えておくのが良さそうだったので使いそうなものを記載しておくことにしました。

`Ctrl` キーと `b` キーの同時押しを `^b` と表記しています。

| 機能                               | キー操作                       | 補足・説明                                                                                                                                                                                                                                                                   |
|------------------------------------|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 起動                               | `tmux` コマンド                | 当然ですが tmux のセッション外で実行します。                                                                                                                                                                                                                                 |
| デタッチ                           | `^b` `d`                       | 終了とは異なり状態が保存されます。                                                                                                                                                                                                                                           |
| アタッチ                           | `tmux a` コマンド              | `-t <session名>` でアタッチするセッションを選択可能。セッション一覧は `tmux list-sessions` コマンド。                                                                                                                                                                        |
| 上下分割                           | `^b` `"`                       | 分割されたエリアはpaneと呼ばれます。                                                                                                                                                                                                                                         |
| 上下分割したpaneの高さを均等にする | `^b` `Alt+2`                   |                                                                                                                                                                                                                                                                              |
| pane移動                           | `^b` `矢印キー`                | マウスクリックでも。                                                                                                                                                                                                                                                         |
| 全paneに同じ入力を行う/解除する    | `^b` `:setw synchronize-panes` | [the hard wayの説明](https://github.com/yukihane/kubernetes-the-hard-way/blob/master/docs/01-prerequisites.md#running-commands-in-parallel-with-tmux)では `setw` でなく `set` を用いているが、 `set` はセッションに対して適用するコマンド(`setw` はウィンドウに対して適用)。 |
