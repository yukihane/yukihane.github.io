---
title: "script src に設定する URL の & はどう書けば良い？"
date: 2021-05-18T22:38:11Z
draft: false
tags:
  - html
---

`<script>` タグの `src` に `URL` 書く場合、クエリパラメータ連結の `&` ってどう書くべきなんだろう、という話です。

結論としては、以下のように、 `&amp;` とするのが無難、ということのようです。

``` html
<script src="http://example.com/?foo=1&amp;bar=2"></script>
```

- [Should src be HTML-escaped in script tags in HTML? - Stack Overflow](https://stackoverflow.com/a/26918445/4506703)

からリンクされている "HTML Living Standard — Last Updated 18 May 2021 [13.2.5.36 Attribute value (double-quoted) state](https://html.spec.whatwg.org/multipage/parsing.html#attribute-value-(double-quoted)-state)" によると、ダブルクオートされた(※シングルクオートも[同じ](https://html.spec.whatwg.org/multipage/parsing.html#attribute-value-(single-quoted)-state))文字列中に `&` が表れた場合、取り敢えず [文字参照](https://ja.wikipedia.org/wiki/%E6%96%87%E5%AD%97%E5%8F%82%E7%85%A7) であるとみなそうとするので誤動作を引き起こす可能性がある、ようです。

とすると、 `<a>` タグの `href` も同様にエスケープする必要がありそうですね。…とググった結果(そのとおりでした):

- [Do I encode ampersands in \<a href…​\>? - Stack Overflow](https://stackoverflow.com/a/3705601/4506703)
