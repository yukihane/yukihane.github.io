---
title: text/plain で JSON を投げつけてくるヤツに対処する
date: 2019-05-21T20:12:30Z
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

- [RestTemplate でレスポンスの Content-Type を変更する。](https://qiita.com/masato_ka/items/aa5f158a94eca1fcc42d)

の別解。

    @Autowired
    private RestTemplateBuilder builder;

    ...
        final MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
        converter.setSupportedMediaTypes(Arrays.asList(MediaType.TEXT_PLAIN));
        final RestTemplate restTemplate = builder.additionalMessageConverters(converter).build();

ちなみに上記のようにコンバータを明示的に設定しない場合だと次のような例外になる :

    org.springframework.web.client.HttpClientErrorException$NotAcceptable: 406 Not Acceptable
        at org.springframework.web.client.HttpClientErrorException.create(HttpClientErrorException.java:89)
        at org.springframework.web.client.DefaultResponseErrorHandler.handleError(DefaultResponseErrorHandler.java:122)
        at org.springframework.web.client.DefaultResponseErrorHandler.handleError(DefaultResponseErrorHandler.java:102)
        at org.springframework.web.client.ResponseErrorHandler.handleError(ResponseErrorHandler.java:63)
        at org.springframework.web.client.RestTemplate.handleResponse(RestTemplate.java:778)
        at org.springframework.web.client.RestTemplate.doExecute(RestTemplate.java:736)
        at org.springframework.web.client.RestTemplate.execute(RestTemplate.java:710)
        at org.springframework.web.client.RestTemplate.postForEntity(RestTemplate.java:463)
