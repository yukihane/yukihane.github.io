---
title: "Swagger"
date: 2020-07-24T01:42:56Z
draft: false
---

WildFlyにはRestEasyが組み込まれているのでそれを前提に。

- [公式Wiki](https://github.com/swagger-api/swagger-core/wiki/Swagger-Core-JAX-RS-Project-Setup-1.5.X)

# Swagger セットアップ

## pom.xml

\`swagger-jaxrs\`を依存関係に追加する。

    <dependency>
        <groupId>io.swagger</groupId>
        <artifactId>swagger-jaxrs</artifactId>
        <version>1.5.13</version>
    </dependency>

参考: [Adding the dependencies to your application](https://github.com/swagger-api/swagger-core/wiki/Swagger-Core-RESTEasy-2.X-Project-Setup-1.5#adding-the-dependencies-to-your-application) Jersyの場合は専用の別ライブラリがある。

## web.xml

自動でJAX-RSのリソースプロバイダをスキャンするために、\`web.xml\`に次を追記する。

``` xml
  <context-param>
    <param-name>resteasy.scan</param-name>
    <param-value>true</param-value>
  </context-param>
```

参考: [Hooking up Swagger-Core in your Application - Automatic scanning and registration](https://github.com/swagger-api/swagger-core/wiki/Swagger-Core-RESTEasy-2.X-Project-Setup-1.5#automatic-scanning-and-registration) 上記のほか、手動追加など他の選択肢も有る。

## コード

\`Application\`継承クラスのコンストラクタに次を記載する。

``` java
        BeanConfig beanConfig = new BeanConfig();
        beanConfig.setVersion("0.1.0");
        beanConfig.setSchemes(new String[] { "http" });
        beanConfig.setHost("localhost:8080");
        beanConfig.setBasePath("/hello-wildfly-rest/rest");
        beanConfig.setResourcePackage("jp.himeji_cs.hello_wildfly_rest.rest");
        beanConfig.setScan(true);
        beanConfig.setPrettyPrint(true);
```

参考: [Configure and Initialize Swagger - Using Swagger’s BeanConfig - Using the Application class](https://github.com/swagger-api/swagger-core/wiki/Swagger-Core-RESTEasy-2.X-Project-Setup-1.5#using-the-application-class) これ以外の設定方法も記載が有る。

# Swagger-UI セットアップ

1.  WildFlyのホームディレクトリ(以下、`$JBOSS_HOME`)直下に\`swagger\`というディレクトリを作成し、https://github.com/swagger-api/swagger-ui\[swagger-ui\]の\`dist\`以下をコピーする。

\# \`\$JBOSS_HOME/standalone/configuration/standalone.xml\`を開き、undertow設定箇所で上記のディレクトリを公開する設定を行う。

            <subsystem xmlns="urn:jboss:domain:undertow:3.1">
                <server name="default-server">
                    <host name="default-host" alias="localhost">
                        <location name="/" handler="welcome-content"/>
                        <location name="/swagger" handler="swagger"/>
                    </host>
                </server>
                <handlers>
                    <file name="welcome-content" path="${jboss.home.dir}/welcome-content"/>
                    <file name="swagger" path="${jboss.home.dir}/swagger"/>
                </handlers>

(上記の、 **swagger** という文字列が現れている行(2行)を追加。)

これで、 <http://localhost:8080/swagger/> へアクセスするとSwagger-UIが利用できる。

# アノテーション

<https://github.com/swagger-api/swagger-core/wiki/annotations>
