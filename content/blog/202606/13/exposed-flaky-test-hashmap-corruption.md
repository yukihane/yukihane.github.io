---
title: "CI の flaky test を追ったら JDK の HashMap が壊れていた"
date: 2026-06-13T00:00:00+09:00
tags: ["kotlin", "exposed", "testing"]
draft: false
---

## TL;DR

- Kotlin + Exposed ORM のプロジェクトで、CI の並列テスト実行時に `ClassCastException: LinkedHashMap$Entry cannot be cast to HashMap$TreeNode` が散発的に発生しました。
- 原因は Exposed 内部の `IdentifierManagerApi` が **非スレッドセーフな `LinkedHashMap`** を識別子キャッシュに使っており、Kotest の並列実行で同時書き込みが起きて HashMap の内部構造が壊れるためです。
- これは [Exposed #1704](https://github.com/JetBrains/Exposed/issues/1704) として報告済みの既知バグで、[Exposed 1.3.0](https://github.com/JetBrains/Exposed/releases/tag/1.3.0) で修正されています。
- ローカルの単独テスト実行では再現しません。CI のテストレポート（HTML アーティファクト）を取得して初めて完全なスタックトレースが得られ、原因を特定できました。

---

## 症状: 無関係な2テストが同じ例外で落ちる

ある PR の CI で、7,000 件超のテスト中 2 件だけが失敗しました。

```
SomeQueryServiceImplTest — ClassCastException
AnotherUseCaseTest       — ClassCastException
```

奇妙なのは、この2つがまったく異なるドメインのコードであることです。一方は集計クエリの QueryService テスト、もう一方はマスターデータ取得の UseCase テスト。PR の変更は前者のドメインに閉じたリファクタリングが中心で、後者には一切触れていません。

さらに、どちらのテストもローカルで単独実行すると問題なく PASS します。

---

## 最初に疑ったこと: PR の変更が原因？

PR にはドメインモデルのリファクタリングが含まれていました。enum のリネーム、フィールド削除、テーブル定義の更新など、それなりに大きな変更です。Exposed の `customEnumeration` で定義した DB の enum 型と Kotlin の enum クラスの齟齬が出ているのでは、と疑いました。

ところが調べていくと:

- テストコード自体は変更されていない
- もう一方のテストは変更対象のドメインと一切関係がない
- Flyway マイグレーションにも enum 型の不整合はない
- `origin/main` との差分を見ても、共通基盤の変更は入っていない

コード変更が原因ではないようです。

---

## 転機: テストレポートの完全なスタックトレース

CI のコンソールログでは、スタックトレースが 1 行しか表示されていませんでした。

```
java.lang.ClassCastException at SomeQueryServiceImplTest.kt:59
    Caused by: java.lang.ClassCastException at SomeQueryServiceImplTest.kt:59
```

これだけでは何もわかりません。CI がアップロードしているテストレポートの HTML アーティファクトをダウンロードして、初めて完全なスタックトレースを確認できました。

```
java.lang.ClassCastException:
  class java.util.LinkedHashMap$Entry cannot be cast to
  class java.util.HashMap$TreeNode

at java.base/java.util.HashMap$TreeNode.moveRootToFront(HashMap.java:1986)
at java.base/java.util.HashMap$TreeNode.treeify(HashMap.java:2102)
at java.base/java.util.HashMap.treeifyBin(HashMap.java:770)
at java.base/java.util.HashMap.putVal(HashMap.java:642)
at java.base/java.util.HashMap.put(HashMap.java:610)
at o.j.exposed.sql.statements.api.IdentifierManagerApi.needQuotes(...)
```

**`LinkedHashMap$Entry` を `HashMap$TreeNode` にキャストしようとして失敗している**——これはアプリケーションコードの型エラーではありません。JDK の `HashMap` 内部構造が壊れていることを示すシグナルです。

---

## 背景: HashMap はなぜ「壊れる」のか

Java の `HashMap` は、同一バケットに 8 個以上のエントリが溜まると、連結リスト（`LinkedHashMap$Entry`）から赤黒木（`TreeNode`）に変換します（treeify）。この変換処理はバケット内のノード型が `Entry` であることを前提としています。

しかし **複数スレッドが同時に `put` を呼ぶと、あるスレッドが treeify を開始した時点で、別スレッドが同じバケットに `Entry` ノードを挿入してしまいます**。結果、treeify が `Entry` を `TreeNode` として読もうとして `ClassCastException` が発生します。

```
スレッド A: put → バケット内 8 件超 → treeify 開始
スレッド B: put → 同じバケットに Entry を追加
スレッド A: treeify 中に Entry を TreeNode として読もうとする → 💥 ClassCastException
```

これは [JDK-8173671](https://bugs.openjdk.org/browse/JDK-8173671) として報告されている既知の挙動です。`HashMap` がスレッドセーフでないことの帰結ですが、多くの人が想像する `ConcurrentModificationException` ではなく `ClassCastException` として現れる点が厄介です。

---

## 原因: Exposed の識別子キャッシュが非スレッドセーフだった

スタックトレースを遡ると、壊れた `HashMap` の出所は Exposed ORM の `IdentifierManagerApi.needQuotes()` でした。

Exposed はテーブル名やカラム名をクォートする際、結果を `LinkedHashMap`（LRU キャッシュ、上限 1,000 エントリ）にキャッシュします。この `IdentifierManagerApi` は **DB の URL ごとに 1 インスタンスが生成され、全トランザクションで共有されます**。

```kotlin
// Exposed 内部（簡略化）
class IdentifierManagerApi {
    // ⚠️ スレッドセーフではない
    private val cache = LinkedHashMap<String, Boolean>(1000, 0.75f, true)

    fun needQuotes(identifier: String): Boolean =
        cache.getOrPut(identifier) { /* クォートが必要か判定 */ }
}
```

`LinkedHashMap` はスレッドセーフではありません。このプロジェクトでは Kotest の `parallelism = 3` 設定で 3 つのテストスペックが同一 JVM 内で並列実行されるため、共有キャッシュへの同時書き込みが発生し、HashMap の内部構造が破壊されていたのです。

2つの無関係なテストが同じ例外で落ちた理由もこれで説明がつきます。どちらのテストも Exposed を通じて SQL を組み立てる際に同じ `IdentifierManagerApi` を経由しており、壊れた HashMap を引き当てたに過ぎません。

---

## なぜローカルでは再現しないのか

この問題がローカルで再現しにくい理由は複数あります。

- **単独テスト実行**: 1 つのスペックだけ実行すればスレッド競合は起きません
- **CPU コア数の違い**: CI の 2 コアランナーではコンテキストスイッチが頻繁に発生し、競合が顕在化しやすくなります。ローカルの多コアマシンではスレッド切り替えが滑らかで、タイミングが合いにくいです
- **キャッシュの暖まり具合**: 全テストスイートの実行順序によっては、キャッシュが十分暖まった状態でテストが走り、`put` が発生しません。単独実行では他のテストが先にキャッシュを埋めてくれることがないため、逆説的に「毎回 `put` が走るのに競合相手がいない」状態になります

---

## 修正の所在

この問題は [Exposed #1704](https://github.com/JetBrains/Exposed/issues/1704) として報告されており、[PR #2783](https://github.com/JetBrains/Exposed/pull/2783) で修正されました。修正内容は `LinkedHashMap` を `Collections.synchronizedMap` でラップし、`getOrPut` をアトミックに行うようにするものです。

```kotlin
// 修正後（概念）
private val delegate: MutableMap<String, V> =
    Collections.synchronizedMap(
        object : LinkedHashMap<String, V>(cacheSize, 0.75f, true) {
            override fun removeEldestEntry(eldest: Map.Entry<String, V>): Boolean =
                size >= cacheSize
        }
    )
```

この修正は **Exposed 1.3.0**（2026 年 5 月リリース）に含まれています。

---

## Production は大丈夫なのか

テスト環境で顕在化しやすい問題ですが、Production でもリスクはゼロではありません。

- **定常状態**: キャッシュが暖まれば読み取りのみになるため、ほぼ安全です
- **デプロイ直後**: キャッシュが空の状態で複数リクエストが並行に来ると、未キャッシュの識別子に対して同時 `put` が発生し得ます
- **影響**: SQL の組み立てフェーズ（`prepareSQL`）でクラッシュし、トランザクションが失敗します

デプロイ直後のコールドスタートは日常的に起きるイベントなので、「CI の flaky test」で済まない可能性がある点は押さえておきたいところです。

---

## 一般化できる教訓

- **「無関係なテストが同じ例外で落ちる」は共有リソースの破壊を疑います。** ドメインが違うのに同じ例外クラスで落ちる場合、原因はアプリケーション層ではなくインフラ層にある可能性が高いです。
- **スタックトレースは最後まで読みます。** CI のコンソール出力は省略されていることが多いです。テストレポートのアーティファクトをダウンロードして完全なスタックトレースを確認する手間を惜しまないようにします。
- **`ClassCastException` は型の間違いとは限りません。** JDK の内部クラス間のキャストエラー（`LinkedHashMap$Entry` → `HashMap$TreeNode` 等）は、ほぼ確実にスレッドセーフ違反による構造破壊を示しています。HashMap の並行アクセスは `ConcurrentModificationException` だけでなく、`ClassCastException`、`NullPointerException`、無限ループなど、予測困難な形で壊れます。

---

## まとめ

- CI の flaky test の正体は、Exposed ORM の `IdentifierManagerApi` 内部キャッシュ（非スレッドセーフな `LinkedHashMap`）の並行アクセスによる HashMap 構造破壊でした。
- [Exposed #1704](https://github.com/JetBrains/Exposed/issues/1704) として報告済みで、1.3.0 で修正されています。
- ローカルの単独テストでは再現しません。CI のテストレポート HTML をダウンロードして完全なスタックトレースを得たことが原因特定の転機でした。
- Production でもデプロイ直後のコールドスタート時に発生しうるリスクがあります。「CI だけの問題」と片付けず、ライブラリのアップグレードで根本解消するのが望ましいです。

一見して PR と無関係な flaky test でしたが、追ってみると JDK の HashMap 内部構造 → Exposed ORM のキャッシュ設計 → OpenJDK の既知バグレポートへと繋がりました。「Re-run で通るから」と見過ごさなかったことで、Production リスクの存在にも気づけた一件でした。

---

> **参考**: [Exposed #1704](https://github.com/JetBrains/Exposed/issues/1704)、[Exposed PR #2783](https://github.com/JetBrains/Exposed/pull/2783)、[JDK-8173671](https://bugs.openjdk.org/browse/JDK-8173671)
