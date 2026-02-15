---
title: "JAAS"
date: 2020-07-24T01:16:09Z
draft: false
---

<https://github.com/yukihane/hello-rest-environment> の hello-wildfly-rest にサンプルコードを置いている。

# WildFly設定 standalone/configuration/standalone.xml

- [Security subsystem configuration - WildFly 10 - Project Documentation Editor](https://docs.jboss.org/author/display/WFLY10/Security+subsystem+configuration)

  - [Authentication Modules - WildFly 10 - Project Documentation Editor](https://docs.jboss.org/author/display/WFLY10/Authentication+Modules)

- [Wildfly 8でJAAS - hatenob](http://nobrooklyn.hateblo.jp/entry/2015/02/23/230640)

`standalone/configuration/standalone.xml` の security サブシステム設定部分にsecurity-domainを追加:

``` xml
        <subsystem xmlns="urn:jboss:domain:security:1.2">
            <security-domains>
                <security-domain name="own-domain" cache-type="default">
                    <authentication>
                        <login-module code="Database" flag="required">
                          <module-option name="dsJndiName" value="java:jboss/datasources/hello-wildfly-restDS"/>
                          <module-option name="principalsQuery" value="select email from Member where name = ?"/>
                          <module-option name="rolesQuery" value="select 'user', 'Roles' from Member where name = ?"/>
                        </login-module>
                    </authentication>
                </security-domain>
(後略)
```

login-module の code や module-option については前述のリンク先に説明がある。

\`rolesQuery\`についてはクエリの1項目目がロール、2項目目がロールグループだそうだが、2項目目はhttps://docs.jboss.org/author/display/WFLY10/Authentication+Modules\[\`Roles\`固定でないといけない\]らしい。

また、ここでは認証(authentication)だけ行いたく、認可(authorization)はアプリケーション独自で行う想定なので、1項目目も\`user\`固定としている。

# WARで利用する

## jboss-web.xml

`WEB-INF` ディレクトリ以下に `jboss-web.xml` ファイルを作成し、次の内容を記載する:

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<jboss-web>
  <security-domain>own-domain</security-domain>
</jboss-web>
```

## web.xml

``` xml
<web-app>
(前略)
  <security-constraint>
    <display-name>None Authorized Resource</display-name>
    <web-resource-collection>
      <web-resource-name>non-protected-page</web-resource-name>
      <description>認証不要リソース</description>
      <url-pattern>/rest/ejb/*</url-pattern>
      <url-pattern>/rest/login/*</url-pattern>
      <url-pattern>/rest/swagger.json</url-pattern>
    </web-resource-collection>
  </security-constraint>
  <security-constraint>
    <display-name>Authorized Resource</display-name>
    <web-resource-collection>
      <web-resource-name>protected-page</web-resource-name>
      <description>ログイン認証後に表示されるリソース</description>
      <url-pattern>/*</url-pattern>
    </web-resource-collection>
    <auth-constraint>
      <description>認証完了したユーザが参照できるリソース</description>
      <role-name>user</role-name>
    </auth-constraint>
  </security-constraint>
  <login-config>
    <auth-method>FORM</auth-method>
    <realm-name>own-domain</realm-name>
    <form-login-config>
      <form-login-page>/rest/login/</form-login-page>
      <form-error-page>/rest/login/</form-error-page>
    </form-login-config>
  </login-config>
  <security-role>
    <role-name>user</role-name>
  </security-role>
</web-app>
```

# EJB で利用する

## jboss-ejb3.xml

``` xml
<?xml version="1.0"?>
<jboss:ejb-jar xmlns:jboss="http://www.jboss.com/xml/ns/javaee" xmlns="http://java.sun.com/xml/ns/javaee"
  xmlns:s="urn:security" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://www.jboss.com/xml/ns/javaee http://www.jboss.org/j2ee/schema/jboss-ejb3-2_0.xsd
                     http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/ejb-jar_3_1.xsd"
  version="3.1" impl-version="2.0">

  <assembly-descriptor>
    <s:security>
      <ejb-name>*</ejb-name>
      <s:security-domain>own-domain</s:security-domain>
    </s:security>
    <method-permission>
      <unchecked />
      <method>
        <ejb-name>MyNonSecureEjb</ejb-name>
        <method-name>getText</method-name>
      </method>
    </method-permission>
    <method-permission>
      <unchecked />
      <method>
        <ejb-name>MemberRegistration</ejb-name>
        <method-name>register</method-name>
      </method>
    </method-permission>
    <method-permission>
      <role-name>user</role-name>
      <method>
        <ejb-name>*</ejb-name>
        <method-name>*</method-name>
      </method>
    </method-permission>
  </assembly-descriptor>
</jboss:ejb-jar>
```

認証不要にしたいものは `ejb-name` , `method-name` を `*` にせず明示した上で `<unchecked />` とする必要があった。 例えば `method-name` を `*` にしてしまうと想定通り動かない( `user` ロール権限が必要になった)。
