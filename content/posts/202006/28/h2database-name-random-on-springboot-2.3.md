---
title: "Spring Boot 2.3.0 から H2Database の名前 jdbc:h2:mem:testdb じゃなくなっとるやん(デフォルトでは)"
date: 2020-06-28T21:05:14Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
# tags: []
# images: []
# videos: []
# audio: []
draft: false
---

前は[ここ](https://qiita.com/yukihane/items/3effe753ce01a2cadd84)に書いた通り固定で `jdbc:h2:mem:testdb` という名前だったのにこれでアクセスできんようになってしもた。

起動ログに

```
o.s.b.a.h2.H2ConsoleAutoConfiguration    : H2 console available at '/h2-console'. Database available at 'jdbc:h2:mem:30591993-9fe2-4068-a5e2-05b263e3495b'
```

みたいに出るのでここで確認しよう。
というか、素直にプロパティで

```
spring.datasource.generate-unique-name=false
```

設定したほうが良いわ自分の場合。

issue:

- [Default spring.datasource.generate-unique-name to true](https://github.com/spring-projects/spring-boot/commit/9ff50f903f691bf0c016313c7ac8de6d04714f97)
