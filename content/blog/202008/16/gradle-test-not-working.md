---
title: "Gradleでintegration testを作成するも実行できない(JUnit5)"
date: 2020-08-16T14:20:16Z
draft: false
tags:
  - gradle
---

Gradle で integration-test 用にテストディレクトリを分けようとして [リファレンス](https://docs.gradle.org/current/userguide/java_testing.html#sec:configuring_java_integration_tests) を参考に `build.gradle` を編集しました。

しかし、コンパイル対象には入っているようですがこのテストが実行されている気配がありません。

仕方なくデバッグログを出力してみたところ、次のようなログが出力されているのに気づきました:

    2020-08-16T23:10:21.737+0900 [DEBUG] [TestEventLogger] Gradle Test Run :integrationTest STARTED
    2020-08-16T23:10:21.746+0900 [DEBUG] [org.gradle.api.internal.tasks.testing.detection.AbstractTestFrameworkDetector] test-class-scan : failed to scan parent class java/lang/Object, could not find the class file
    2020-08-16T23:10:21.747+0900 [DEBUG] [TestEventLogger]-
    2020-08-16T23:10:21.747+0900 [DEBUG] [TestEventLogger] Gradle Test Run :integrationTest PASSED

"failed to scan parent class java/lang/Object, could not find the class file" でググったところ、次のエントリがヒットしました:

- [Gradle integration test building but not running - Stack Overflow](https://stackoverflow.com/a/51382241/4506703)

というわけで、JUnit5を利用する場合、 [冒頭でリンクしたリファレンスの記述](https://docs.gradle.org/current/userguide/java_testing.html#sec:configuring_java_integration_tests)だけでは不十分で、実際には `useJUnitPlatform()` も必要で、次のように記述する必要がありました:

<div class="formalpara-title">

**build.groovy**

</div>

    task integrationTest(type: Test) {
        useJUnitPlatform() // これを追加！
        description = 'Runs integration tests.'
        group = 'verification'

        testClassesDirs = sourceSets.intTest.output.classesDirs
        classpath = sourceSets.intTest.runtimeClasspath
        shouldRunAfter test
    }
