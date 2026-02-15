---
title: "WindowsでGradleが扱うリソースのファイルエンコーディング設定"
date: 2020-09-12T12:26:22Z
draft: false
tags:
  - gradle
---

# 問題

Spring Bootの自動テストで [`data.sql`](https://docs.spring.io/spring-boot/docs/2.3.3.RELEASE/reference/htmlsingle/#howto-initialize-a-database-using-spring-jdbc) を作成しているのですが、 `gradle check` でテストを実行すると、失敗してしまう。

原因を調べたのですが、どうも日本語のカラムを比較しているところで失敗しているようで、出力を見る感じ `data.sql` のファイルエンコーディングが `MS932` で扱われてしまっているようでした。

この解決策としては、

``` bash
gradle -Dfile.encoding=UTF-8 check
```

とすれば良いことに気づきました。

ただ、毎回この `-Dfile.encoding=UTF-8` を打ちたくないので、デフォルトオプションに指定したく、色々と試行錯誤した結果、次の設定が等価のようです。

# 解決手順

自分はGradleをSDKMAN!でインストールしてGit Bashでのみ利用しています。解決の確認もこの環境で行っています。

まず、環境変数 `GRADLE_USER_HOME` を設定します [^1]。

``` bash
echo 'export GRADLE_USER_HOME=$HOME/.gradle' >> ~/.bashrc
```

続いて、 `gradle.properties` でファイルエンコーディングを設定します。

    mkdir -p ~/.gradle
    echo 'file.encoding=UTF-8' >> ~/.gradle/gradle.properties

これでOKでした。

他の方法、 `GRADLE_OPTS` 環境変数に設定するなど次のページに書かれている方法ではいずれも目的を達成できませんでした。

- [Show UTF-8 text properly in Gradle - Stack Overflow](https://stackoverflow.com/q/21267234/4506703)

UTF-8として認識されないまま、あるいは、リソースファイルの読み取りだけでなくGradleコンソール出力もUTF-8になってしまう(結果、出力の日本語が化けてしまう)という結果となりました。

[^1]: [リファレンス](https://docs.gradle.org/current/userguide/build_environment.html#sec:gradle_environment_variables)によると未設定の場合は `$USER_HOME/.gradle` になる、とありましたが、今回この環境変数を明示的に設定しないと有効になりませんでした
