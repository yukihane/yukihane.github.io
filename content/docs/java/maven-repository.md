---
title: "Maven Repository"
date: 2020-07-23T18:36:13Z
draft: false
---

通常は [リポジトリマネージャ](https://maven.apache.org/repository-management.html)(Sonatypeの [Nexus](https://www.sonatype.com/download-oss-sonatype)など)を使うのが便利で良いが、レンタルサーバではJavaを動作させられなかったりするため、Apache httpdとscpで実現する方式を記載。

参考: <http://maven.apache.org/plugins/maven-deploy-plugin/examples/deploy-ssh-external.html>

1.  [`$M2_HOME/conf/settings.xml`](https://maven.apache.org/settings.html)を\`~/.m2/\`ディレクトリに無ければコピーする。

\# \`servers\`タグの下に\`server\`タグを作成し、上記ページのようにサーバ情報を記述する。今回記述したのは\`id\`と\`username\`のみでよかった。(公開鍵認証)

``` xml
  <servers>
    <server>
      <id>default</id>
      <username>myname</username>
    </server>
  </servers>
```

1.  deployするモジュールの\`pom.xml\`を編集する。これも上記ページに記載がある。\`distributionManagement\`にデプロイ先のリポジトリ情報を書き、\`extension\`で\`wagon-ssh-external\`を記述。

2.  \`mvn deploy\`コマンドでデプロイできる。
