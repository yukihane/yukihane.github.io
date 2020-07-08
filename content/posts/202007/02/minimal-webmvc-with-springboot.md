---
title: Spring Boot でなるべく依存関係を小さくしてWebMVCを使ってみる
date: 2020-07-02T21:11:04Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [spring-boot, spring-mvc]
# images: []
# videos: []
# audio: []
draft: false
---

特に実用性とかは考えていない。何となくやってみたというだけ。

## 動かしたいやつ

```java:MyController.java
@RestController
@RequestMapping("/")
public class MyController {

    @GetMapping("/")
    public String index() {
        return "hello";
    }
}
```

## 設定

```xml:pom.xml
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot</artifactId>
    </dependency>
    <dependency>
      <groupId>org.springframework</groupId>
      <artifactId>spring-webmvc</artifactId>
    </dependency>
    <dependency>
      <groupId>org.apache.tomcat.embed</groupId>
      <artifactId>tomcat-embed-core</artifactId>
    </dependency>
```

```java:WebConfig.java
@Configuration
@EnableWebMvc
public class WebConfig {

    @Bean
    ServletWebServerFactory servletWebServerFactory() {
        return new TomcatServletWebServerFactory(8080);
    }

    @Bean
    DispatcherServlet dispatcherServlet() {
        return new DispatcherServlet();
    }
}
```

```java:MyApplication.java
@ComponentScan
public class MyApplication {
	public static void main(final String[] args) {
		SpringApplication.run(MyApplication.class, args);
	}
}
```
