---
title: "RestTemplateが採用するHTTPクライアント実装の順序"
date: 2021-07-24T19:53:33Z
draft: false
tags:
  - spring-boot
---

> By default the built RestTemplate will attempt to use the most suitable ClientHttpRequestFactory
>
> —  [RestTemplateBuilder JavaDoc](https://docs.spring.io/spring-boot/docs/2.5.3/api/org/springframework/boot/web/client/RestTemplateBuilder.html)

とありますが、具体的にどうやって決めているの？という話です。

[`ClientHttpRequestFactorySupplier`](https://github.com/spring-projects/spring-boot/blob/v2.5.3/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/client/ClientHttpRequestFactorySupplier.java)をみると一目瞭然ですが、

1.  Apache HttpClient (`org.apache.http.client.HttpClient`) がクラスパスに存在すればそれを採用する

2.  OkHttp (`okhttp3.OkHttpClient`) がクラスパスに存在すればそれを採用する

3.  上記のものがいずれも無ければ `java.net.HttpURLConnection` を採用する

という実装になっています。
