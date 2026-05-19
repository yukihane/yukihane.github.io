---
title: "Kotlin のデフォルト引数が Spring AOP プロキシをすり抜けて NPE になる話"
date: 2026-05-20T02:00:00+09:00
tags: ["kotlin", "spring"]
draft: false
---

## TL;DR

- `@Transactional` 系のアノテーション（Spring AOP のクラスプロキシ）が掛かった Kotlin クラスで、**メソッドのデフォルト引数式が注入フィールドを参照**していると `NullPointerException` になることがあります。
- 原因は「Kotlin のデフォルト引数は **static な合成メソッド `xxx$default`** に展開され、それが Spring AOP プロキシのインターセプトをすり抜ける」ためです。
- 同じシグネチャでも **引数を明示的に渡すと再現しません**。そのためテストやコードパスによって出たり出なかったりして気付きにくいです。
- 対策はシンプルです。デフォルト引数で注入依存を参照しないこと。必要なら **メソッド本体で `val` 宣言** するか、オーバーロードで表現します。

---

## 症状

ある UseCase をリファクタして、時刻取得を `Clock` の DI 経由に変えました。

```kotlin
@Service
class ResumeDeliveryUseCase(
    private val repository: SomeRepository,
    private val clock: Clock,
) {
    @ExposedTransactional // 中身は Spring AOP のトランザクション境界
    operator fun invoke(
        projectId: ProjectId,
        now: OffsetDateTime = OffsetDateTime.now(clock), // ← デフォルト引数で注入フィールドを参照
    ): Result<…> {
        // now を使った期限判定など
    }
}
```

ユニットテストは大半が緑のままでした。ところが**特定のテストだけ** `NullPointerException` で落ちます。落ちるテストと落ちないテストの差を見ると、次のようになっていました。

- 落ちるテスト: `useCase(projectId)` と `now` を**省略**して呼んでいる
- 落ちないテスト: `useCase(projectId, now = fixedTime)` と `now` を**明示的に渡している**

ロジックは同じなのに、引数を省略したときだけ落ちます。なぜでしょうか。

---

## 前提知識1: Kotlin のデフォルト引数のコンパイル結果

Kotlin はデフォルト引数を持つ関数を、**2つのメソッド**にコンパイルします。

```kotlin
fun invoke(projectId: ProjectId, now: OffsetDateTime = OffsetDateTime.now(clock))
```

がコンパイルされると、概念的には次の2つになります。

1. **実体メソッド** `invoke(projectId, now)` — 全引数を取る通常のインスタンスメソッド
2. **合成ブリッジ** `invoke$default(receiver, projectId, now, mask, marker)` — **`static` な synthetic メソッド**

呼び出し側のコードは、引数を省略すると実体メソッドではなく `invoke$default(...)` を呼ぶようにコンパイルされます。`invoke$default` の中身はざっくり次のとおりです。

```java
static Object invoke$default(ResumeDeliveryUseCase receiver,
                             ProjectId projectId,
                             OffsetDateTime now,
                             int mask, Object marker) {
    if ((mask & 1) != 0) {
        // now が省略された → デフォルト式を評価
        now = OffsetDateTime.now(receiver.clock); // ★ receiver のフィールドを直接読む
    }
    return receiver.invoke(projectId, now);
}
```

### 「`static` な synthetic メソッド」とは

`invoke$default` を理解する鍵は **`static`** と **synthetic** の2語にあります。

**`static`（静的）メソッド** とは、特定のインスタンスではなく**クラスそのものに属する**メソッドのことです。インスタンスメソッドが暗黙の `this`（レシーバ）を持つのに対し、`static` メソッドには `this` が存在しません。そのため `invoke$default` は、本来 `this` だったはずのレシーバを**第1引数 `receiver` として明示的に受け取る**形になっています。

```java
static Object invoke$default(ResumeDeliveryUseCase receiver, ...) // ← this の代わりに receiver を引数で受ける
```

この「インスタンスメソッドではなく static」という点が、後述する AOP プロキシすり抜けの核心になります。CGLIB はサブクラスでインスタンスメソッドを**オーバーライド**して横取りしますが、`static` メソッドはオーバーライドの対象外なので素通りしてしまいます。

**synthetic（合成）メソッド** とは、**ソースコードには書かれていないのに、コンパイラが自動生成した**メソッドのことです。バイトコード上では `ACC_SYNTHETIC` フラグが付きます。開発者は `now: OffsetDateTime = OffsetDateTime.now(clock)` というデフォルト引数付きの関数を1つ書いただけですが、コンパイラが裏で「引数省略時にデフォルト式を埋めて本体を呼ぶ」橋渡し役を勝手に作ります。それが `invoke$default` です。名前に含まれる `$` は、こうしたコンパイラ生成物であることを示す慣習的な目印になっています。

まとめると、次のようになります。

> **`static` な synthetic メソッド = 「コンパイラが裏で自動生成した（synthetic）、インスタンスに属さない（static）メソッド」**

`static` だから AOP プロキシのインターセプト対象外で、しかも synthetic なのでソース上に現れず開発者の意識に上りにくい。この2つの性質の組み合わせが、本記事の NPE を「気付きにくいバグ」にしています。

---

ここで重要なのは、**デフォルト式 `OffsetDateTime.now(clock)` の `clock` は「`invoke$default` が受け取った receiver のフィールドを直接読む」コードに変換される**ことです。そして `invoke$default` は **static** であることです。

---

## 前提知識2: Spring AOP のクラスプロキシ（CGLIB）の構造

`@Transactional`（やそれ相当の自前アノテーション）はトランザクション境界を張るため、Spring AOP が対象クラスをラップします。インターフェースを実装しない具象クラスの場合、**CGLIB でサブクラスプロキシ**を生成します。

標準的なクラスプロキシでは、ざっくり次の構造になります。

- DI で他の Bean に注入される参照は **プロキシ**（CGLIB が生成したサブクラスのインスタンス）です
- プロキシは Objenesis 等で **コンストラクタを通さずに生成**されます。つまり**プロキシ自身のフィールド（`clock` 含む）は初期化されず null** です
- 本来のロジックは「**ターゲット**」と呼ばれる別インスタンス（コンストラクタ注入済みで `clock` が入っている本物）が持ちます
- プロキシのメソッド呼び出しは AOP のアドバイス連鎖を経て、最終的に `proceed()` で **ターゲット側**に委譲されます

通常のインスタンスメソッドを呼ぶ限り、アドバイスがターゲットに委譲してくれるので「プロキシのフィールドは空」という事実は表に出ません。`this.clock` を読むコードも、実行時の `this` はターゲットなので正しく動きます。

---

## 衝突: デフォルト引数だけがプロキシをすり抜ける

ここで2つの事実が噛み合います。

> **CGLIB がインターセプト（オーバーライド）できるのは「オーバーライド可能なインスタンスメソッド」だけです。`static` メソッドはインターセプトできません。**

`invoke$default` は **static synthetic** メソッドです。したがって引数を省略した呼び出しでは、次のことが起きます。

1. 呼び出し側は、注入された参照（= **プロキシ**）を receiver として `invoke$default(proxy, …)` を呼びます
2. `invoke$default` は static なので **アドバイスを通らず、ターゲットへの委譲も起きません**
3. その中でデフォルト式が `proxy.clock` を**直接**読みます → **プロキシのフィールドは未初期化なので null** です
4. `OffsetDateTime.now(null)` 相当 → **NPE** になります

一方、`now` を明示的に渡すと、コンパイル時に `invoke$default` ではなく**実体メソッドの直呼び**になります。実体メソッドは普通のインスタンスメソッドなので、プロキシ → アドバイス → ターゲット（`clock` 注入済み）と正しく流れ、NPE は起きません。

これが「ロジックは同じなのに引数を省略したときだけ落ちる」の正体です。**デフォルト引数の解決処理だけが AOP プロキシをすり抜けて、注入依存が入っていないプロキシ本体を参照してしまう**のです。

```
useCase(projectId)              → invoke$default(proxy, …)  → static, すり抜け → proxy.clock(null) → 💥 NPE
useCase(projectId, now = t)     → proxy.invoke(projectId, t) → advise → target.invoke(…)            → ✅ OK
```

---

## 修正

デフォルト引数で注入依存を参照するのをやめます。今回はデフォルト引数を撤去し、メソッド本体の先頭で `val` 宣言にしました。

```kotlin
@ExposedTransactional
operator fun invoke(projectId: ProjectId): Result<…> {
    val now = OffsetDateTime.now(clock) // 本体内 → 実体メソッド経由 → target で評価される
    // …
}
```

これで `clock` の参照は **実体メソッドの内部**に移ります。実体メソッドはアドバイス経由でターゲット（`clock` 注入済み）上で実行されるため、`$default` 経路そのものが消えて NPE しなくなります。

「テスト時に時刻を差し替えたい」という意図でデフォルト引数のシームを置いていた場合でも、`Clock` を DI して固定 `Clock` Bean に差し替える設計にしていれば、デフォルト引数のシームは不要になります。テストは固定 `Clock` を注入するだけで決定的になります。

---

## 一般化できる教訓

> **Spring AOP プロキシ（`@Transactional` 系）が掛かるクラスでは、メソッドのデフォルト引数式から注入フィールドやプロキシ対象メソッドを参照しないようにします。**
> デフォルト値が必要なら、(a) メソッド本体で `val` 宣言する、(b) 明示的なオーバーロードで表現する、のどちらかにします。

見つけにくい理由も押さえておきたいところです。

- **引数を明示で渡すコードパスでは絶対に再現しない**ので、テストの書き方次第で「通る／通らない」が分かれます。CI で特定テストだけ落ちる、という形で出やすいです。
- スタックトレースは `xxx$default` の中での NPE になり、一見すると「なぜここで？」となります。`$default` というシグネチャを見たら、この罠を思い出すとよいでしょう。
- 同種の問題は `@Cacheable` / `@Async` / `@Validated` など **Spring AOP プロキシ全般**で起こりえます。`@Transactional` 固有ではありません。

---

## まとめ

- Kotlin のデフォルト引数は `static` な合成メソッド `xxx$default` に展開されます。
- Spring AOP のクラスプロキシは「インターセプト対象のインスタンスメソッド」しか横取りできず、`static` の `$default` はすり抜けます。
- すり抜けた `$default` の中でデフォルト式が注入フィールドを参照すると、プロキシ本体（注入されていない）を読んで NPE になります。
- 引数を明示で渡すと `$default` を通らないので再現しません。そのため発見が遅れがちです。
- 対策は「デフォルト引数で注入依存を参照しない」ことです。本体 `val` 宣言かオーバーロードで回避します。

小さなリファクタ（`OffsetDateTime.now()` を `Clock` DI に置換）が、フレームワークのプロキシ機構とコンパイラの脱糖の交差点で牙を剥いた一例でした。デフォルト引数は便利ですが、AOP プロキシ配下では「その式が実体メソッドの内側で評価されるのか、static ブリッジで評価されるのか」を意識する価値があります。

---

*補足（正確性のため）: 「プロキシのフィールドが null」になる細部は、Spring のプロキシ戦略（ターゲット分離型か same-instance 型か、`@Configuration` クラスか否か、`proxyTargetClass` 設定など）によって挙動差があります。確実に言えるのは「`$default` は static でアドバイス対象外であり、デフォルト式がプロキシをすり抜けて評価される。そこで注入依存を参照すると壊れうる」という構造であり、本記事の症状（省略呼び出し時のみ NPE／明示渡しで回避／本体移動で解消）はこの説明と整合します。*
