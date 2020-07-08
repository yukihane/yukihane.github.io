---
title: "%s に null を渡したらどうなるんだっけ"
date: 2019-06-11T20:19:09Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java]
# images: []
# videos: []
# audio: []
draft: false
---

# こたえ

文字列 `null` が出力される。

# コード

        final String text = null;
        System.out.printf("%s", text);

# 参考

- [java.util.Formatter](https://docs.oracle.com/en/java/javase/12/docs/api/java.base/java/util/Formatter.html)

> For category General, Character, Numberic, Integral and Date/Time conversion, unless otherwise specified, if the argument arg is null, then the result is "null".

リンク先の表にある通り、 `s` はカテゴリ"general"に属す。ちなみに[日本語](https://docs.oracle.com/javase/jp/12/docs/api/java.base/java/util/Formatter.html#syntax)ではこうなっている(わかりにくい):

> カテゴリ「一般」、Character、「数」、「積分」および Date/Time 変換では、特に指定しない限り、引数 arg が null の場合、結果は"null"です。
