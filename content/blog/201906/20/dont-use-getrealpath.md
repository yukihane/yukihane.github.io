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

タイトルに書いたような、ファイル出力先として `ServletContext#getRealPath` を利用しているサンプルコードが見つかる、と聞いて検索してみたところ、日本語、非日本語にかかわらず確かにそのようなサンプルコードは散見されました。
例えば Qiita では(順不同):

- [SpringMVC と JasperReports で帳票を印刷してみた 番外編（画像編）](https://qiita.com/shibafu/items/a660ce88e3e8a1d6902d)
- [jsp(servlet)の画像アップロードについて](https://qiita.com/yume21116/items/bc31262cae137daee32f)
- [JSP/サーブレット ファイルアップロードの実装](https://qiita.com/ohke/items/bec00a69d3f538aab06b)
- [画像の保存と紐付けの同時アップロード](https://qiita.com/yume21116/items/8a6c0117ac866eb9a058)
- [画像アップロードのパスの設定について](https://qiita.com/k499778/items/0ab656a612456741924b)

#### どうして利用しては駄目なのか

[Stack Overflow](https://ja.stackoverflow.com/a/55904/2808)に理由を記載しています。
私の説明だけでは不安なのであれば、次も参照してみてください。

- [Recommended way to save uploaded files in a servlet application](https://stackoverflow.com/q/18664579/4506703) - Stack Overflow

ちなみに、[The Java EE Tutorial](https://docs.oracle.com/javaee/7/tutorial/servlets016.htm)見てみたらクライアントが path 指定するようになってました…まあ、変に正しい実装はこれだと混乱させることは無い分まし、なの、かな…？
