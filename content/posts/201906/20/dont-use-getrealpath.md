---
title: ファイル出力先にServletContext#getRealPathを使うな
date: 2019-06-20T20:26:49Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java, servlet]
# images: []
# videos: []
# audio: []
draft: false
---

色んなところでそういうサンプルコードが見つかる、と聞いて嘘やん思いながら検索してみたところ、日本語英語を問わず確かに多い。
例えば Qiita では(順不同):

- [SpringMVC と JasperReports で帳票を印刷してみた 番外編（画像編）](https://qiita.com/shibafu/items/a660ce88e3e8a1d6902d)
- [jsp(servlet)の画像アップロードについて](https://qiita.com/yume21116/items/bc31262cae137daee32f)
- [JSP/サーブレット ファイルアップロードの実装](https://qiita.com/ohke/items/bec00a69d3f538aab06b)
- [画像の保存と紐付けの同時アップロード](https://qiita.com/yume21116/items/8a6c0117ac866eb9a058)
- [画像アップロードのパスの設定について](https://qiita.com/k499778/items/0ab656a612456741924b)

#### なんでつこたらアカンの？

[リンク先](https://ja.stackoverflow.com/a/55904/2808)に長文書いてもたんでそっち見て。
どこの馬の骨が書いたかわからん説明信じられるか？はい、そんな人のために upvoted 数の多い Stack Overflow の記事をご用意しました:

- [Recommended way to save uploaded files in a servlet application](https://stackoverflow.com/q/18664579/4506703)

[いかがでしたか？](https://www.google.co.jp/search?q=%E3%81%84%E3%81%8B%E3%81%8C%E3%81%A7%E3%81%97%E3%81%9F%E3%81%8B%EF%BC%9F)

# 何も考えずに今までファイルアップロードをコピペ実装したことがある人、先生怒らないから手を挙げなさい

てかなんでこんな実装インターネット上に氾濫してんのやろ？
オフィシャルがそうやってるからやろか…と思て[The Java EE Tutorial](https://docs.oracle.com/javaee/7/tutorial/servlets016.htm)見てみたらクライアントが path 指定するようになってた。

**なお悪いわ！！**

(おわり)
