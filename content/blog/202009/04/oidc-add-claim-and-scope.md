---
title: "claimとscopeを追加して取得してみる"
date: 2020-09-03T23:24:39Z
draft: false
tags:
  - oidc
  - spring-boot
  - spring-security
---

# はじめに

Keycloak上で新しいclaimと、それを取得できる新しいscopeを定義し、Spring Securityを使って参照してみます。

[KeycloakをIdPにしてSpring Security OAuth 2.0 Login/Client を試してみる]({{< relref"/blog/202007/21/hello-oidc-with-keycloak" >}}) で作成したコードをベースにしています。

今回のコードはこちらです:

- <https://github.com/yukihane/hello-java/tree/master/spring/oidc/oidc-add-scope>

# Keycloak上の設定手順

## ユーザ属性(claim)追加

[KeycloakをIdPにしてSpring Security OAuth 2.0 Login/Client を試してみる]({{< relref"/blog/202007/21/hello-oidc-with-keycloak" >}}) のときと同様に、管理者でログインします。

[Users](http://localhost:8081/auth/admin/master/console/#/realms/myrealm/users) 設定画面から以前作成したユーザ `myuser` の編集を行います。

`myuser` の編集画面で **Attrributes** タブを開き、次のレコードを作成し、保存します。

|       |            |
|-------|------------|
| Key   | fav-number |
| Value | 8          |

## scope追加

[Client Scopes](http://localhost:8081/auth/admin/master/console/#/realms/myrealm/client-scopes)を選択し、表の右上 **Create** ボタンを押します。

次の情報を入力し、 **Save** します。

|      |           |
|------|-----------|
| Name | extrainfo |

つづいて **Mappers** タブを開きます。 **Create** ボタンを押し、次の情報を入力します。

|                     |                       |
|---------------------|-----------------------|
| Name                | extrainfo mapper      |
| Mapper Type         | User Attribute        |
| User Attribute      | fav-number            |
| Token Claim Name    | fav-number            |
| Claim JSON Type     | int                   |
| Add to ID token     | OFF                   |
| Add to access token | OFF                   |
| Add to usrinfo      | ON (デフォルトのまま) |

## クライアントから取得できるようにする

[Clients](http://localhost:8081/auth/admin/master/console/#/realms/myrealm/clients) 画面で `myclient` を選択し、 **Client Scopes** タブを開きます。

**Optional Client Scopes** で、 `extrainfo` を **Assined Optional Client Scopes** に移します。

# Spring Bootの設定

## scope追加

`application.yml` で設定している registration に、今回追加で取得するscope `extrainfo` 追加します。

<div class="formalpara-title">

**application.yml**

</div>

``` yml
        registration:
          myspring:
            scope:
            - openid
            - extrainfo
```

## 取得した情報を表示してみる

コントローラで情報を取得してみます。

``` java
    @GetMapping
    public String index() {
        final Authentication authn = SecurityContextHolder.getContext().getAuthentication();
        log.info("Authentication: {}", authn);

        final OAuth2User user = ((OAuth2AuthenticationToken) authn).getPrincipal();
        final Object favNum = user.getAttribute("fav-number");
        return "Hello " + authn.getName() + "! Your fav is " + favNum + ".";
    }
```
