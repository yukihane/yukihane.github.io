---
title: "Spring Boot(Spring MVC)のform送信の仕組みを少しずつ理解する"
date: 2025-05-01T21:19:38+09:00
draft: false
tags: ["spring-boot"]
---

## はじめに

Spring Boot + Thymeleaf でのform送信について、公式ドキュメントとしては

- [Handling Form Submission](https://spring.io/guides/gs/handling-form-submission)
- [Validating Form Input](https://spring.io/guides/gs/validating-form-input)

があります。

しかし、これらのドキュメントは初歩的な説明にとどまり、この知識だけで実践に挑むとかなり苦労します。
また、最近は静的webページでformをpostするみたいなことをやる機会が少なくなっており、検索しても実例が出てこなかったりロストテクノロジー化しつつあるように思われました。
(「ロストテクノロジー化」については、AIに聞けば良い時代になったので今後は問題にはならないかも？)

今回、form post実装で色々とつまづいたことがあったので、そうったことを含めて、上記公式ドキュメントのnext step的な内容をまとめたいと思います。

本記事のコードはKotlinで実装する予定でしたが、Spring Boot(Spring MVC)の事情とKotlin特有の話があるので、Spring MVCの話をするのにJavaで実装し直した箇所が混在しています。

## postデータがcontollerに渡るまでの処理の前提知識

(本節の情報はドキュメントや実装で詳細を確認したわけでなく、経験に拠るものです。ので正確ではないかもしれません)

ユーザーが作成したformデータが、コントローラーのハンドラーの引数として渡ってくるまでには、大きく次の2つの手順を踏みます。

1. formデータの各項目が(今回の場合は)文字列として受け付けられるので、それをそれぞれJavaのオブジェクトに変換する
   - データバインディングと呼ばれる処理
   - ドキュメント: [@InitBinder](https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-controller/ann-initbinder.html)
2. `@Valid`(あるいは `@Validated`) が付与されていれば、バインドしたオブジェクトを検証する
   - いわゆるバリデーション。典型的には Bean Validator を用いて行う
   - ドキュメント: [Validation](https://docs.spring.io/spring-framework/reference/web/webmvc/mvc-controller/ann-validation.html)

私は長い間1.と2.を区別できていませんでした。
Bean Validator は名前の通りBean(Javaオブジェクト)を検証するものであり、そもそもJavaオブジェクトが構築できていないのならvalidationできない、というに気付けばそれはそう、という話ではあるのですが...

どちらも `BindingResult#hasErrors()` で error として扱えたり、大抵の場合は同一視できるのですが微妙な違いもあるので2種類ある、というのは覚えておいた方が良いです。

## 実装、挙動確認

ここからは、実際の挙動を確認していきます。
実行するにはJava21(以降)がインストールされている必要があります。

### ソースコード

まず簡単なフォームを実装して挙動を確認してみます。(以降、bootstrap利用&prettierの整形の都合上、行数が多いですが大したことはしていません)

- [ソースコード](https://github.com/yukihane/hello-java/tree/a52f84feeea8b92e8526eee6f1913fae964d21b6/spring/validation/kotlin-form-binding)
  - hash: a52f84feeea8b92e8526eee6f1913fae964d21b6
  - path: spring/validation/kotlin-form-binding

簡単に解説します。

まず、ユーザー入力とそのデータ送信を行う[form](https://github.com/yukihane/hello-java/blob/a52f84feeea8b92e8526eee6f1913fae964d21b6/spring/validation/kotlin-form-binding/src/main/resources/templates/form.html#L20-L66)とそのformのデータをバインドするクラス [`JavaForm`](https://github.com/yukihane/hello-java/blob/a52f84feeea8b92e8526eee6f1913fae964d21b6/spring/validation/kotlin-form-binding/src/main/java/com/example/kotlin_form_binding/JavaForm.java) を実装します。
`JavaForm`のプロパティにはBean Validationアノテーションを付与します。

postをハンドルするコントローラのメソッドでは、 [`JavaForm` 引数に `@Valid`](https://github.com/yukihane/hello-java/blob/a52f84feeea8b92e8526eee6f1913fae964d21b6/spring/validation/kotlin-form-binding/src/main/kotlin/com/example/kotlin_form_binding/MyController.kt#L29-L30) (または`@Validated`) アノテーションを付与します。
そしてその引数の直後に `BindingResult` 引数を設定します。

formについてはもう少し説明が必要かもしれません。
`th:`で始まるタグはThymeleafのものですが、2種類のドキュメントを参照する必要があります。

- [Tutorial: Using Thymeleaf](https://www.thymeleaf.org/doc/tutorials/3.1/usingthymeleaf.html)
  - (1つ前のバージョンのようですが)[日本語版](https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html)もあるようです
- [Tutorial: Thymeleaf + Spring](https://www.thymeleaf.org/doc/tutorials/3.1/thymeleafspring.html)

そして、今回のようにformを実装する上で必須になるのは後者のドキュメントの [6 Creating a Form](https://www.thymeleaf.org/doc/tutorials/3.1/thymeleafspring.html#creating-a-form) と [7 Validation and Error Messages](https://www.thymeleaf.org/doc/tutorials/3.1/thymeleafspring.html#validation-and-error-messages) です。
(`th:field`とか、実際にform作るのには必須だと思うのですが冒頭で紹介したSpring Boot側のチュートリアルでは一切出てこないですからね…)

### 実行方法

次のコマンド

```sh
./gradlew bootRun
```

で実行し、 http://localhost:8080/java へアクセスします。

次の項目が入力、送信できます:

- name(`String`): `@NotNull`, `@NotEmpty`, `@Size(min = 1, max = 10)`
- birthDate(`LocalDate`): `@NotNull`, `@DateTimeFormat(iso = DATE)`
- age(`Short`): 任意項目

まず、そのまま何も入力せずに「送信」ボタンを押します。

![何も入力せず送信](/202505/01/spring-boot-form-binding/01empty.png)

空入力のとき、`String` は `null` でなく空文字列に変換されているのがわかります。

### 日付フォーマット不正

続いて、生年月日入力欄に、適当な文字列("aaaa" とか)を入力してみます。

![不正な日付](/202505/01/spring-boot-form-binding/02invalid_date.png)

何やら様相の異なるエラーメッセージが出力されています:

> Failed to convert property value of type java.lang.String to required type java.time.LocalDate for property birthDate; Failed to convert from type [java.lang.String] to type [@jakarta.validation.constraints.NotNull @org.springframework.format.annotation.DateTimeFormat java.time.LocalDate] for value [aaaa]

これが、前述の説明した「データバインディング」失敗時の挙動です。

formデータを `JavaForm` オブジェクトにバインドするためには、文字列 "aaaa" を `LocalDate` 型に変換する必要がありますが、この変換処理が成功しなかったのが理由です。

メッセージの趣が異なる理由も、空入力のときの「null は許可されていません」はBean Validator(の実装であるHibernate Validator)が出力しているのに対し、上記のシステマチックなメッセージはSpring MVCが出力しているから、という違いから来ています。

メッセージのカスタマイズ方法については後述します

### 数値オーバーフロー

年齢は `Short` で定義しているので `32767` を超過するとオーバーフローします。

`32768` 以上を入力して送信してみます。
そうすると、メッセージ形式から、データバインディングでエラーになっていることがわかります。
つまり、オーバーフローしないよう検証しようと `@Max(Short.MAX_VALUE)` といったアノテーションを付与したとしても、このBean Validationが動作することはないわけです。

### リストの要素が動的に増減する場合のpost

公式チュートリアル[4.1節](https://www.thymeleaf.org/doc/tutorials/3.1/thymeleafspring.html#the-concept)の図中 "Rows" 箇所のようなものです。

入力する要素数(行数)が動的に変わる箇所の実装です。

公式チュートリアルの実装は [6.6 Dynamic fields](https://www.thymeleaf.org/doc/tutorials/3.1/thymeleafspring.html#dynamic-fields) で説明されている通りで、行追加や行削除を行う際にはサーバーにpostし、サーバー側でバインドオブジェクトの行を増減して送り返すことで、対応するテーブルの行数を増減させています。

確かにこのやりかたはThymeleafとしてはまっとうです。が、今どき行の追加・削除でページ更新が発生するやり方が許容されれるでしょうか…？ということで、私の実装ではjsで行の増減を行い、サーバーリクエストが発生しないような実装を行ってみました。

- [ソースコード](https://github.com/yukihane/hello-java/tree/d91c46453493e332a8e1c3c1c055d28194d8d654/spring/validation/kotlin-form-binding)
  - hash: d91c46453493e332a8e1c3c1c055d28194d8d654
  - path: spring/validation/kotlin-form-binding

[行のtemplate](https://github.com/yukihane/hello-java/blob/d91c46453493e332a8e1c3c1c055d28194d8d654/spring/validation/kotlin-form-binding/src/main/resources/templates/form.html#L78-L96)を作っておき、[jsでcloneして行追加](https://github.com/yukihane/hello-java/blob/d91c46453493e332a8e1c3c1c055d28194d8d654/spring/validation/kotlin-form-binding/src/main/resources/static/js/index.js#L1-L10)、[行のindexを再計算](https://github.com/yukihane/hello-java/blob/d91c46453493e332a8e1c3c1c055d28194d8d654/spring/validation/kotlin-form-binding/src/main/resources/static/js/index.js#L28-L52)しています。

…ただこれ、サンプルの小さい実装だからまだ気にならないかもしれませんが、めちゃめちゃ保守したくないコードです。
個人的には、こういうフロントで動的なことをやらないといけない要件が出たなら、今の時代はThymeleafを捨ててVueやReactなんかで実装すべきなのではと考えています。

閑話休題。
Thymeleafとしては、コレクション要素の `name` は `families[0].familyName` というような形式になります。
これを自動で設定するには

```html
th:field="*{families[__${iterStat.index}__].familyName}"
```

のような書き方をすることになります。

### メッセージのカスタマイズ

#### Bean Validator

Bean Validationのメッセージのカスタマイズ方法は、[Bean Validation 仕様書](https://jakarta.ee/specifications/bean-validation/3.0/jakarta-bean-validation-spec-3.0.html#validationapi-message)に記述があります。
メッセージバンドル `ValidationMessages.properties` を見るので、クラスパスにこの形式のファイルを置いて(優先度を上げて)やればデフォルト設定のメッセージを上書きできます。

具体的には、 [`src/main/resources/ValidationMessages.properties` ファイル](https://github.com/yukihane/hello-java/blob/912a460c01739e0e7b6accdf6f57107476281d43/spring/validation/kotlin-form-binding/src/main/resources/ValidationMessages.properties)を作成し、次のように編集します(実際のエンコーディングは ISO-8859-1(Latin-1) です):

```properties
jakarta.validation.constraints.NotNull.message=必須項目です
```

そうして、アプリケーションを再起動した後前回と同じように空のまま送信すると、メッセージが今回設定した「必須項目です」に変わっているはずです。

key値 `jakarta.validation.constraints.NotNull.message` の部分はどうやって調べるの？という点については、標準のものであれば仕様書の [Appendix B: Standard ResourceBundle messages](https://jakarta.ee/specifications/bean-validation/3.0/jakarta-bean-validation-spec-3.0.html#standard-resolver-messages) に載っています。
が、IDEのクラスファイル(やコンパイル前ソースコード)を覗く機能で実装を見た方が早いでしょう。
例えば `@NotNull` のクラスを見ると次のように実装されています:

```java
public @interface NotNull {
    String message() default "{jakarta.validation.constraints.NotNull.message}";
```

#### データバインディング

ではデータバインディング失敗時のエラーメッセージはどうやってカスタマイズするのでしょう？
検索してみたのですが、どうも公式のドキュメントに明示的には書かれていないようです。

前回試したように、生年月日に不正な文字列を入力して送信します。
そしてハンドラーの中で `BindingResult` をデバッガーで見てみましょう。
`erros[n].codes` (`n` は数値)に文字列が並んでいると思います。

- `typeMismatch.profile.birthDate`
- `typeMismatch.birthDate`
- `typeMismatch.java.time.LocalDate`
- `typeMismatch`

どうやらこれがメッセージのkey値になるようです。この並び順の優先度になっていて、下に行くほど汎用的(なので優先度が低い)ですね。

そして、設定するファイルは、Spring MVCの機能なので、上記の `ValidationMessages.properties` **ではなく** 、 `messages.properties` になります。

(こちらも実際のエンコーディングは ISO-8859-1)

```
typeMismatch=有効な形式ではありません
```

を設定して実行し、生年月日に不正な文字列、年齢にオーバーフローする値を入力して送信してみましょう。
エラーメッセージが「有効な形式ではありません」に変わったことが確認できます。
