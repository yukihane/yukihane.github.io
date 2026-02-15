---
title: "Spring Bootブックレビュー Spring Boot 2 入門: 基礎から実演まで"
date: 2020-07-15T14:28:39Z
draft: false
tags:
  - book
  - spring-boot
---





Kindle Unlimited でいくつかのSpring Framework/Spring Boot 本が読めることに気づきました。



もし入門本として有用なものがあれば初心者の方に薦めていきたいなと考え、今回それらを呼んでみましたので感想を記録します。



## [Spring Boot 2 入門: 基礎から実演まで Kindle版](https://www.amazon.co.jp/dp/B0893LQ5KY/) / 原田 けいと, 竹田 甘地, Robert Segawa



購入する場合の価格は780円。



- ○ 独自解釈(と捉えられそうな)の書き方は排除しようという意志が感じられる。ちゃんとオフィシャルの説明を根拠にして書こうとしている。

- ☓ Hello, worldプログラムで\`PostMapping\`を使っている(そして正しくない使い方をしている)。 [オフィシャル](http://localhost:1313/posts/202007/15/spring-boot-books-review/) だとここは `GetMapping` 。


  - 3.3.3節で `GetMapping` が登場するが、 `RequestMapping` との関係について特に言及がなく、唐突に感じる。( `RequestMapping` を使う必要が無かったのでは )

  - 3.4.4節 で `RequestMapping` についてちゃんと説明しているので著者が分かっていないわけではなく、書き方(や説明順)の問題。


- \- MVCウェブフレームワークについての知識がゼロの人だと、唐突に説明なしで用語が登場して戸惑うかもしれない(例えば、人によっては「テンプレートエンジンって何？」「コントローラって何？」となるかもしれない)。ただそのレベルから本書で説明しろ、というのも酷だと思うので個人的には妥当だと思う。

- \- がっつりEclipse(STS)を前提としている。が、敢えてIntelliJとかVSCodeとか使ってる人なら読み替えるのは容易なはずだよね :) 個人的にもSTS前提とするのは妥当だと思う。

- ☓ Springマジックをちゃんと説明するのは難しいので「こう書けばこうなります」的な説明になってしまうのは仕方がないのかな、と思う(例: コントローラのハンドラメソッドで `return "index";` とすれば `templates/index.html` が呼ばれます)。ただ、なんでそうなるのか調べたい人に対して、オフィシャルへの導線があると良かった。

- ○ オフィシャルリファレンスへのリンクが正しい。ちゃんと特定バージョン(今回の場合 `2.3.0.RELEASE` )へのリンクになっている。

- ○ 最初からDevToolsについて言及している。この本がトップバッターなのでなんとも言えないんだけど、多分他の本はDevToolsには触れられていないんじゃないかな…？

- ☓ 最初からThymeleafを使っているが、Thymeleafに対する説明が少し足りない感じを受ける。オフィシャルリファレンス( [3.0](https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf_ja.html), [Springインテグレーション](https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html))へのリンクくらいは有っても良いのでは。

- ☓ 細かいですが、3.3.4節の記述「 `@RequestParam("message")` は、正式には `name="message"` を省略したものです。」は不正確。正しくは(これはJavaの仕様) 「 `value="message"` を省略したもの」。(ただしここでは `name` も `value` も同じ役割なので結果は同じ。)

- ○ 表紙で「2.3対応」と謳っているだけでなく、ちゃんと内容も2.3での変更点が反映されている。具体的には 4.2.3節で validation が別扱いになったこと、5.3節で h2databese データベース自動命名のランダム化、について触れられている。

- ○ これは個人的に参考になった点なのですが、Webjars を使ったことがないので役割や使い方を知れたのはすごく為になりました！

- ☓ 4.3.3節 6.メッセージコンフィグの作成 で `@Configuration`, `@Bean` アノテーションが登場しますが、初学者にとって理解難易度が高いと思うので、もう少し説明が欲しい。書かれている説明だけだと絶対理解できない。せめてオフィシャルリファレンスへのリンクとか。

- ○ Spring Data JPAをちゃんと評価している。日本の記事だと、某氏の影響からか、使いもせずにJPAディス(& MyBatisアゲ)のものが多い…


  - ただ、Spring Data JDBC を誤解しているような気がします。JPAほど複雑さを持ち込まずSpring Data JPAっぽい自動クエリ生成ができるライブラリ、みたいな立ち位置ですよねこれ。(Spring Data JDBC の "JDBC" は "非JPA" みたいなニュアンスの命名。歴史的にも Spring Data JDBC の方が新しい、はず。)


- ☓ 本書で解説し切ることはできないのは当然なので、JPAもしくはHibernateリファレンスへのリンクが欲しい。

- ○ コンストラクタインジェクションを前提としている。また、個人的に `@RequiredArgsConstructor` について触れられているのもポイント高し。

- \- 個人的には `UserDetailsService` 否定派( [参考](https://webcache.googleusercontent.com/search?q=cache:O9yfMuVPTYoJ:https://qiita.com/yukihane/items/e214c0f9f4b671087caa))なので 8.3.3節でそれを使っているのは残念…ですが、まあ、オフィシャルの説明に沿うなら妥当な判断ですよね…

- ☓ 8.3.3節 `@Service` の説明は `@Component` との違いについて、ステレオタイプという概念を交えて説明して欲しかった。

- ☓ テスティングについての言及がない









