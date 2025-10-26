---
title: Spring 2.3.0 で時刻オフセットの書式コロン付き+09:00みたいに変わっとるやん
date: 2020-06-30T21:09:44Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: ["jackson", "spring-boot", "datetime"]
# images: []
# videos: []
# audio: []
draft: false
---

正確には jackson-databind 2.11.0 で。

- [jackson 2.11 リリースノート](https://github.com/FasterXML/jackson/wiki/Jackson-Release-2.11#changes-behavior)
- [Change default textual serialization of `java.util.Date`/`Calendar` to include colon in timezone offset #2643](https://github.com/FasterXML/jackson-databind/issues/2643)

[このへん](https://docs.spring.io/spring-boot/docs/2.2.8.RELEASE/reference/htmlsingle/#dependency-versions-coordinates)見ると分かるけど、Spring Boot 2.2 系列は jackson-databind 2.10.x が採用されていて、 [2.3.0](https://docs.spring.io/spring-boot/docs/2.3.0.RELEASE/reference/htmlsingle/#dependency-versions-coordinates) で 2.11.0 が採用されている。

コード:

```java
    @GetMapping("/")
    public Date date() {
        return new Date();
    }
```

結果(2.2.8):

```
"2020-06-30T13:46:24.265+0000"
```

結果(2.3.1):

```
"2020-06-30T13:47:09.532+00:00"
```

2.2.x 書式に戻したいならプロパティで:

```
spring.jackson.date-format=yyyy-MM-dd'T'HH:mm:ss.SSSZ
```

書式は[`SimpleDateFormat`のリファレンス](https://docs.oracle.com/en/java/javase/11/docs/api/java.base/java/text/SimpleDateFormat.html)参照。

ところで上記リファレンスを見ると 2.2.x で 2.3.x の書式にしようとする場合`XXX`が利用できそうに思われるが`+00:00`のとき`Z`と表現されてしまって同等にはならない。

jackson-databind 的には [`StdDateFormat#withColonInTimeZone()`](https://github.com/FasterXML/jackson-databind/blob/jackson-databind-2.10.4/src/main/java/com/fasterxml/jackson/databind/util/StdDateFormat.java#L251)で設定して欲しいところだと思うが、Spring Boot から簡単に設定変更するパスはなさそう。

いかがでしたか？
