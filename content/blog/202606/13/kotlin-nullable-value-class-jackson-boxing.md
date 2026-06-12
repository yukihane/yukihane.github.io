---
title: "Jackson + Kotlin の nullable な value class が {\"value\":\"...\"} で出力される"
date: 2026-06-13T00:00:00+09:00
tags: ["kotlin", "jackson"]
draft: false
---

## TL;DR

- Kotlin の `@JvmInline value class` を **nullable** なプロパティとして持つ data class を `jackson-module-kotlin` でシリアライズすると、auto-unwrap が効かず `{"value":"..."}` の boxed object として出力されることがあります。
- Jackson 2.17 で value class サポートは正式に入りましたが、公式 docs は **"there are many edge cases for the `value class` that wraps nullable"** と明記しており、完全解決ではありません。
- 推奨される回避策は value class 側の underlying プロパティに `@get:JsonValue` を付与することです。

---

## 何が起きたか

Kotlin で ID 系の型安全性を担保するために、こういう value class を定義しているプロジェクトは多いと思います。

```kotlin
@JvmInline
value class UserId(private val value: UUID) {
    override fun toString() = value.toString()
}
```

これを REST API の Response model でそのまま露出します。

```kotlin
data class UserResponse(
    val userId: UserId,
    val name: String,
)
```

`jackson-module-kotlin` の `registerKotlinModule()` を効かせていれば、`@JvmInline value class` は auto-unwrap されて中身の値だけで serialize されます。`userId` は `"01HW...UUID..."` の文字列で出ます。ここまでは想定通りです。

ところがプロパティを **nullable** にした瞬間、挙動が変わります。

```kotlin
data class CommentResponse(
    val commentId: CommentId,
    val replyToId: CommentId?, // ← nullable
)
```

`replyToId` が non-null のとき、期待していたのは:

```json
{ "commentId": "01HW...", "replyToId": "01HX..." }
```

実際に出るのは:

```json
{ "commentId": "01HW...", "replyToId": { "value": "01HX..." } }
```

フロントエンド側で `z.string().nullish()` のような Zod schema を当てていると、当然 parse に失敗します。

---

## なぜ起きるか

Kotlin の inline / value class は、コンパイル後に「可能なら」underlying value 1個に展開されます。ただしこれは **non-null 文脈に限った最適化** で、nullable にした瞬間に Kotlin コンパイラは実行時に wrapper object として box する必要があります（null と underlying value の `0` を区別できないため）。

Jackson はその box された wrapper object を「普通の POJO」として認識し、内部プロパティ名 `value` をそのまま JSON のキーとして書き出してしまいます。これが `{"value":"..."}` の正体です。

---

## Issue の状態

関連する jackson-module-kotlin の issue は全部 closed になっています。

- [#199 — Support for inline classes](https://github.com/FasterXML/jackson-module-kotlin/issues/199)
- [#462 — invalid field names from value classes](https://github.com/FasterXML/jackson-module-kotlin/issues/462)
- [#563 — Nullable value class properties included even with JsonInclude.NON_NULL](https://github.com/FasterXML/jackson-module-kotlin/issues/563)
- [#650 — Supports deserialization of value class](https://github.com/FasterXML/jackson-module-kotlin/issues/650)

これらは [PR #768](https://github.com/FasterXML/jackson-module-kotlin/pull/768) で取り込まれ、**Jackson 2.17.0** (2024-03) でリリースされました。opt-in flag はなく、`registerKotlinModule()` するだけでデフォルト有効です。

ただし「全解決」ではありません。公式 docs [`docs/value-class-support.md`](https://github.com/FasterXML/jackson-module-kotlin/blob/2.18/docs/value-class-support.md) には明確にこう書かれています。

> there are many edge cases for the `value class` that wraps nullable

特に nullable を含むケースでは、`@JsonSerialize(using = ...)` を当てても意図通り効かない、といった既知の制約が残っています。

---

## 推奨される回避策: `@get:JsonValue`

公式 docs もワークアラウンドとして案内しているのが `@JsonValue` の付与です。value class の underlying プロパティに付けます。

```kotlin
import com.fasterxml.jackson.annotation.JsonValue

@JvmInline
value class UserId(
    @get:JsonValue private val value: UUID,
) {
    override fun toString() = value.toString()
}
```

ポイントは2つです。

1. **`@get:` 接頭辞が必須** — value class の primary constructor プロパティに直接 `@JsonValue` を付けても getter には伝播しません。`@get:` で明示的に getter にアノテーションを付ける必要があります。
2. `@JsonValue` は「このクラスを serialize するときは、このプロパティ単体の値で表現する」と Jackson に伝えるアノテーションです。auto-unwrap の有無に関わらず、nullable / non-null 問わず一貫して中の値だけが出ます。

これで `replyToId: UserId?` でも期待通り `"replyToId": "01HX..."` または `"replyToId": null` で出力されます。

---

## 他の選択肢と比較

| 方針 | 影響範囲 | 規約維持 | 横展開コスト |
|---|---|---|---|
| Response の型を `String?` に降格 | 当該エンドポイントのみ | × | nullable VO ごとに個別対応 |
| カスタム `JsonSerializer<T>` を `SimpleModule` に登録 | 全 Response | ○ | VO ごとに serializer 実装 |
| **value class に `@get:JsonValue` を付与** | 全 Response | ○ | VO 一箇所のみ |

「Domain 層の value class に Jackson アノテーションを付けるのは Presentation 都合を Domain に持ち込んでいる」という DDD 観点の議論はあります。ただし value class を Response model にそのまま露出するという設計をすでに採用しているなら、その境界は元々曖昧で、`@get:JsonValue` で局所的に整合させるのが現実解になります。

---

## デシリアライズ側について

Jackson 2.17+ で value class の deserialization もサポートされましたが、Request body で受ける用途があるなら `@JsonCreator` を value class に付けておくとより堅いです。

```kotlin
@JvmInline
value class UserId @JsonCreator(mode = JsonCreator.Mode.DELEGATING) constructor(
    @get:JsonValue private val value: UUID,
)
```

---

## まとめ

- nullable な `@JvmInline value class` プロパティは Jackson の auto-unwrap が効かず `{"value":"..."}` として box されます。
- Issue は closed ですが、公式 docs が "many edge cases" の残存を認めています。
- Response model で value class を露出する設計を採るなら、value class 側に `@get:JsonValue` を付ける運用が現実的です。
- 単一エンドポイントで `String?` 降格してその場しのぎするより、value class 一箇所修正で全 Response が一貫します。

型安全性のために導入した value class が serialize 層で破綻するというのはかなり罠で、API contract テスト（実際の `ObjectMapper` で JSON 化して `isTextual` / `isObject` を assert する）を入れておくと回帰検知できます。

> **関連**: [Kotlin の @JvmInline value class が Spring MVC のパラメータバインディングで壊れる]({{< ref "blog/202605/20/kotlin-value-class-spring-mvc-binding/" >}}) — 同じ value class が Spring MVC のリフレクションベースバインディングでも問題を起こすケースです。

---

> **参考**: [jackson-module-kotlin — docs/value-class-support.md](https://github.com/FasterXML/jackson-module-kotlin/blob/2.18/docs/value-class-support.md)、[jackson-module-kotlin PR #768](https://github.com/FasterXML/jackson-module-kotlin/pull/768)、[Kotlin — Inline value classes](https://kotlinlang.org/docs/inline-classes.html)
