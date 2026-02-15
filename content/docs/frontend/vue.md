---
title: "vue.js"
date: 2020-07-23T15:53:22Z
draft: false
---

# 初歩的な疑問/TIPSなど

## htmlの書き下しを簡単に行う

Emmetというプラグイン？がある。 [VSCodeには標準で入っていた](https://code.visualstudio.com/docs/editor/emmet)。 使い方はググろう。

ユーザ設定で次のように追記すればよい？

``` js
{
    "emmet.includeLanguages": {
        "vue-html": "html",
        "vue": "html"
    }
}
```

<https://github.com/Microsoft/vscode/issues/22585> によると `emmet.syntaxProfiles` で設定するように書かれているが、双方どのような意味の設定なのかわかっていない…

## JavaScript framework によく出てくるrouterとは？

URLを対応する実装と紐づける処理のこと？ URLが指定された際に、何を表示するかを決定するロジック。

# Howto

## 共通メニュー(共通ヘッダ)を作成する

参考:

- [【Vue.js】Vue.jsで共通ヘッダーを作る【header】 - The sky is the limit](http://www.sky-limit-future.com/entry/2017/09/19/131736)
