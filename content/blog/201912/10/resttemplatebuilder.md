---
title: RestTemplateBuilderに関する覚書
date: 2019-12-10T20:41:15Z
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

# [RestTemplateBuilder](https://docs.spring.io/spring-boot/docs/current/api/org/springframework/boot/web/client/RestTemplateBuilder.html)

- [RestTemplate](https://github.com/spring-projects/spring-framework/blob/v5.2.2.RELEASE/spring-web/src/main/java/org/springframework/web/client/RestTemplate.java) は Spring Framework(spring-web)だけれども [RestTemplateBuilder](https://github.com/spring-projects/spring-boot/blob/v2.2.2.RELEASE/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/client/RestTemplateBuilder.java) は Spring Boot。
- Java の世界の `なんちゃらBuilder` ([StringBuilder](https://docs.oracle.com/javase/jp/11/docs/api/java.base/java/lang/StringBuilder.html)とか Lombok の[`Builder`アノテーション](https://projectlombok.org/features/Builder)とか、ざっくり総称で Effective Java 版 Builder とでも呼ぶべきか)の使い方は、「まず `builder` のインスタンスを生成します」から始まるので `RestTempalteBuilder` もそれだと思っていた。
  - つまり、このクラスインスタンスは Spring Boot のデフォルト状態でインジェクション可能だけれども、このインジェクションされた`RestTempalteBuilder`インスタンスのスコープは(Spring のデフォルトであるところの)singleton-scope **ではない** と思っていた。
    - だって`builder`インスタンスが singleton-scope なら、ある`bean`で `builder`に設定したものが他所の`bean`にも波及しちゃうじゃない。
- けど[`ResttemplateAutoConfiguration`の Bean 定義部分](https://github.com/spring-projects/spring-boot/blob/v2.2.2.RELEASE/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/web/client/RestTemplateAutoConfiguration.java#L56-L69)どう見ても singleton-scope にしか見えない。何か自分の知らない記法(あるいは暗黙的解釈)がなにかまだあるのか？ **また** 何か Spring マジックが発動しているのか…？

と思ってたけど、`RestTemplateBuilder`の状態設定メソッド([このへん](https://github.com/spring-projects/spring-boot/blob/v2.2.2.RELEASE/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/client/RestTemplateBuilder.java#L141-L668))見て気づいた、 **設定メソッドの中で `new RestTemplateBuilder()` やっとるんかーい！**

インジェクションのタイミングじゃなくて `builder` にビルド設定を渡すタイミングで新しいインスタンスに成り代わってたのね…

# 関連リンク

- [14. Calling REST Services with RestTemplate](https://docs.spring.io/spring-boot/docs/2.2.1.RELEASE/reference/html/spring-boot-features.html#boot-features-resttemplate-customization) - Spring Boot Features

# 余談

Effective Java 版 Builder だと`builder`に情報を設定する際に、`builder`インスタンスを使い回すもよし

```
var builder = new StringBuilder();
builder.append("Hello, ");
builder.append("world!");
builder.toString();
```

戻り値を使ってメソッドチェーンしてもよし

```
new StringBuilder().append("Hello, ").appned("world!").toString();
```

だけれども、 `RestTemplateBuilder` は前者を許してはくれないということか。
