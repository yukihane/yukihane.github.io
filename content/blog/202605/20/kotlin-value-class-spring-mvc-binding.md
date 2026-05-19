---
title: "Kotlin の @JvmInline value class が Spring MVC のパラメータバインディングで壊れる話"
date: 2026-05-20T03:00:00+09:00
tags: ["kotlin", "spring"]
draft: false
---

## TL;DR

- Kotlin の `@JvmInline value class` を `@ModelAttribute` で受ける data class のプロパティに使うと、リクエスト時に `BeanInstantiationException` が発生します。
- 原因は Kotlin リフレクション API が value class のアンラップ済み型を正しく扱えないバグ（[KT-64097](https://youtrack.jetbrains.com/issue/KT-64097)）です。Spring Framework 6.1.0 以降のリフレクションベース（`KCallable#callBy`）のパラメータ解決と噛み合って表面化します。
- Spring 側はこれを「Kotlin のバグ」として `NOT_PLANNED` でクローズ済みです（[spring-framework#31698](https://github.com/spring-projects/spring-framework/issues/31698)）。フレームワークの修正は期待できません。
- 回避策はバインディング方式によって異なります。`@ModelAttribute` の data class では value class を使わず、`UUID` 等の素の型で受けて Controller 内で value class に変換するのが安全です。

---

## value class とは

Kotlin の `@JvmInline value class` は、1つの値を型安全にラップするための仕組みです。

```kotlin
@JvmInline
value class GroupId(val value: UUID)
```

`UUID` をそのまま引き回すと「どの ID なのか」が型で表現されず取り違えが起きやすくなります。`GroupId` のような value class でラップすると、コンパイラが型レベルで区別してくれます。しかも **コンパイル時にラップ先の型（ここでは `UUID`）へ展開（アンボクシング）される** ため、実行時のオブジェクト生成コストがほぼありません。型安全とゼロコストを両立できる、Kotlin らしい道具です。

ところが、この「コンパイル時に別の型へ展開される」性質が、リフレクションを多用するフレームワークと相性が悪いのです。

---

## 症状

`@ModelAttribute` で受け取る data class のプロパティに value class を使うと、リクエスト時に `BeanInstantiationException` が発生します。

```kotlin
// ❌ @ModelAttribute の data class に value class を使用 → BeanInstantiationException
data class ListEmployeesRequest(
    val groupId: GroupId?, // Kotlin リフレクションが GroupId を正しく解決できない
    val keyword: String?,
)

@GetMapping("...")
fun list(@Valid request: ListEmployeesRequest) // 実行時エラー
```

コンパイルは通ります。テストの書き方やリクエストパラメータの有無によっては表面化しないこともあり、特定のエンドポイントだけ実行時に落ちる、という形で現れます。

---

## 原因: Kotlin リフレクションと value class アンラップのズレ

Spring Framework 6.1.0 以降、Kotlin の data class バインディングは Kotlin リフレクション（`KCallable#callBy`）ベースのパラメータ解決を使うようになりました。コンストラクタの引数を名前で解決し、リフレクション経由でインスタンスを生成する方式です。

しかし、value class は前述のとおり **コンパイル時にラップ先の型へアンボクシングされます**。この「ソース上の型（`GroupId`）」と「実体の型（`UUID`）」のズレを、Kotlin リフレクション API が正しく橋渡しできないバグがあります（[KT-64097](https://youtrack.jetbrains.com/issue/KT-64097)）。結果として、`callBy` でコンストラクタを呼ぼうとした時点で値を組み立てられず、Spring 側で `BeanInstantiationException` として表面化します。

Spring プロジェクトはこの問題を Spring 自身のバグではなく **Kotlin リフレクションのバグ** と位置づけ、[spring-framework#31698](https://github.com/spring-projects/spring-framework/issues/31698) を `NOT_PLANNED` でクローズしています。つまりフレームワーク側の修正で解決される見込みは薄く、利用側で避けるしかありません。

---

## バインディング方式ごとの影響

同じ value class でも、どのバインディング経路を通るかで挙動が変わります。

| バインディング方式 | value class | 備考 |
|---|---|---|
| `@ModelAttribute`（data class バインディング） | ❌ 使用不可 | Kotlin リフレクションのバグにより `BeanInstantiationException` |
| `@PathVariable` / `@RequestParam`（単独パラメータ） | ⚠️ 要注意 | 基本的に動作するが、value class マングリングの影響を受ける場合がある |
| `@RequestBody`（JSON） | ✅ 使用可能 | Jackson がデシリアライズを処理するため影響なし |

ポイントは「**誰がインスタンスを組み立てるか**」です。`@RequestBody` は Jackson がデシリアライズを担うのでこのバグの影響を受けません。一方 `@ModelAttribute` の data class バインディングは Kotlin リフレクション経由のため直撃します。

> **関連**: `@ModelAttribute` の Kotlin data class バインディングが脆いのは value class に限った話ではありません。以前 [KotlinでformバインディングするときもやっぱりJava Beansにした方が良さそう]({{< ref "blog/202505/04/kotlin-form-binding/" >}}) で、non-null プロパティや primary constructor 宣言だと壊れ、`var` + nullable + body 宣言（≒ Java Bean 的な書き方）が必要になる挙動を確認しました。根っこは共通で「Kotlin の data class と、リフレクションでインスタンスを組み立てるフレームワークの相性問題」です。その記事の末尾では「`@RequestBody` / Jackson なら話が変わるはず」と予想していましたが、本記事の影響表（`@RequestBody` は ✅）がそれを裏付ける形になりました。

---

## 回避策

`@ModelAttribute` の data class では value class を使わず、**素の型（`UUID` 等）で受け取り、Controller 内で value class に変換する**のが確実です。

```kotlin
// ✅ UUID で受け取り、Controller で value class に変換
@GetMapping("...")
fun list(
    @RequestParam(required = false) groupId: UUID? = null,
    // ...
) {
    val query = EmployeeListQuery(
        filter = EmployeeFilter(groupId = groupId?.let { GroupId(it) }),
    )
}
```

境界（Controller の引数）では素の型で受け、ドメイン層へ渡す手前で value class に包みます。型安全の恩恵はドメイン層で受けつつ、リフレクションの罠を避けられます。

---

## まとめ

- `@JvmInline value class` はコンパイル時にラップ先の型へアンボクシングされます。
- Spring 6.1.0 以降の Kotlin data class バインディングは Kotlin リフレクション（`callBy`）を使いますが、リフレクション API が value class のアンラップ済み型を正しく扱えません（KT-64097）。
- このため `@ModelAttribute` の data class プロパティに value class を使うと `BeanInstantiationException` になります。
- Spring 側は「Kotlin のバグ」として `NOT_PLANNED` クローズ済みです。フレームワーク修正は期待できません。
- `@RequestBody`（JSON）は Jackson 経由なので影響ありません。`@ModelAttribute` では素の型で受けて Controller 内で value class に変換します。

value class は型安全とゼロコストを両立する優れた道具ですが、「コンパイル時に別の型へ消える」という性質上、リフレクションを多用するフレームワークの境界では油断できません。どのバインディング経路が誰によってインスタンス化されるかを意識しておきたいところです。

---

> **参考**: [KT-64097](https://youtrack.jetbrains.com/issue/KT-64097)、[spring-framework#31698](https://github.com/spring-projects/spring-framework/issues/31698)、[spring-framework#28638](https://github.com/spring-projects/spring-framework/issues/28638)
