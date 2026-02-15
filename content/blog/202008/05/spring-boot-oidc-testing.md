---
title: "Spring Security OAuth 2.0 Login を自動テストする"
date: 2020-08-04T21:39:37Z
draft: false
tags:
  - spring-boot
  - spring-security
  - oauth
  - oidc
---

[KeycloakをIdPにしてSpring Security OAuth 2.0 Login/Client を試してみる]({{< relref"/blog/202007/21/hello-oidc-with-keycloak">}}) で作成したプログラムの自動テスト方法です。

今回のコードも前回と同じく次のディレクトリにあります:

- <https://github.com/yukihane/hello-java/tree/master/spring/oidc-example>

まず結論なのですが、リファレンスに説明がありますのでここを参照しましょう、ということになります:

- [Testing OAuth 2.0 Clients](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#testing-oauth2-client) - 19.2.2. SecurityMockMvcRequestPostProcessors

実際のコードがこちらです。

``` java
@WebMvcTest
class HelloControllerTest {

    @Autowired
    ClientRegistrationRepository clientRegistrationRepository;

    /**
     * 未ログイン状態の場合、IdPへリダイレクトする。
     */
    @Test
    public void 未ログイン状態(@Autowired final MockMvc mvc) throws Exception {
        mvc.perform(get("/")).andExpect(status().is3xxRedirection())
            .andExpect(header().exists("Location"));
    }

    @Test
    public void ログイン状態(@Autowired final MockMvc mvc) throws Exception {

        // https://docs.spring.io/spring-security/site/docs/current/reference/html5/#testing-oauth2-client
        mvc.perform(
            get("/")
                .with(oidcLogin()
                    .clientRegistration((this.clientRegistrationRepository.findByRegistrationId("myspring")))

                ))
            .andExpect(status().isOk());
    }

    @TestConfiguration
    static class AuthorizedClientConfig {
        @Bean
        OAuth2AuthorizedClientRepository authorizedClientRepository() {
            return new HttpSessionOAuth2AuthorizedClientRepository();
        }
    }

}
```

`spring-security-oauth2` (何回も書きますが現在利用すべき Spring Security OAuth 2.0 Client とは別のライブラリです)時代は、 [`@WithMockUser`](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#test-method-withmockuser) や、 [`@WithSecurityContext`](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#test-method-withsecuritycontext) を利用してモック認証ユーザを作成していましたが、現在のライブラリではそのようにアノテーションで設定する方針は採らないようです。

> I think we avoided annotation support for OIDC because it was not very easy for users to customize the OidcUser and OAuth2AuthenticationToken objects (the attributes are rich objects which cannot easily be modified by an annotation). Instead, we felt that user’s could set SecurityContextHolder directly for method support or use the oidcLogin support for MockMvc style testing.
>
> —  , [spring-security-test @WithMockOidcuser gh-8459 \#8461](https://github.com/spring-projects/spring-security/pull/8461#issuecomment-624229723)

続いて別の話なのですが、[前回]({{< relref"/blog/202007/21/hello-oidc-with-keycloak">}})、 `issuer-uri` だけ設定すれば他の設定が色々省略できて便利、と書きましたが、 `issuer-uri` を設定してしまうと(そして他の設定を省略すると) テスト開始時IdPへアクセスしに行こうとしてしまうようです。IdPに接続できないとテストが失敗します。

これを避けるために、結局、 `authorization-uri` などは明記する、というところで落ち着きました。
