---
title: "Spring Sessionをインメモリで利用する"
date: 2021-01-24T13:31:55Z
draft: false
tags:
  - spring-boot
  - spring-session
---

- [What should be a replacement for StoreType.HASH_MAP in spring-boot 2](https://stackoverflow.com/q/48906697/4506703)

昔は `spring.session.store-type` の選択肢に `hash_map` というものがあったようですが、現在は存在しません。(ちなみに `none` は Spring Session を利用しない、という意味になるようで、挙動が変わってしまいます( `JSESSIONID` と `SESSIONID` とか))

ではどうすれば良いかというと、(上のStack Overflowにも回答がありますが)

- [9.5. Using @EnableSpringHttpSession](https://docs.spring.io/spring-session/docs/current/reference/html5/#api-enablespringhttpsession)

<!-- -->

    @EnableSpringHttpSession
    @Configuration
    public class SpringHttpSessionConfig {

        @Bean
        public MapSessionRepository sessionRepository() {
            return new MapSessionRepository(new ConcurrentHashMap<>());
        }

    }

というコンフィグ設定を行えば良いようです。
