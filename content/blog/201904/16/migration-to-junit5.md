---
title: Testing the Web Layer のコードを JUnit Jupiter にマイグレーションしてみる
date: 2019-04-16T20:06:33Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [spring-boot]
# images: []
# videos: []
# audio: []
draft: false
---

# 概要

(追記: ここで試したのは`2.1.4.RELEASE`時点のもの。`2.2.0.M3`以降では [#14736](https://github.com/spring-projects/spring-boot/issues/14736)の通り JUnit5 がデフォルトになっている模様。)

spring-boot-starter-test の JUnit5 対応はこちらの issue:

- [Investigate JUnit 5 starter upgrade #14736](https://github.com/spring-projects/spring-boot/issues/14736)

現時点でいわゆる out-of-the-box では使えない。手を入れる必要がある。

そこで試しに[Testing the Web Layer](https://spring.io/guides/gs/testing-web/) のサンプルコードを JUnit4 から JUnit Jupiter に変更してみた(Maven 用の `pom.xml` のみ)。

- https://github.com/yukihane/gs-testing-web/tree/feature/junit-jupiter/complete

# 参考

- [Testing the Web Layer](https://spring.io/guides/gs/testing-web/) - Spring project's guides
- [SpringExtension for JUnit Jupiter](https://docs.spring.io/spring/docs/current/spring-framework-reference/testing.html#testcontext-junit-jupiter-extension) - Spring Famework Testing
  - [Testing Spring Boot Applications](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-testing.html#boot-features-testing-spring-boot-applications) - Spring Boot reference
- [Provide dedicated Spring Boot starter for JUnit 5 #14716](https://github.com/spring-projects/spring-boot/issues/14716) - Spring Boot Issues
- [Configuring Test Engines](https://junit.org/junit5/docs/current/user-guide/#running-tests-build-maven-engines-configure) - JUnit 5 official guide

# 変更手順

詳しくは冒頭に記載した Git リポジトリ参照のこと。

1. `spring-boot-starter-test` が `junit`(JUnit4)に依存しているので除外する。 ([差分リンク](https://github.com/yukihane/gs-testing-web/commit/d77d7087c2e64f5233f525c35cab1b0251656cde#diff-fbdb7c22a3fe16b8cab5b3cb905bd96a))
2. JUnit5 関連の依存関係を追加設定する。 `junit-jupiter-engine`, `junit-jupiter-api` ([差分リンク](https://github.com/yukihane/gs-testing-web/commit/1fb1b1e402198d2703d4b8e4f1721421aca5d32b#diff-fbdb7c22a3fe16b8cab5b3cb905bd96a))
3. ~~テストクラスに付与されているアノテーション `@RunWith(SpringRunner.class)` を `@ExtendWith(SpringExtension.class)` に置換する。~~ ([差分リンク](https://github.com/yukihane/gs-testing-web/commit/4e347ee8b9fb3ce4e1569ff88400925d6b3386b5#diff-d9a22d7a8178d5b42a8750123cbfe5b1))
4. `@RunWith(SpringRunner.class)` を単に削除する。
   - `@ExtendWith(SpringExtension.class)` は `@SpringBootTest` や `@WebMvcTest` に含まれるため明示的な設定は不要。
5. JUnit4 の `import` を JUnit Jupiter のものに置換する。(差分は上のものに含まれる)

# 備考

## Hamcrest vs AssertJ

- [Spring Boot Starter adds both AssertJ and Hamcrest assertion libraries #15789](https://github.com/spring-projects/spring-boot/issues/15789)

からは、 Spring Boot では AssertJ を使うことが推奨されているように感じる。ただし、

- [Support AssertJ variant in MockMvc [SPR-16637] #21178](https://github.com/spring-projects/spring-framework/issues/21178)
  - [Consider AssertJ variant of MockMvc #5729](https://github.com/spring-projects/spring-boot/issues/5729)

にあるとおり、 現時点では MockMvc が Hamcrest に依存しているので完全には Hamcrest を除外できない。

## `@ExtendWith(SpringExtension.class)`

[Spring Boot + JUnit5 + Kotlin でテストを書く - Qiita](https://qiita.com/gumimin/items/f15eaede3e0e5b7a11a5) などでは本アノテーションを付与する旨記載されているが、Spring Boot のテストに用いるアノテーションには既に設定されているため、自分(テストコード記述者)が明示的に設定する必要は(もはや)ない。

[46.3 Testing Spring Boot Applications](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-testing.html#boot-features-testing-spring-boot-applications) - Spring Boot リファレンス:

> If you are using JUnit 5, there’s no need to add the equivalent @ExtendWith(SpringExtension.class) as @SpringBootTest and the other @…Test annotations are already annotated with it.

及び関連する issue:

- [Annotate @…Test annotations with @ExtendWith(SpringExtension.class) #13739](https://github.com/spring-projects/spring-boot/issues/13739)

## コンポーネントスキャン

[SpringBoot と JUnit5 で MockMvc を使うには - Qiita](https://qiita.com/thankkingdom/items/f1b600a3b27ee858c448#%E3%83%86%E3%82%B9%E3%83%88%E3%82%B3%E3%83%B3%E3%83%95%E3%82%A3%E3%82%B0%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%81%AE%E4%BD%9C%E6%88%90) では

> ③ テストコンフィグファイルの作成
> これが重要でした。個々のテストクラスで、コンポーネントスキャンしてクラスを参照できるようにしてあげます。

と書かれているが、今回無くても動作した。
