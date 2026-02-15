---
title: "VSCode でエラー/警告アンダーラインの区別がつかない"
date: 2021-10-25T17:31:42+09:00
draft: false
---

VSCode のデフォルトの色設定だと、エラーの波線と警告の波線との区別が私の目では付けづらいのです。 おそらく赤色と黄色だと思うのですが…

色についてのプロパティは次のリンク先に説明がありました。

- <https://code.visualstudio.com/api/references/theme-color>

今回は警告色を少し暗めにしてエラー色と区別できるようにすることにしました。

``` json
{
  "workbench.colorCustomizations": {
    "editorWarning.foreground": "#00588f"
  }
}
```

この設定で下波線と、サイドバー(スクロールバー)に表示される色が変わりました。 サイドバーの色はいったんエディタを全て閉じないと反映されないかもしれません。
