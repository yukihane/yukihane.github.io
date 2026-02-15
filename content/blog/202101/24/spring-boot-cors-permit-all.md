---
title: "Spring Boot の CORS 設定を全許可する"
date: 2021-01-24T13:59:39Z
draft: false
tags:
  - spring-boot
---

- [How to configure CORS in a Spring Boot + Spring Security application?](https://stackoverflow.com/a/65867566/4506703) - Stack Overflow

Spring Boot のリファレンス [4.7.1. The “Spring Web MVC Framework” \> CORS Support](https://docs.spring.io/spring-boot/docs/2.4.2/reference/htmlsingle/#boot-features-cors) を見ると、次のように設定すれば良いように見えます。

``` java
// https://docs.spring.io/spring-boot/docs/2.4.2/reference/htmlsingle/#boot-features-cors
@Configuration
public class MyConfiguration {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(final CorsRegistry registry) {
                registry.addMapping("/**").allowedMethods("*").allowedHeaders("*");
            }
        };
    }
}
```

この設定は Spring MVC だけを使っている場合には上手くいきますが、 `spring-boot-starter-security` を導入するとクライアントサイドでCORSの問題で通信が失敗するような状況が発生します。

なぜならば、 [プリフライトリクエスト](https://developer.mozilla.org/ja/docs/Web/HTTP/CORS#preflighted_requests) には [`Authorization` ヘッダ(等、規定されていないヘッダ)が含まれない](https://fetch.spec.whatwg.org/#cors-preflight-fetch)ため、プリフライトリクエストがSpring Securityフィルタで `401 Unauthorized` になって Spring MVC 部分まで到達しないからです。

幸い、Spring Securityには [上記で設定したCORS設定を `CorsFilter` で統合できます](https://docs.spring.io/spring-security/site/docs/5.4.2/reference/html5/#cors)。 コンフィグで CORS 有効化すればデフォルトでそのような設定になります。

``` java
// https://docs.spring.io/spring-security/site/docs/5.4.2/reference/html5/#cors
@EnableWebSecurity
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(final HttpSecurity http) throws Exception {
        // ...

        // 大抵の場合、CSRF対策機能は無効化する必要があるでしょう
        // (CORSを許可する必要がある = JSリクエスト なので)
        http.csrf().disabled();

        // if Spring MVC is on classpath and no CorsConfigurationSource is provided,
        // Spring Security will use CORS configuration provided to Spring MVC
        http.cors(Customizer.withDefaults());
    }
}
```

[サンプルコード](https://github.com/yukihane/hello-java/tree/master/spring/cors/cors-sample)
