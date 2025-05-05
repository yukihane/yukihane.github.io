---
title: "Thymeleafのformのバインドにrecord classは使わない方が良さそう"
date: 2025-05-05T11:59:23+09:00
tags: ["spring-boot", "java"]
draft: false
---

[前回](/blog/202505/04/kotlin-form-binding.md) のつづき。

あれ、そういえばJavaのrecord classも似たような性質だな、ということはrecord classもform bindingには使えないのかな？でもあまりそんな話聞いたこと無いな、どうなんだろう…と思い検索してみたのですが、ヒットしたのは自分の記事でしたｗ

- [Spring MVC で Java17 record を試してみる](/blog/202110/18/java17-record-on-spring-mvc/)

当時は使えそう、という結論でしたが、今見返すと正常系しか試しておらず、エッジケースは試せていなさそうです。

というわけで、前回と同じように `LocalDate` に妥当でない形式の文字列を設定できるコードを書いてみました:

- [ソースコード](https://github.com/yukihane/hello-java/tree/main/spring/record-spring-mvc-form)

実行してみると…やはり前回と同じ例外が出ました。

```
Caused by: org.springframework.expression.spel.SpelEvaluationException: EL1007E: Property or field 'name' cannot be found on null
```

うーん、[thyemeleaf](https://github.com/thymeleaf/thymeleaf/issues)や[thymeleaf-spring](https://github.com/thymeleaf/thymeleaf-spring/issues)のissuesの動きを見ても、もはや活発とは言えなさそうな雰囲気ですよね。
積極的にthymeleafを利用するのはもう時代にそぐわないのかもしれません。
