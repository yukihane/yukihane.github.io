---
title: Tomcat上でJSF実現
date: 2018-07-07T21:47:59Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [jsf, java, tomcat]
# images: []
# videos: []
# audio: []
draft: false
---

非 JavaEE なサーブレットコンテナ上で JSF を実行するように変更する手順。

# TL;DR

- Mojarra を依存関係に含める
- JSF リソースを `javax.faces.webapp.FacesServlet` にマップするよう `web.xml` で設定する

# 実装例

https://github.com/yukihane/hello-jsf/tree/feature/server/tomcat

`feature/server/tomcat` ブランチと `feature/server/javaee` ブランチで diff を取れば、 JavaEE アプリケーションサーバ向け設定との差異がわかります。
(ちなみに `master`ブランチや `README.md` の説明は別の内容向けなので気にしないで下さい)

# 手順

通常の(JSF 未対応の)`war`に対し、Mojarra 依存関係を追加します。
`pom.xml`

    <dependency>
      <groupId>org.glassfish</groupId>
      <artifactId>javax.faces</artifactId>
      <version>2.2.4</version>
    </dependency>

(余談ですが、初見でこの`groupId`, `artifactId`からこれが Mojarra 本体だとわかるだろうか、いやわからない。)

次に`web.xml`で(今回の例では)拡張子`xhtml`ファイルへのアクセスを MojarraJSF プロセスエントリポイントへマップします。

`src/main/webapp/WEB-INF/web.xml`:

    <servlet>
      <servlet-name>faces</servlet-name>
      <servlet-class>javax.faces.webapp.FacesServlet</servlet-class>
      <load-on-startup>1</load-on-startup>
    </servlet>

    <servlet-mapping>
      <servlet-name>faces</servlet-name>
      <url-pattern>*.xhtml</url-pattern>
    </servlet-mapping>

以上です。
