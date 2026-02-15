---
title: "Spring Bootブックレビュー 【後悔しないための入門書】Spring解体新書"
date: 2020-07-16T17:41:09Z
draft: true
tags:
  - book
  - spring-boot
---

<div id="header">

</div>

<div id="content">

<div class="sect1">

## [【後悔しないための入門書】Spring解体新書　Java入門のあとはこれを学ぶべき: Spring Boot2で実際に作って学べる！Spring Security、Spring JDBC、Spring MVC、Spring Test、Spring MyBatisなど多数解](https://www.amazon.co.jp/dp/B07H6XLXD7/) / 田村達也

<div class="sectionbody">

<div class="paragraph">

総評としては、次のような感じです:

</div>

<div class="ulist">

- 前回レビューした [Spring Boot 2 入門: 基礎から実演まで](https://www.amazon.co.jp/dp/B0893LQ5KY/) とは異なり、一次情報を参照して正しく説明しよう、という意志が感じられない。自身の経験や二次情報の解説をもとに書いている。

- 一次情報に当たる意志が無いとこの辺りで頭打ちになる、という良い例にはなっている。

  <div class="ulist">
  - この本にちゃんとツッコミが入れられれば入門者卒業、みたいな。

  </div>

</div>

<div class="paragraph">

なので、入門書として読むには薦められない、というのが私の感想になります。

</div>

<div class="paragraph">

以下、読んだ際のメモです:

</div>

<div class="ulist">

- (このメモを作るときに気づいたのですが、節番号がドット区切りだったりハイフン区切りだったりで統一性が無い)

- Kindle for PC で読むと白背景にコードが書かれている部分と黒背景にコードが書かれている部分がある。この違いが何を表しているのかもよくわからないし、白背景の部分はコードが見えない(非常に見づらい)。

- ターゲットが Spring Boot 2.0.3 であり、今やサポートが切れているバージョンを対象にしている。

  <div class="ulist">
  - ただし、現行最新安定版である2.3.1と大きく異なっているのかと言うと、さほど違いはない。

  </div>

- 2-4.プロジェクトの作成: 細かいですが、ライブラリの説明で"Web"について「SpringBootが使えるようになります」とありますが、Webを選択しなければspring-boot-starterが依存関係に入るので、別にWebを選択しなくてもSpringBootは利用可能です。

- 3-1. Hello Worldを表示してみる: Controllerのハンドラメソッド命名について「GETリクエストの場合、メソッド名の頭にgetを付けるのが慣習となっています」とありますが、そのような慣習はないと思います。

- 3-3. データベースから値を取得してみる

  <div class="ulist">
  - 「リポジトリークラスやサービスクラスなどの間で渡すクラスのことをSpringではdomain(ドメイン)クラスと呼びます」とありますが、Springでそのような呼び方を規定しているわけではないですし、それはドメインクラスと言うよりエンティティクラスです。
  - Thymeleaf での form の作り方は [公式リファレンス](https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html#creating-a-form) を参照すべき。

  </div>

- 4-1. DIを一言で説明するなら

  <div class="ulist">
  - DIコンテナを利用しない場合、インスタンスを破棄するためには `null` を代入する必要がある旨の説明が為されているが、この説明は誤り。
  - そもそも Spring Boot はデフォルトでシングルトンスコープなのでコンポーネントインスタンスの破棄なんてしないので2重に間違っている。

  </div>

- 4.2.2. 注入とは何か: 「変数にインスタンスを入れることを入れることを注入と言います」とありますが、これは単なる代入(assign)であって注入(inject)では無いです。

- 4.3.1 DIの中の処理: `@Autowired` を付けられる箇所、の説明が正確でない。例えば「setterの引数」に付与できるとあるが、付与できるのはsetter自身であって引数ではない。

- 4.4.2. DIの落とし穴その1 singleton: デフォルトでsingleton scope なのでControllerインスタンスは1つしか生成されず、そのままだと大量のリクエストが処理しきれなくなる、という旨の説明があるが、完全に誤り。

- 5章が何のために存在しているのかわからない。(6章冒頭でも同じようなことを説明している)

- 6章の冒頭で「この章から本格的なWebアプリケーション開発を通して、Springの使い方を解説していきます。最初は、データバインドとバリデーション(入力チェック)について説明していきます」とあるが、説明する順番が間違っていると思う。

- 依存性を排除するためにインタフェースを経由するんだ、というような説明を行っているにも関わらず、説明コードにその思想が反映されていない(8-3-5 `UserService`)。

</div>

<div class="paragraph">

…疲れたのでここで終わります。

</div>

</div>

</div>

</div>

<div id="footer">

<div id="footer-text">

Last updated 2026-02-15 15:48:50 +0900

</div>

</div>
