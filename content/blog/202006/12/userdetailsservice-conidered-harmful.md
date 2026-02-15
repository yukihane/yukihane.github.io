---
title: "UserDetailsServiceは誤解されている"
date: 2020-06-12T09:37:26Z
draft: false
tags:
  - spring-boot
  - spring-security
---

サンプルコード等だけを見ていると `UserDetailsService` を利用することがSpring Securityの唯一の認証処理実現方法だと誤解しがちですが、 `UserDetailsService` はむしろユーティリティライブラリくらいの立ち位置で、別に利用しなくても実現可能です。

そして、役割も誤解されがちで、これは単に認証に必要な情報を"名前をキーにして"取得するDAOです。 認証を行うクラスではありませんし、そもそも名前をキーにしないようなシステムでは適合しません。 しかしSpring Boot上でデフォルト設定で使っていると認証するためのクラスが一切出てこないので誤解してしまう、というわけです。

公式リファレンスでは次のようにあります:

> `UserDetailsService` is a DAO interface for loading data that is specific to a user account. It has no other function other to load that data for use by other components within the framework. It is not responsible for authenticating the user. Authenticating a user with a username/password combination is most commonly performed by the `DaoAuthenticationProvider`, which is injected with a `UserDetailsService` to allow it to load the password (and other data) for a user in order to compare it with the submitted value. Note that if you are using LDAP, this approach may not work.
>
> If you want to customize the authentication process then you should implement AuthenticationProvider yourself.
>
> —  [What is a UserDetailsService and do I need one?](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#appendix-faq-what-is-userdetailservice)

その他、次のQ&Aも参照してみてください:

- [I need to login in with more information than just the username.](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#appendix-faq-extra-login-fields)

- [How do I access the user’s IP Address (or other web-request data) in a UserDetailsService?](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#appendix-faq-request-details-in-user-service)

- [How do I access the HttpSession from a UserDetailsService?](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#appendix-faq-access-session-from-user-service)

- [How do I access the user’s password in a UserDetailsService?](https://docs.spring.io/spring-security/site/docs/5.3.3.RELEASE/reference/html5/#appendix-faq-password-in-user-service)

要約すると、それらは `UserDetailsService` の役割ではなくて、 認証フィルター だったり authentication-provider だったりが為すべきことである、というのが理解されていない、というような話です。

このような誤解を避けるためにも、少なくともはじめはユーティリティクラスであるところの `UserDetailsService` を利用しない、シンプルなコードサンプルを参照して理解したほうが良いのではないか、と考えるに至りました。

が、そういったサンプルがどこにあるか思い浮かばなかったので(オフィシャルのサンプルも常に `UserDetailsService` を使っている)、自分で作りました。

- <https://github.com/yukihane/hello-java/tree/master/spring/springboot-auth-example-202006>

関連リンク:

- [UserDetailsServiceのloadUserByUsernameの存在意義がよくわからないです](https://ja.stackoverflow.com/q/67596/2808)
