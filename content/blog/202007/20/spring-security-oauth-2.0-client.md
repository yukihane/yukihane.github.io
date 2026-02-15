---
title: "Spring Security OAuth 2.0 Client の auto-configuration"
date: 2020-07-20T06:36:51Z
draft: false
tags:
  - spring-boot
  - spring-security
  - oauth2
---

- [`OAuth2ClientAutoConfiguration`](https://github.com/spring-projects/spring-boot/blob/v2.3.1.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/servlet/OAuth2ClientAutoConfiguration.java)

上記のクラスが `Import` しているもの(など):

- [`OAuth2ClientRegistrationRepositoryConfiguration`](https://github.com/spring-projects/spring-boot/blob/v2.3.1.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/servlet/OAuth2ClientRegistrationRepositoryConfiguration.java)

  - `ClientRegistrationRepository` bean 定義。

    - [`OAuth2ClientProperties`](https://github.com/spring-projects/spring-boot/blob/v2.3.1.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/OAuth2ClientProperties.java)(`spring.security.oauth2.client`)プロパティから定義を取得して生成するインメモリレジストリを生成。

- [`OAuth2WebSecurityConfiguration`](https://github.com/spring-projects/spring-boot/blob/v2.3.1.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/servlet/OAuth2WebSecurityConfiguration.java)

  - [`OAuth2AuthorizedClientService`](https://github.com/spring-projects/spring-security/blob/5.3.3.RELEASE/oauth2/oauth2-client/src/main/java/org/springframework/security/oauth2/client/OAuth2AuthorizedClientService.java) bean 定義。

  - [`OAuth2AuthorizedClientRepository`](https://github.com/spring-projects/spring-security/blob/5.3.3.RELEASE/oauth2/oauth2-client/src/main/java/org/springframework/security/oauth2/client/web/OAuth2AuthorizedClientRepository.java) bean 定義。

  - `WebSecurityConfigurerAdapter` デフォルト実装。

    - 全てのリクエストに authenticated を要求する。 oauth2Login, oauth2Client 有効化。

リファレンスリンク:

- [`ClientRegistrationRepository`](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#oauth2Client-client-registration-repo)

- [`OAuth2AuthorizedClientRepository` / `OAuth2AuthorizedClientService`](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#oauth2Client-authorized-repo-service)

- 全般として: [12.2. OAuth 2.0 Client](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#oauth2client)
