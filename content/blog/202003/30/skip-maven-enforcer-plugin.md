---
title: "Maven Enforcer Pluginの実行をスキップする"
date: 2020-03-30T05:37:45Z
draft: false
tags:
  - java
  - maven
---

とあるMavenプロジェクトを `mvn clean install` しようとしたところ、次のエラーになり正常終了しませんでした。

    [WARNING] Rule 0: org.apache.maven.plugins.enforcer.BannedRepositories failed with message:
    Current maven session contains banned repository urls, please double check your pom or settings.xml:
    central - http://my.internal.repo/xxx
    snapshots - http://my.internal.repo/yyy

原因は `mvn help:effective-pom` 実行結果を見て理解したのですが、どうも `http://` だとエラーになるようで、 `https://` を使え、ということのようです。 公式リファレンスで該当するのはこれでしょうか:

- <https://maven.apache.org/enforcer/enforcer-rules/bannedRepositories.html>

そしてスキップするための説明はこちら:

- <https://maven.apache.org/enforcer/maven-enforcer-plugin/enforce-mojo.html#skip>

`enforcer.skip` プロパティを `true` にすれば良いようです。

    mvn clean install -Denforcer.skip=true
