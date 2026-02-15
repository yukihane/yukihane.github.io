---
title: "gradle bootRun でプロファイルを指定するには？"
date: 2020-08-29T23:16:09Z
draft: false
tags:
  - spring-boot
  - gradle
---

`gradle bootRun` を実行する際にアクティブ化するプロファイルの指定を行いたかったのですが、ぱっと思いつかなかったのでメモ。

まず、

    gradle bootRun -Dprofiles.active=myproile

はうまくいきません。\`profiles.active\`システムプロパティは (アプリケーションでなく) Gradle に渡されるためです。

`BootRun` は `JavaExec` を継承しているので同じように

ので、 `--args` を利用して、

    gradle bootRun --args='--spring.profiles.active=myprofile'

とします。

あるいは、環境変数を用いて

    SPRING_PROFILES_ACTIVE=myprofile gradle bootRun

で適用できます。

# 参考

- <https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#howto-set-active-spring-profiles>

- <https://docs.gradle.org/current/userguide/application_plugin.html>

- <https://github.com/spring-projects/spring-boot/issues/1176>
