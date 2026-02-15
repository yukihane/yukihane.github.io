---
title: "DevToolsを組み込んでいると再起動してもsessionが引き継がれる"
date: 2020-09-01T18:46:13Z
draft: false
tags:
  - spring-boot
---

Spring Boot開発中、再起動するとsessionは消失すると思いこんでいたのですが、どうも引き継がれているように見えて混乱しました。

その後、調査してみると `server.servlet.session.persistent` プロパティで再起動時セッションを破棄するか保持するかを設定できることがわかりました。ただし、デフォルト値は `false` で、もちろんデフォルトからは変更していません(存在を知らなかったので)。

仕方がないので [`Session#setPersistent()`](https://github.com/spring-projects/spring-boot/blob/v2.3.3.RELEASE/spring-boot-project/spring-boot/src/main/java/org/springframework/boot/web/servlet/server/Session.java#L83) メソッドでブレークポイントを設定してデバッグ実行してみたところ、確かに誰かが `true` に設定しようとしていることがわかりました。 しかし、誰が設定しようとしているのかが全くわからない…

更にググってなんとか情報が見つかりました:

- [Default value of `server.servlet.session.persistent` - Stack Overflow](https://stackoverflow.com/a/61094170/4506703)

これによると `DevToolsPropertyDefaultsPostProcessor` で設定されている、とのことなので見てみると… [確かに](https://github.com/spring-projects/spring-boot/blob/v2.3.3.RELEASE/spring-boot-project/spring-boot-devtools/src/main/java/org/springframework/boot/devtools/env/DevToolsPropertyDefaultsPostProcessor.java#L68) ！

というか、DevToolsを組み込むことで他にもいろんなデバッグ用設定が有効になるんですね…知りませんでした。

    properties.put("spring.thymeleaf.cache", "false");
    properties.put("spring.freemarker.cache", "false");
    properties.put("spring.groovy.template.cache", "false");
    properties.put("spring.mustache.cache", "false");
    properties.put("server.servlet.session.persistent", "true");
    properties.put("spring.h2.console.enabled", "true");
    properties.put("spring.resources.cache.period", "0");
    properties.put("spring.resources.chain.cache", "false");
    properties.put("spring.template.provider.cache", "false");
    properties.put("spring.mvc.log-resolved-exception", "true");
    properties.put("server.error.include-binding-errors", "ALWAYS");
    properties.put("server.error.include-message", "ALWAYS");
    properties.put("server.error.include-stacktrace", "ALWAYS");
    properties.put("server.servlet.jsp.init-parameters.development", "true");
    properties.put("spring.reactor.debug", "true");
