---
title: "finalと実質finalの違い"
date: 2020-02-21T06:53:19Z
draft: false
tags:
  - java
---

<https://ja.stackoverflow.com/a/63099/2808> を見ていて気づいたのですが、 `実質final` というのは脳内(コンパイラ)で `final` を補完してくれる、というような処理が行われるわけではないのですね。

下記コード中の(2) と (3) の違いは、連結前の `String` 変数を `final` 付きで宣言しているか否かだけですが、結果がお互い異なっています。

``` java
        String literal_neko = "ネコ";
        String literal_ne_ko = "ネ" + "コ";

        // (1) https://docs.oracle.com/javase/specs/jls/se13/html/jls-3.html#jls-3.10.5
        System.out.println("literal_neko == literal_ne_and_ko: " + (literal_neko == literal_ne_ko)); // true

        // (2) finalなStringの連結: true
        final String final_ne = "ネ";
        final String final_ko = "コ";
        String final_ne_and_final_ko = final_ne + final_ko;

        System.out.println("literal_neko == final_ne_final_ko: " + (literal_neko == final_ne_and_final_ko)); // true

        // (3) 非final(だが実質final)なStringの連結: false
        String ne = "ネ";
        String ko = "コ";
        String ne_and_ko = ne + ko;

        System.out.println("literal_neko == ne_and_ko: " + (literal_neko == ne_and_ko)); // false
```
