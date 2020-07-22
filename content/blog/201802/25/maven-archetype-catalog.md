---
title: maven-archetype-plugin と archetype-catalog.xml 生成場所/読み取り場所
date: 2018-02-25T19:18:52Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
# tags: []
# images: []
# videos: []
# audio: []
draft: false
---

(注: 文中に記載の `localRepository` 設定有無、というのは間違った条件かも知れません(検証中))

# 問題

`mvn archetype:generate -DarchetypeCatalog=local` コマンドを実行したところ、次のようなメッセージが出力され、 `archetype-catalog.xml` を認識できていないような感じでしたので原因を調べてみました。

```
[INFO] No archetype defined. Using maven-archetype-quickstart (org.apache.maven.archetypes:maven-archetype-quickstart:1.0)
Choose archetype:
Your filter doesn't match any archetype (hint: enter to return to initial list)
Choose a number or apply filter (format: [groupId:]artifactId, case sensitive contains): :
```

# 調査内容

使用した Maven のバージョンは、現時点での最新バージョンである `3.5.2` です。

自作の [maven-archetype-java-quickstart](https://github.com/yukihane/maven-archetype-java-quickstart) を用い、次の 3 パターンを試しました。

- plugin を明示しない - `master` ブランチ
- plugin 最新バージョン `3.0.1` を明示する - [`feature/test-maven-archetype-plugin`](https://github.com/yukihane/maven-archetype-java-quickstart/tree/feature/test-maven-archetype-plugin)ブランチ
- plugin `2.4` バージョンを明示する - 上の `feature/test-maven-archetype-plugin` を書き換え

また、 `settings.xml` での `localRepository` 設定の有無でも結果が変わりましたのでそれらをまとめます。

# 調査結果

まず、 `mvn archetype:update-local-catalog` コマンドで `archetype-catalog.xml` が生成される場所です。

<table>
<tr><th></th><th>plugin未設定</th><th>2.4</th><th>3.0.1</th></tr>
<tr><td>localRepository設定無し</td><td>~/.m2/</td><td>~/.m2/</td><td>~/.m2/repository/</td></tr>
<tr><td>localRepository設定有り</td><td>{localRepository}/</td><td>~/.m2/</td><td>{localRepository}/</td></tr>
</table>

plugin を明示しない場合、一貫していません。

---

次に、 `mvn archetype:generate -DarchetypeCatalog=local` コマンド実行時にどの場所にある `archetype-catalog.xml` を読んでいるのかを調べました。

<table>
<tr><td>localRepository設定無し</td><td>~/.m2/</tr>
<tr><td>localRepository設定有り</td><td>{localRepository}/</td></tr>
</table>

# まとめ

- `localRepository` 設定を行ってない場合、 `~/.m2/archetype-catalog.xml` を読みに行こうとするので `3.0.1` を使用したプロジェクトを読み取れない。
- `localRepository` 設定を行っている場合、 `{localRepository}/archetype-catalog.xml` を読みに行こうとするので `2.4` を使用したプロジェクトを読み取れない。

という結果になりました。

`localRepository` 設定有無で `archetype-catalog.xml` を読み取る場所に一貫性が無い、というのが根本原因だと思われますが、結果的には、 `maven-archetype-plugin` を明示していない(私のプロジェクトのような)場合問題が起きない、ということになります。

# 関連するバグレポート

- [[ARCHETYPE-529] Maven archetype:generate does not find local archetypes in interactive mode - ASF JIRA](https://issues.apache.org/jira/browse/ARCHETYPE-529)
