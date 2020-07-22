---
title: Spring Validator(でラップされたBean Validation)のメッセージをi18nしたときの覚え書き
date: 2019-03-26T20:04:13Z
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

# やりたかったこと

- BeanValidation のプロパティファイル [`ValidationMessages.properties`](https://docs.jboss.org/hibernate/validator/6.1/reference/en-US/html_single/#validator-customconstraints-errormessage) でなく、 Spring のメッセージプロパティに統合したい。
  - Spring のメッセージプロパティとは？
- `Accept-Language`ベースでメッセージを国際化したい。

# 調べた

## Spring のメッセージプロパティファイルはどこ？

これはキーワード "site:spring.io i18n message" でググるとすぐ見つかった。

- [27. Internationalization](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-internationalization.html)

`messages.properties` だ。

また、メッセージに関するプロパティは、このページで説明されている通り [MessageSourceProperties](https://github.com/spring-projects/spring-boot/blob/v2.1.3.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/context/MessageSourceProperties.java) で確認できる。
例えば [`cacheDuration`](https://github.com/spring-projects/spring-boot/blob/v2.1.3.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/context/MessageSourceProperties.java#L53) というフィールドがあるので `application.properties` ファイルには

    spring.messages.cache-duration

という名前で該当値を設定できる(フィールド名は camelCase だが、これに bind するプロパティ名は いわゆる[kebab-case が推奨されている](https://github.com/spring-projects/spring-boot/wiki/relaxed-binding-2.0#properties-files))。

[Externalized Configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-external-config.html#boot-features-external-config)という仕組みだと思うが、 **どうやって実現しているのかは分からん** 。 `MessageSourceProperties` に `ConfigurationProperties` アノテーションが付いているわけでもなし。

## デフォルト設定値を調べる

デバッガで追いかけた。 **これ本当ならどうやってリファレンス探せば見つかるんだ？**

[`ValidationAutoConfiguration#defaultValidator()`](https://github.com/spring-projects/spring-boot/blob/v2.1.3.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/validation/ValidationAutoConfiguration.java#L54) メソッドだ。

プロジェクト名(ディレクトリ名)から想像がつく通り、 [Auto-configuration](https://docs.spring.io/spring-boot/docs/current/reference/html/using-boot-auto-configuration.html)という仕組みだ。
明示的な設定を行っていない場合、フレームワーク側でよしなに設定を行ってくれる。

…が、その設定が気に入らない、というのが今回の問題のひとつの側面だ。

ここで登場するメソッド [`MessageInterpolatorFactory#getObject()`](https://github.com/spring-projects/spring-boot/blob/v2.1.3.RELEASE/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/validation/MessageInterpolatorFactory.java#L53)で、お節介にも BeanValidation 側の `MessageInterpolator` を取ってきている。
このため冒頭で記載したとおりデフォルトで `ValidationMessages.properties` が使われるようだ。
**マジかよ？ なんでそんなとこで日和ってんねん！**

# なおした

## 今回こうやった

まずはじめに、今回の問題の本質とは無関係だが、fallback 先ロケール設定を変更しておく。[デフォルトだとシステムロケール](https://github.com/spring-projects/spring-boot/blob/v2.1.3.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/context/MessageSourceProperties.java#L60)、つまり日本語環境なら `messages.properties` でなく `messages_ja.properties` にフォールバックしてしまうので直感に反する。
そこで `application.properties` ファイルに次を設定。

    spring.messages.fallback-to-system-locale=false

[Spring Tools 4 for Eclipse](https://spring.io/tools) なら補完も効くし説明もポップアップ表示される。嬉しい。なお、もしかしたら他の IDE でも同様の機能はあるのかもしらんが、使ったこと無いのでわからない。

さて本題。

上記で登場した auto-configuration であるところの `ValidationAutoConfiguration#defaultValidator()` を上書きして自分好みにしてしまえばいい。
[`@ConditionalOnMissingBean(Validator.class)`](https://github.com/spring-projects/spring-boot/blob/v2.1.3.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/validation/ValidationAutoConfiguration.java#L53) が付与されているので、自前で `Validator` を提供するメソッドを作ってしまえば良いということだ。
というわけでこんなクラスを作るぞ。

    import javax.validation.Validator;
    import org.springframework.beans.factory.annotation.Autowired;
    import org.springframework.context.MessageSource;
    import org.springframework.context.annotation.Bean;
    import org.springframework.context.annotation.Configuration;
    import org.springframework.validation.beanvalidation.LocalValidatorFactoryBean;

    @Configuration
    public class MyConfig {

        @Autowired
        private MessageSource messageSource;

        @Bean
        public Validator localValidatorFactoryBean() {
            final LocalValidatorFactoryBean factoryBean = new LocalValidatorFactoryBean();
            factoryBean.setValidationMessageSource(messageSource);
            return factoryBean;
        }
    }

`LocalValidatorFactoryBean` は `javax.validation.Validator` も `org.springframework.validation.Validator` も実装しているが、戻り値の型として使うべきは(`@ConditionalOnMissingBean`で指定している型である)前者だ。間違えて後者を使うと想定どおり動作しないやっかいなバグになるぞ。
ちなみに戻り値の型指定、 `javax.validation.Validator` の代わりに `LocalValidatorFactoryBean` でも動作した。
`instanceof`で評価しているのだと思うが確証はない。

さて `MessageSource` が登場しているがこれはなにか？ **わからん** 。
ググってたときにたまたま見つけた。
いやもちろん名前通りメッセージリソースなのだが、ここまで見てきたリファレンスでは一切登場していない。
[27. Internationalization](https://docs.spring.io/spring-boot/docs/current/reference/html/boot-features-internationalization.html)とか[`MessageSourceProperties`](https://github.com/spring-projects/spring-boot/blob/v2.1.3.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/context/MessageSourceProperties.java)の javadoc とかで触れられているべきでは！？

こいつはロケール考慮されているようで、デフォルトだと [`AcceptHeaderLocaleResolver`](https://github.com/spring-projects/spring-framework/blob/v5.1.5.RELEASE/spring-webmvc/src/main/java/org/springframework/web/servlet/i18n/AcceptHeaderLocaleResolver.java)を使って 冒頭に記載した希望通り`Accept-Language`を考慮してくれるようだがいい加減調べるのに疲れたので裏はとっていない。
多分[このへん](https://docs.spring.io/spring/docs/5.1.5.RELEASE/spring-framework-reference/web.html#mvc-localeresolver)読めば良いのだろう。

ところで この部分の調査の過程で [LocalValidatorFactoryBean #setValidationMessageSource](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/validation/beanvalidation/LocalValidatorFactoryBean.html#setValidationMessageSource-org.springframework.context.MessageSource-)に解答っぽい記述があることに気づいた。
が、 **この文章見て具体的に何やればいいかわからんのだが？** そもそも **このメソッドの存在をどうやったら見つけられるんだ？**

## やっかいなことに

Spring(Boot)のやりかたは上に書いた方法だけではないようだ。次のエントリで同じ目的を達成するための方法が説明されている。

- [Spring Boot でバリデーションエラーメッセージを日本語にしてみる - Qiita](https://qiita.com/yhinoz/items/5dd8b58fa555dfb0ca82)

`WebMvcConfigurerAdapter`(注: 現行バージョンでは代わりに `WebMvcConfigurer`)**って何やねんどこから出てきた？**

**どっちで設定すべきやねーん！**

# 追記

## ロケールについて

上で端折った i18n について調べ直した。**デバッガのステップ実行で**。

[`LocaleContextHolder#getLocale()`](https://github.com/spring-projects/spring-framework/blob/v5.1.5.RELEASE/spring-context/src/main/java/org/springframework/context/i18n/LocaleContextHolder.java#L204) でロケールを取得している。

こいつを使っているのが `MessageInterpolator`(を実装した実体 [`LocaleContextMessageInterpolator` の `interpolate` メソッド](https://github.com/spring-projects/spring-framework/blob/v5.1.5.RELEASE/spring-context/src/main/java/org/springframework/validation/beanvalidation/LocaleContextMessageInterpolator.java#L50) だ。

ServletFilter であるところの [`RequestContextFilter`](https://github.com/spring-projects/spring-framework/blob/v5.1.5.RELEASE/spring-web/src/main/java/org/springframework/web/filter/RequestContextFilter.java#L111) で `HttpServletRequest#getLocale()` をロケールとして設定している。

したがって、　*HTTP リクエストコンテキストでは* (補足: なんか Qiita の他の人の記事とかではコンテキストを無視して説明している文章が多いぞ。別に validation は RequestScope だけで行うわけではなかろう)、ロケールは `HttpServletRequest#getLocale()` の値となるし、それ以外のコンテキストでもそのコンテキストに応じたロケールを設定してくれていると期待できることが分かった。

## WebMvcConfigurer

ここにあった！

- [1.10.4. Validation - Spring Framework Documentation > Web Servlet](https://docs.spring.io/spring/docs/5.1.5.RELEASE/spring-framework-reference/web.html#mvc-config-validation)

**何が Spring Boot で何が Spring なのか全然分からん**。

いや、よく考えると auto-configuration はあくまで付加的な仕組みであって、そこから行うべきことを考えるのは筋が違うな。
ということは `WebMvcConfigurer` で設定するのが本来の姿なのだろうか。
しかし **Validation の、国際化の仕組みの設定が `WebMvcConfigurer` という名前のものに備わっているというのはどうやって思い至れば良いんだろう？**

もしかしたらこういう手順か？

1. Spring Boot リファレンスの該当しそうな章 [37.Validation](https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#boot-features-validation) を見る。
2. `@Validated` という validation 専用っぽいアノテーションが使われているぞ。
3. [javadoc の記述](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/validation/annotation/Validated.html)を読むと Spring MVC という単語が出てるので、validation の仕組みは Spring MVC の機能のひとつなんだ？
4. [Spring Framework ドキュメントのリスト](https://docs.spring.io/spring/docs/5.1.5.RELEASE/spring-framework-reference/)を見ると Spring MVC は[Web Servlet](https://docs.spring.io/spring/docs/5.1.5.RELEASE/spring-framework-reference/web.html#spring-web)に含まれているようだ？ Servlet と validation って何か関係があるのか？よく分からんが見てみよう。
5. 該当する節 [1.10.4. Validation](https://docs.spring.io/spring/docs/5.1.5.RELEASE/spring-framework-reference/web.html#mvc-config-validation)が見つかった！なるほど 設定は `WebMvcConfigurer` で行うのか！
6. 関係しそうな名前 [`getValidator()`ってメソッド](https://docs.spring.io/spring-framework/docs/current/javadoc-api/org/springframework/web/servlet/config/annotation/WebMvcConfigurer.html#getValidator--)があるぞ！

**マジでこんなこと考えるの？無理ゲーじゃない？**
あとこれから更に `LocalValidatorFactoryBean` インスタンスを生成して返すってのに気付くのにもまた一山超える必要がありそうだし。

# まとめ

- Spring 全然わからん。
- Qiita のスタイル、バックスラッシュでくくるとハイパーリンク貼ってるのかどうなのかわからんからいまいち。
- Qiita 等で Spring( Boot)解説エントリを書いている人に向けて: 根拠となる公式リファレンス/ソースコードへの参照も含めてほしい。あなたの書いたその実装方法が妥当なのか入門者は確認できない。
