---
title: 元号が令和に変わったことを知らない人のための日付処理方法
date: 2019-06-12T20:24:45Z
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

# 問題

`JapaneseDate.of`(や `LocalDate.of`)を使うと厳密(strict)に検証されてしまう。
結果、例外が出る。

```
// 平成31年6月12日
final JapaneseDate today = JapaneseDate.of(JapaneseEra.HEISEI, 31, 6, 12);
System.out.println(today);
```

```
Exception in thread "main" java.time.DateTimeException: year, month, and day not valid for Era
	at java.base/java.time.chrono.JapaneseDate.of(JapaneseDate.java:231)
	at com.github.yukihane.datetime.App.main(App.java:21)
```

# 解決策

`JapaneseChronology#resolveDate`(や `IsoChronology#resolveDate`)を使えばゆるふわ(lenient)な検証でゆるしてくれたりも。

```
final Map<TemporalField, Long> fieldValues = new HashMap<>();
fieldValues.put(ChronoField.ERA, (long) JapaneseEra.HEISEI.getValue());
fieldValues.put(ChronoField.YEAR_OF_ERA, 31L);
fieldValues.put(ChronoField.MONTH_OF_YEAR, 6L);
fieldValues.put(ChronoField.DAY_OF_MONTH, 12L);
final JapaneseDate today = JapaneseChronology.INSTANCE.resolveDate(fieldValues, ResolverStyle.LENIENT);
System.out.println(today);
```

```
Japanese Reiwa 1-06-12
```

しかしよく考えるとデフォルト(的)挙動が strict モードって和暦扱うところでは怖いよな。
お隠れになると(※もはや改元はお隠れになられた場合だけではなくなったが)今までちゃんと動いていたところが例外出るようになるんだぜ…

# 参考

- [AbstractChronology#resolveDate - Java API doc](<https://docs.oracle.com/javase/jp/12/docs/api/java.base/java/time/chrono/AbstractChronology.html#resolveDate(java.util.Map,java.time.format.ResolverStyle)>)

> - YEAR_OF_ERA と ERA - 両方とも存在する場合、それらが組み合わされて YEAR を形成します。 lenient モードでは YEAR_OF_ERA の範囲は検証されず、smart および strict モードでは検証されます。

`smart`は平成 31 年 6 月は許してくれるけど平成 32 年 6 月は許してくれない。賢いか…？
(※ 検証するのは"YEAR_OF_ERA の範囲"だけだから言ってることとやってることは合ってる)
