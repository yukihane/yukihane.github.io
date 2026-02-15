---
title: "Spring-BootでJSPを使う"
date: 2020-07-10T21:54:33Z
draft: false
tags:
  - spring-boot
  - jsp
---

<https://start.spring.io/> で depencencies に `Spring Web` を追加して生成します。

生成された `pom.xml` に次の依存関係を追加します:

<div class="formalpara-title">

**pom.xml**

</div>

``` xml
<dependency>
    <groupId>org.apache.tomcat.embed</groupId>
    <artifactId>tomcat-embed-jasper</artifactId>
</dependency>
<dependency>
    <!-- 必要に応じて -->
    <groupId>javax.servlet</groupId>
    <artifactId>jstl</artifactId>
</dependency>
```

`appliction.properties` に次を追加します:

<div class="formalpara-title">

**application.properties**

</div>

``` properties
spring.mvc.view.prefix=/WEB-INF/view/
spring.mvc.view.suffix=.jsp
```

`src/main/webapp/WEB-INF/view/` の下に JSP ファイルを作成します。

コントローラではThymeleaf利用時などと同様、 `return "index";` とすることで `index.jsp` を返すようになります。

参考:

- [Spring Boot version 1 のころのサンプル `pom.xml`](https://repo.spring.io/release/org/springframework/boot/spring-boot-sample-web-jsp/1.0.0.RC1/spring-boot-sample-web-jsp-1.0.0.RC1.pom)

出典:

- [Can you use jsp for your front end while your backend routes are restful in Spring Boot?](https://stackoverflow.com/a/62545655/4506703) - Stack Overflow

  - [サンプルコード](https://github.com/yukihane/stackoverflow-qa/tree/master/en62542331)
