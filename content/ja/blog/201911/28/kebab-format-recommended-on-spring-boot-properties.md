---
title: Spring Boot のプロパティではkebab-formatが推奨されている
date: 2019-11-28T20:38:12Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [spring-boot]
# images: []
# videos: []
# audio: []
draft: false
---

**Relaxed Binding 2.0** という仕組みにより

```
spring.jpa.database-platform=mysql
spring.jpa.databasePlatform=mysql
spring.JPA.database_platform=mysql
```

いずれの形式でも正しくバインドできる。
が、公式ドキュメントからは一番上の `database-platform` が推奨されているように読み取れる。

---

[Relaxed binding](https://github.com/spring-projects/spring-booT/wiki/Spring-Boot-Configuration-Binding#relaxed-binding) - Spring Boot Configuration Binding:

> Spring Boot uses a canonical format that is lower case and use hyphen to separate words.

[Properties Files](https://github.com/spring-projects/spring-boot/wiki/relaxed-binding-2.0#properties-files) - Relaxed Binding 2.0:

> We recommend that properties are stored in lowercase kabab format. i.e. `my.property-name=foo`.
