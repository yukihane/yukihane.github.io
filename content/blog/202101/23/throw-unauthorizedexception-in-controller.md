---
title: "ControllerでUnauthorizedExceptionを投げると401でなく403になる"
date: 2021-01-23T14:14:04Z
draft: false
tags:
  - spring-boot
  - spring-security
---

- [Authentication handling in Spring boot 2.x with WebSecurityConfigurerAdapter](https://stackoverflow.com/q/65757377/4506703) - Stack Overflow

[`Http403ForbiddenEntryPoint`](https://github.com/spring-projects/spring-security/blob/5.3.3.RELEASE/web/src/main/java/org/springframework/security/web/authentication/Http403ForbiddenEntryPoint.java#L38-L39) がデフォルトで設定されているため、 [`ExceptionTranslationFilter`](https://github.com/spring-projects/spring-security/blob/5.3.3.RELEASE/web/src/main/java/org/springframework/security/web/access/ExceptionTranslationFilter.java#L51-L52) において [`AuthenticationException` のサブクラス](https://github.com/spring-projects/spring-security/blob/5.3.3.RELEASE/web/src/main/java/org/springframework/security/web/access/ExceptionTranslationFilter.java#L169)は全て `403` になっている模様。

認証通った上でunauthorizedってことはforbiddenなんだよな？ということでしょうか。…この言い方だと全然ニュアンス伝わらないか。

- [9.6. Handling Security Exceptions](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#servlet-exceptiontranslationfilter)

にこの辺りの図解がありました。
