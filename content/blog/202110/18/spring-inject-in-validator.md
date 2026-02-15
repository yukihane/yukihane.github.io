---
title: "Spring Boot でカスタム validator に injection する"
date: 2021-10-18T12:59:08+09:00
draft: false
tags:
  - spring-boot
---

# はじめに

Spring Boot で JPA Validator にインジェクションしようとしたけどできなかった、という話を何度か聞いてその度に調べていたので、次回に備えてまとめておきます。 サンプルコードはこちら:

- <https://github.com/yukihane/hello-java/tree/master/spring/inject-in-validator>

# 解説

Spring Boot で JPA Validator を利用するのは、典型的には

- Sprng MVC でハンドラメソッドにアノテーションを付与する

- 永続化時のバリデーション (一般的な JPA Validation の利用方法)

の 2 つのタイミングがあるのかなと思っています。

前者は次のような感じのものです:

``` java
    @PostMapping("/")
    public MyEntity index(@Valid @RequestBody final MyRequest req) {
        ...
    }

    public record MyRequest(@MyConstraint("1") String name, int age) {
    }
```

こちらは、 Spring Framework のリファレンス [3.7.2. Configuring a Bean Validation Provider](https://docs.spring.io/spring-framework/docs/5.3.3/reference/html/core.html#validation-beanvalidation-spring) に説明があり、この設定を行うことでカスタム validator でも `@Autowired` が利用できるようになります。

ちなみに Spring Boot では自動設定されます([`ValidationAutoConfiguration`](https://github.com/spring-projects/spring-boot/blob/v2.5.5/spring-boot-project/spring-boot-autoconfigure/src/main/java/org/springframework/boot/autoconfigure/validation/ValidationAutoConfiguration.java))ので明示的なコンフィグレーションは不要です。

よく困るのは後者です。エンティティにアノテーションを付与して、永続化時に検証するものです:

``` java
@Entity
public class MyEntity {

    @Id
    private Long id;

    @MyConstraint("4")
    private String name;

    private int age;
}
```

こちらは自動設定されないので明示的なコンフィグレーションが必要になります。 次のような設定を行います:

``` java
import java.util.Map;
import javax.validation.Validator;
import org.springframework.boot.autoconfigure.orm.jpa.HibernatePropertiesCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MyConfig {

    @Bean
    public HibernatePropertiesCustomizer hibernatePropertiesCustomizer(final Validator validator) {
        return new HibernatePropertiesCustomizer() {
            @Override
            public void customize(final Map<String, Object> hibernateProperties) {
                hibernateProperties.put("javax.persistence.validation.factory", validator);
            }
        };
    }
}
```

この設定を行うことで、 JPA フレームワークが用いる validator インスタンスの生成が Spring Framework に委譲され、 Spring Bean として管理されることになります。 そのため `@Autowired` も利用できるようになります。

参考:

- [@AutowiredでインジェクトしたUserServiceがnullになってしまう](https://ja.stackoverflow.com/a/73728/2808) - スタック・オーバーフロー

# 余談

この検証をしていて気づいたのですが、 validator インスタンスは必要に応じて生成されるんですね。

通常の `@Component` を付与した Spring Bean は(特に設定しないと)singleton なので 1 つしか生成されないのですが、そうすると不都合あるよな…(validator が状態を持っているので並行して validation できない)とか思っていたのですが、ちゃんとチェックするタイミングごと(context ごと、というのが正確なのかな？)にインスタンス生成されていますね。
