---
title: h2-consoleとspring-boot-starter-securityと私
date: 2019-07-12T20:33:40Z
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

# 概要

`spring-boot-starter-security` を導入しても http://localhost:8080/h2-console にアクセスしたかった。

作業結果: https://github.com/yukihane/hello-java/tree/master/spring/h2-console-spring-security-example

# 手順

## h2-console が使える依存関係を追加してプロジェクトセットアップ [8113d7](https://github.com/yukihane/hello-java/commit/8113d7bc552c11f3e1cf3d6e64fe97be922d2596)

```pom.xml
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>

```

## h2-console を表示してみる [1b16dc](https://github.com/yukihane/hello-java/commit/1b16dcc49ca9a83dd0a80b947800a63be0d39422)

```application.properties
spring.h2.console.enabled=true
spring.datasource.generate-unique-name=false
```

```schema.sql
create table greeting_table (
  message varchar(256) not null
);
```

(注: `spring.datasource.generate-unique-name` 設定は Spring Boot 2.3.0 からデフォルト値が変わったため必要になったもので、リンク先 Git リポジトリには含まれていません([参考](https://qiita.com/yukihane/items/2be37518f42525c8327d)))

の設定を行った上で http://localhost:8080/h2-console/ へアクセス。

| 項目名       | 設定値             |
| ------------ | ------------------ |
| Driver Class | org.h2.Driver      |
| JDBC URL     | jdbc:h2:mem:testdb |
| User Name    | sa                 |
| Password     | (空)               |

## `spring-boot-starter-security` を追加してアクセスしてみる [61357fe](https://github.com/yukihane/hello-java/commit/61357fe7316c4fca72090466d1cb66a874fcb055)

```pom.xml
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-jdbc</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>
        <dependency>
            <groupId>com.h2database</groupId>
            <artifactId>h2</artifactId>
            <scope>runtime</scope>
        </dependency>
```

http://localhost:8080/h2-console/

![spring-boot-login.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/85594/f802cb71-b4ac-b7e5-5ee8-3dfa2ed9d66c.png)

はいはい[これ](https://qiita.com/yukihane/items/cdb7f348da9b32b2ff4d)ね。 [15e7b26](https://github.com/yukihane/hello-java/commit/15e7b26b3b23ec2c3df4218ff20bbc2b58aed9ed)

```
@Configuration
public class MyWebSecConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(final HttpSecurity http) throws Exception {
    }
}
```

h2-console ログイン画面が表示されるので上で書いたものと同じ入力を行い Connect。

> Whitelabel Error Page
> This application has no explicit mapping for /error, so you are seeing this as a fallback.
>
> Fri Jul 12 11:30:17 JST 2019
> There was an unexpected error (type=Forbidden, status=403).
> Forbidden

なぜなのか。

# 対処 [d4b449b](https://github.com/yukihane/hello-java/commit/d4b449b635c19c2b0a66732ca083aaae3585b36d)

```
@Configuration
public class MyWebSecConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(final HttpSecurity http) throws Exception {
        http.csrf().disable();
        http.headers().frameOptions().disable();
    }
}
```
