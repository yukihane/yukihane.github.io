---
title: SimpleDateFormat もこれもうわかんねぇな
date: 2019-06-11T20:23:06Z
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

# 結果

## 1.8

```
H
```

## 11

```
平成
```

# 環境

## 1.8

```
java version "1.8.0_201"
Java(TM) SE Runtime Environment (build 1.8.0_201-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.201-b09, mixed mode)
```

## 11

```
openjdk version "11.0.2" 2019-01-15
OpenJDK Runtime Environment 18.9 (build 11.0.2+9)
OpenJDK 64-Bit Server VM 18.9 (build 11.0.2+9, mixed mode)
```

# コード

```
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.util.Date;
import java.util.Locale;

public class Main {

    public static void main(final String[] args) {
        final Date date = date(2010, 3, 4);
        final SimpleDateFormat format = new SimpleDateFormat("G", new Locale("ja", "JP", "JP"));
        System.out.println(format.format(date));
    }

    private static Date date(final int year, final int month, final int dayOfMonth) {
        final long time = LocalDate.of(year, month, dayOfMonth)
            .atStartOfDay(ZoneOffset.ofHours(9)).toEpochSecond() * 1000;
        return new Date(time);
    }
}
```

# 関連(しない)

- [DateTimeFormatter とかこれもうわかんねぇな](https://qiita.com/yukihane/items/9001b15a44d56b1dda23)

# 関連(する)

- [JDK-8216204 Wrong SimpleDateFormat behavior with Japanese Imperial Calendar](https://bugs.openjdk.java.net/browse/JDK-8216204)

> From JDK 9 onwards, the default locale data is the data derived from the Unicode Consortium's Common Locale Data Repository (CLDR). Please refer https://www.unicode.org/cldr/charts/33/by_type/date_&_time.japanese.html
> The short display format for Heisei is 平成 in the ja locale in CLDR data. Hence the difference in the result.

> To use the JRE locale with JDK 9 set java.locale.providers to a value with COMPAT ahead of CLDR. :
> -Djava.locale.providers=COMPAT, CLDR

- [Use CLDR locale data by default - JDK 9 Release Notes](https://www.oracle.com/technetwork/java/javase/9-relnote-issues-3704069.html#JDK-8008577)

> -Djava.locale.providers=COMPAT,SPI

いやどっちやねん。
