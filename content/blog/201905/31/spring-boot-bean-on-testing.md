---
title: Spring Boot 2.1 でテスト時 @Bean を挿げ替えたかった
date: 2019-05-31T20:14:41Z
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

# 動機

ユニットテスト実行時に [java.time.Clock](https://docs.oracle.com/javase/jp/11/docs/api/java.base/java/time/Clock.html) を特定の時間に固定して再現性のあるテスト(現在の時刻に依存しないテスト)を作成したかった。

# 考え方/方針

`@Configuration` で `@Bean` を定義して `Clock` をインジェクションできるようにし、実装ではそれを用いる。

テストコードでは [@TestConfiguration](https://docs.spring.io/spring-boot/docs/2.1.5.RELEASE/reference/html/boot-features-testing.html#boot-features-testing-spring-boot-applications-detecting-config) で上で定義した `@Bean` をオーバライドしてテスト用`Clock`を供給する。

少し迷う点としては、現時点(バージョン 2.1.5)のリファレンスには `@TestConfiguration` をテストクラスの static inner クラスとして作っておけば優先的に有効化されるように書かれているが、実際はエラーになる。

[`2.1.0` よりデフォルトでは bean オーバーライドが許可されなくなった](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.1-Release-Notes#bean-overriding)ためだろう。

対応としては、

- プロパティ`spring.main.allow-bean-definition-overriding`を`true`に設定することでオーバライドを許可する
- テストの bean 供給メソッドに`@Primary`を付与し優先的に用いるようにする
  - この際メソッド名は production の供給メソッドと被らないようにしなければならないようだった

が考えられたが、今回は後者を採用した。

# サンプルコード

`src/main/java/../ClockConfig.java`:

    @Configuration
    public class ClockConfig {
        @Bean
        public Clock clock() {
            return Clock.systemDefaultZone();
        }
    }

`src/test/java/../ClockTest.java`:

    @SpringBootTest(webEnvironment = WebEnvironment.NONE)
    public class ClockTest {

        private static final ZoneId TOKYO = ZoneId.of("Asia/Tokyo");

        @TestConfiguration
        static class TestDateTimeConfig {
            @Bean
            @Primary
            public Clock clockMock() {
                final LocalDate date = LocalDate.of(2010, 8, 15);
                final Instant fixedInstant = date.atStartOfDay(TOKYO).toInstant();
                final Clock clock = Clock.fixed(fixedInstant, TOKYO);

                return clock;
            }
        }

        @Autowired
        private Clock clock;

        @Test
        public void stopTheWorld(){
            final ZonedDateTime now = Instant.now(clock).atZone(TOKYO);
            assertThat(now.getYear()).isEqualTo(2010);
        }
    }

# 参考リンク

- [46.3.2 Detecting Test Configuration - Spring Boot リファレンス](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-testing.html#boot-features-testing-spring-boot-applications-detecting-config)
- [Add Annotation for bean overriding [SPR-17519] #22051](https://github.com/spring-projects/spring-framework/issues/22051)
