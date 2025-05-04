---
title: "KotlinでformバインディングするときもやっぱりJava Beansにした方が良さそう"
date: 2025-05-04T14:17:43+09:00
tags: ["spring-boot", "kotlin"]
draft: false
---

## はじめに

[前回](/blog/202505/01/spring-boot-form-binding.md) の続きになります。
前回はJavaでformバインディングしvalidationを行いました。

今回は、Kotlinでformバインディングしてみて挙動を確認します。

## いろんなバリエーションの型でformバインディングしてみる

### primary-constructor val non-null

- [ソースコード](https://github.com/yukihane/hello-java/tree/e26aa159289f866fe64484ff04f885093cc31988/spring/validation/kotlin-form-binding)
  - hash: e26aa159289f866fe64484ff04f885093cc31988
  - path: spring/validation/kotlin-form-binding

Javaプログラマー(私)がKotlinを始めてまずやろうとするのはこんなところではないでしょうか:

- formバインディングクラスは不変であるべき -> `val` でプロパティ宣言する
- 必須入力のものはnon-nullで定義する

具体的には次のような実装です([`DataClassValForm.kt`](https://github.com/yukihane/hello-java/blob/e26aa159289f866fe64484ff04f885093cc31988/spring/validation/kotlin-form-binding/src/main/kotlin/com/example/kotlin_form_binding/DataClassValForm.kt)):

```
data class DataClassValForm(
    /** 名前(必須) */
    @field:NotNull
    @field:NotEmpty
    val name: String,

    /** 生年月日(必須) */
    @field:NotNull
    @field:DateTimeFormat(iso = DATE)
    val birthDate: LocalDate,

    /** 年齢(任意) */
    val age: Short?,

    /** 家族 */
    @field:Valid
    @field:NotNull
    val families: List<DataClassFamily> = emptyList(),
)

data class DataClassFamily(
    /** 家族の名前(必須) */
    @field:NotNull
    @field:NotEmpty
    val familyName: String,
)
```

ではこれを実行してみましょう。

```
./gradlew bootRun
```

で起動したらブラウザーで http://localhost:8080/dataClassVal にアクセスしてみます。

…サーバーでエラーが発生しますね。

> Parameter specified as non-null is null: method com.example.kotlin_form_binding.DataClassValForm.<init>, parameter name

というこどで、 `DataClassValForm` のコンストラクション時に、 `String` 型である `name` に `null` が入ってしまっているようです。

改めて実装を見てみると、[ハンドラー](https://github.com/yukihane/hello-java/blob/e26aa159289f866fe64484ff04f885093cc31988/spring/validation/kotlin-form-binding/src/main/kotlin/com/example/kotlin_form_binding/MyController.kt#L43)

```
fun dataClassValForm(model: Model, @ModelAttribute("profile") form: DataClassValForm): String {
```

の引数、 `form` オブジェクトがフレームワークによって生成されているはずです。
このオブジェクトの `name` プロパティのデフォルト値は…まあ普通に考えて `null` でしょうね。
なのでオブジェクト型はnullableでなければならないようです。

ちなみにpostではどうなるかというと、

```
curl -X POST http://localhost:8080/dataClassVal \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "name=鈴木一郎" \
  -d "birthDate=x" \
  -d "age=28" \
  -d "families[0].familyName=鈴木さくら"
```

`birthdate` に不正な値が入った時、データバインディングフェーズで `LocalDate` に `null` が設定されるのでやはりうまくいきません。

### primary-constructor val nullable

前節の通り、必須項目であってもnullableにしなければどうもうまく動かないようです。

本節では全てのプロパティ(collectionを除く)をnullableにして試してみます。

- [ソースコード](https://github.com/yukihane/hello-java/tree/92bd707a15296e574794f15bbc7a14368e3c4fad/spring/validation/kotlin-form-binding)
  - hash: 92bd707a15296e574794f15bbc7a14368e3c4fad
  - path: spring/validation/kotlin-form-binding

[`DataClassValNullableForm.kt`](https://github.com/yukihane/hello-java/blob/92bd707a15296e574794f15bbc7a14368e3c4fad/spring/validation/kotlin-form-binding/src/main/kotlin/com/example/kotlin_form_binding/DataClassValNullableForm.kt):

```
data class DataClassValNullableForm(
    /** 名前(必須) */
    @field:NotNull
    @field:NotEmpty
    val name: String?,

    /** 生年月日(必須) */
    @field:NotNull
    @field:DateTimeFormat(iso = DATE)
    val birthDate: LocalDate?,

    /** 年齢(任意) */
    val age: Short?,

    /** 家族 */
    @field:Valid
    @field:NotNull
    val families: List<DataClassFamilyNullable> = emptyList(),
)

data class DataClassFamilyNullable(
    /** 家族の名前(必須) */
    @field:NotNull
    @field:NotEmpty
    val familyName: String?,
)
```

前回との違いは、全てのプロパティの型に `?` が付いていることです。

http://localhost:8080/dataClassValNullable にアクセスして試してみます。

正常系ではうまく動いていそうに見えます。が、生年月日に "aaaa" を入力してみると、

```
Caused by: org.attoparser.ParseException: Exception evaluating SpringEL expression: "name" (template: "form" - line 29, col 18)
...
Caused by: org.springframework.expression.spel.SpelEvaluationException: EL1007E: Property or field 'name' cannot be found on null
```

という例外がスローされ Internal Server Error になってしまいます。

メッセージからは、どうもThymeleafプロセッサーに渡るべき `DataClassValNullableForm` 型オブジェクトが `null` になっている(ので `null` に `name` プロパティなんて無いよ、と言っている)ようです。

が、この「Thymeleafプロセッサーに渡るべき `DataClassValNullableForm` 型オブジェクト」ってハンドラーの `@ModelAttribute` が付いた引数 `form` だと思うのですが、これはちゃんと生成されているのですよね…なぜこのエラーが出るのかがわかっていないです。

原因はわからないのですが、Javaでうまくいく以上、Kotlinでも書き方をどうにかすればこの問題は起こらなくなるはずです。その書き方を探っていきます。

### primary-constructor var nullable

`val` を `var` に変え、デフォルト値も設定してみます。
これでJavaからは引数なしのデフォルトコンストラクター、setter/getterを備えているように見えているはずです。

- [ソースコード](https://github.com/yukihane/hello-java/tree/fe9cd643e486d814d7274b7bbcf76c000caeb8ba/spring/validation/kotlin-form-binding/src/main/kotlin/com/example/kotlin_form_binding)
  - hash: fe9cd643e486d814d7274b7bbcf76c000caeb8ba
  - path: spring/validation/kotlin-form-binding

http://localhost:8080/dataClassValNullable にアクセスして前回と同じく生年月日に妥当でない文字列を入力してみます。
…同じエラーが出ます。

### without primary-constructor

primary constructor でのプロパティ宣言をやめ、bodyで宣言するように変更します。

- [ソースコード](https://github.com/yukihane/hello-java/tree/e75e84b047b464292e8f8070112f84811944e921/spring/validation/kotlin-form-binding/src/main/kotlin/com/example/kotlin_form_binding)
  - hash: e75e84b047b464292e8f8070112f84811944e921
  - path: spring/validation/kotlin-form-binding

http://localhost:8080/kotlin へアクセス、同様に年月日として妥当でない文字列を入力。
…やっと想定通り動作しました！

## まとめ

これまで見てきた結果、KotlinでThymeleafのformバインディングクラスを実装する場合、プロパティは

- var で宣言する
- nullable で宣言する
- primary constructorでなくbodyで宣言する
  - したがってデフォルト値が必要になる

を守る必要があるようです。つまり、 Java Bean 的な実装が求められるようです。

Spring MVCのドキュメントには [constructor binding](https://docs.spring.io/spring-framework/reference/core/validation/beans-beans.html#beans-constructor-binding) ができるって書いてあるし、そもそもSpring自身Kotlin対応してるって言ってるのでなんでこんな挙動になるのだろう？と思っていたのですが、よくよく考えると今回エラーが出ているのはSpring部分ではなくてThymeleafエンジン部分ですね。

そういえばThymeleafってKotlin向けに考慮している、みたいな話を聞いたことが無いし…と納得することにしました。

したがって、 RestController (一般的にJSONとJavaオブジェクトの変換はJacksonを使うと思います)などではまた話が変わってくるかなと思います。
Jacksonは積極的にKotlin対応してたはずですしね。
