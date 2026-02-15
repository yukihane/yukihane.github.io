---
title: "KeycloakをIdPにしてSpring Security OAuth 2.0 Login/Client を試してみる"
date: 2020-07-20T18:54:23Z
draft: false
tags:
  - spring-boot
  - spring-security
  - oauth
  - oidc
---

# はじめに

Spring Boot で Spring Security OAuth 2.0 [Login](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#oauth2login) / [Client](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#oauth2client) を利用する手順をまとめます。

また、認可サーバ(IdP)にはローカルで立てたKeycloakを用いますのでそちらのセットアップ手順も記載します。

補足事項: Keycloakは [クライアントライブラリ](https://www.keycloak.org/docs/latest/securing_apps/#java-adapters)も提供しており(Spring系のもので言うと、Spring Securityを利用しないもの、Spring Securityを利用するもの、の2種があるようです。詳細は [実装サンプル](https://github.com/keycloak/keycloak-quickstarts)にあります)、Keycloakを利用するのであればそちらを使うのが良さそうです。 ただし、今回は、最終的にKeycloakをIdPとして使うわけではなく、仮に利用しているだけなので、それらは用いず、Spring Securityの汎用機能 [Spring Security OAuth 2.0 Client](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#oauth2client) を利用します。

# Keycloakセットアップ

参考: [Getting Started](https://www.keycloak.org/getting-started) \> [Keycloak on OpenJDK](https://www.keycloak.org/getting-started/getting-started-zip)

## ダウンロードと展開

<https://www.keycloak.org/downloads> からスタンドアロンサーバをダウンロードして展開します(これはWildFlyベースのサーバのようです)。本エントリ記載時点では <https://downloads.jboss.org/keycloak/10.0.2/keycloak-10.0.2.tar.gz> です。

## Keycloak起動

続いて、Keycloakを起動します(この起動方法がまさにWildFlyですね)。

``` bash
./bin/standalone.sh -Djboss.socket.binding.port-offset=1
```

## admin ユーザ作成

adminユーザ未作成状態で <http://localhost:8081/auth/> へアクセスすると、adminユーザのユーザ名とパスワード入力を促されます。

ここではユーザ名、パスワードとも `admin` とすることにします。

|          |       |
|----------|-------|
| Username | admin |
| Password | admin |

**Create** ボタンを押すと上記で入力したadminユーザが作成されます。

[Administration Console](http://localhost:8081/auth/admin/) リンクを押して次の画面に進みます。

## realm作成

Administration Console を開くと、左上に "Master" というプルダウンメニューのようなものがあると思います。

ここにマウスカーソルを合わせると "Add realm" というボタンが表れるのでそれを押します。そうすると <http://localhost:8081/auth/admin/master/console/#/create/realm> へ遷移します。

Nameに `myrealm` と入力ｋし、 Create ボタンを押します。

|      |         |
|------|---------|
| Name | myrealm |

作成が完了すると Administration Console 画面に戻ります。 このとき、左上のrealm名画先ほど作成した "Myrealm" になっていると思います。

続いてこの画面からユーザを作成します。

## ユーザ作成

画面左のメニュー [Users](http://localhost:8081/auth/admin/master/console/#/realms/myrealm/users) を選択し、 "Add user" ボタンを押します。

Usernameに `myuser` を、それ以外の項目も適当に埋め "Save" ボタンを押します。

|            |                    |
|------------|--------------------|
| Username   | myuser             |
| Email      | myuser@example.com |
| First Name | my-firstname       |
| Last Name  | my-lastname        |

ユーザ作成が完了したら、続いてパスワード設定を行います。 画面上部の "Credentials" タブをクリックして開き、パスワードを設定します。ここではユーザ名と同じ `myuser` としました。 また、"Temporary"を `OFF` にしておきます(ONだと初回ログイン時パスワード変更を求められます)。

|                       |        |
|-----------------------|--------|
| Password              | myuser |
| Password Confirmation | myuser |
| Temporary             | OFF    |

そして、 "Set Password" ボタンを押しパスワード設定完了です。

## クライアント登録

ここでいう "クライアント" というのはOAuth2.0でいうところの認可クライアント、OIDCでいうところのRPです。

画面左のメニュー [Clients](http://localhost:8081/auth/admin/master/console/#/realms/myrealm/clients) をクリックします。

続いて画面右の [Create](http://localhost:8081/auth/admin/master/console/#/create/client/myrealm)ボタンを押します。

この画面で次のように入力して、 "Save" ボタンを押します。

|                 |                                   |
|-----------------|-----------------------------------|
| Client ID       | myclient                          |
| Client Protocol | openid-connect (デフォルトのまま) |
| Root URL        | (空のままでOK)                    |

クライアント作成が完了したら続いてこのクライアント設定画面で 次の通り設定変更し "Save" ボタンを押します。

( `myspring` というのは、後でSpring Bootに設定する `registration-id` です。詳細は [Spring Security リファレンス](https://docs.spring.io/spring-security/site/docs/current/reference/html5/#oauth2login-sample-redirect-uri)を "/login/oauth2/code" で検索してみてください)

|                    |                                                  |
|--------------------|--------------------------------------------------|
| Access Type        | confidential                                     |
| Valid Redirect URL | http://localhost:8080/login/oauth2/code/myspring |

上記の通り Access Type を `confidential` に設定すると、この画面上部に "Credentials" タブが表示されます。 このタブで client-secret を確認できます。

これで認可サーバであるKeycloak側の設定は終了です。

続いて、この認可サーバを利用するクライアントをSpring Bootで作っていきます。

# クライアント(Spring Boot)設定

コードはこちらになります。

- <https://github.com/yukihane/hello-java/tree/master/spring/oidc-example>

はじめに、で記載した通り、 Spring Securityの機能を利用します。

Spring Boot では、 <https://start.spring.io/> で "OAuth 2.0 Client" を選ぶことで追加される [`spring-boot-starter-oauth2-client`](https://github.com/spring-projects/spring-boot/blob/v2.3.1.RELEASE/spring-boot-project/spring-boot-starters/spring-boot-starter-oauth2-client/build.gradle) を用いることになります。

余談ですが(&結構何回も書いてきていますが)、 [`spring-security-auth2`](https://spring.io/projects/spring-security-oauth) と、今回利用する `spring-security-oauth2-client` は名前が似ているだけで別系統のライブラリです(そして前者はdeprecatedです)。

## spring-boot-starter-oauth2-client 依存関係追加

Spring Boot で auto-configuration を効かせてOAuth 2.0 Login/Clientを利用するには `spring-boot-starter-oauth2-client` を用います。

<div class="formalpara-title">

**[pom.xml](https://github.com/yukihane/hello-java/blob/0d49734/spring/oidc-example/pom.xml#L22-L25)**

</div>

        <dependency>
          <groupId>org.springframework.boot</groupId>
          <artifactId>spring-boot-starter-oauth2-client</artifactId>
        </dependency>

## security config 設定

[Spring Security OAuth 2.0 Client の auto-configuration]({{< relref"/blog/202007/20/spring-security-oauth-2.0-client" >}}) で記載した通り、 `OAuth2WebSecurityConfiguration` で次のような自動設定が為されていますので、 **特に何も行う必要はありません** 。

<div class="formalpara-title">

**(参考)[OAuth2WebSecurityConfiguration.java](https://github.com/spring-projects/spring-boot/blob/v2.3.2.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/security/oauth2/client/servlet/OAuth2WebSecurityConfiguration.java)**

</div>

    class OAuth2WebSecurityConfiguration {

        @Bean
        @ConditionalOnMissingBean
        OAuth2AuthorizedClientService authorizedClientService(ClientRegistrationRepository clientRegistrationRepository) {
            return new InMemoryOAuth2AuthorizedClientService(clientRegistrationRepository);
        }

        @Bean
        @ConditionalOnMissingBean
        OAuth2AuthorizedClientRepository authorizedClientRepository(OAuth2AuthorizedClientService authorizedClientService) {
            return new AuthenticatedPrincipalOAuth2AuthorizedClientRepository(authorizedClientService);
        }

        @Configuration(proxyBeanMethods = false)
        @ConditionalOnMissingBean(WebSecurityConfigurerAdapter.class)
        static class OAuth2WebSecurityConfigurerAdapter extends WebSecurityConfigurerAdapter {

            @Override
            protected void configure(HttpSecurity http) throws Exception {
                http.authorizeRequests((requests) -> requests.anyRequest().authenticated());
                http.oauth2Login(Customizer.withDefaults());
                http.oauth2Client();
            }

        }

    }

## プロパティ

<div class="formalpara-title">

**[application.yml](https://github.com/yukihane/hello-java/blob/0d49734ccc5758e05a2acc9d472f1acd43b0e6a3/spring/oidc-example/src/main/resources/application.yml)**

</div>

    spring:
      security:
        oauth2:
          client:
            provider:
              mykeycloak:
                # https://www.keycloak.org/docs/latest/securing_apps/index.html#endpoints-2
                # http://localhost:8081/auth/realms/myrealm/.well-known/openid-configuration
                issuer-uri: http://localhost:8081/auth/realms/myrealm
                # https://www.keycloak.org/docs/11.0/securing_apps/index.html
                user-name-attribute: preferred_username
            registration:
              myspring:
                authorization-grant-type: authorization_code
                # 上で定義しているprovider名
                provider: mykeycloak
                # keycloakに登録したidと対応するsecret
                # http://localhost:8081/auth/admin/master/console/#/realms/myrealm/clients
                client-id: myclient
                client-secret: e3b8886b-5b6e-49a7-91c2-c28caadf0a2b

- client-secret は、実際にはKeycloakの設定画面で表示されているもので差し替える必要があります。

- いくつかのサンプルと見ているとエンドポイント(`authorization-uri` など)をそれぞれ設定していましたが、 `issuer-uri` だけ設定すれば後はそこから自動設定できるようです。

- `user-name-attribute` は、[リファレンス](https://www.keycloak.org/docs/11.0/securing_apps/index.html)の "principal-attibute" からそれっぽいものを選びました。

## コントローラを作成してアクセスしてみる

[適当にコントローラを作成](https://github.com/yukihane/hello-java/blob/0d49734ccc5758e05a2acc9d472f1acd43b0e6a3/spring/oidc-example/src/main/java/com/example/oidcexample/HelloController.java)して <http://localhost:8080/> へアクセスしてみます。

Keycloakのログイン画面へリダイレクトされるので、事前に作成したユーザのid, password(myuser, myuser)を入力すれば、コントローラが結果を返してくれます。
