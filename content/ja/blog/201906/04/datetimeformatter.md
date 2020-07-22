---
title: DateTimeFormatter とかこれもうわかんねぇな
date: 2019-06-04T20:16:49Z
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

# コード

```
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

public class App {

    private static String format(final LocalDate date, final String pattern) {
        return date.format(DateTimeFormatter.ofPattern(pattern, Locale.JAPAN));
    }

    public static void main(final String[] args) {
        final LocalDate today = LocalDate.of(2019, 6, 4);

        System.out.println(format(today, "M"));
        System.out.println(format(today, "MM"));
        System.out.println(format(today, "MMM"));
        System.out.println(format(today, "MMMM"));
        System.out.println(format(today, "MMMMM"));
        System.out.println(format(today, "MMMMMM"));
    }
}
```

# 結果

| パターン | 結果                                                  |
| -------- | ----------------------------------------------------- |
| M        | 6                                                     |
| MM       | 06                                                    |
| MMM      | 6 月                                                  |
| MMMM     | 6 月                                                  |
| MMMMM    | 6                                                     |
| MMMMMM   | IllegalArgumentException: Too many pattern letters: M |

```
$ java -version
openjdk version "11.0.2" 2019-01-15
OpenJDK Runtime Environment 18.9 (build 11.0.2+9)
OpenJDK 64-Bit Server VM 18.9 (build 11.0.2+9, mixed mode)
```

# 参考(にならなかった)リンク

- [java.time.format.DateTimeFormatter](https://docs.oracle.com/javase/jp/12/docs/api/java.base/java/time/format/DateTimeFormatter.html)

# 参考(にややなった)リンク

- [java.time.format.DateTimeFormatterBuilder#appendPattern](<https://docs.oracle.com/javase/jp/12/docs/api/java.base/java/time/format/DateTimeFormatterBuilder.html#appendPattern(java.lang.String)>)

# 関連(しない)

- [SimpleDateFormat もこれもうわかんねぇな](https://qiita.com/yukihane/items/0d97e5b8666254719186)
