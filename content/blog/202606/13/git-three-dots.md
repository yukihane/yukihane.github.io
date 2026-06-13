---
title: "git log と git diff での ... (三点ドット) の意味の違い"
date: 2026-06-13T22:08:20+09:00
tags: ["git"]
draft: false
---

## TL;DR

- `git log A...B` と `git diff A...B` は、どちらも `...`（三点ドット）を使いますが、意味がまったく異なります
- `git log A...B` は **対称差（symmetric difference）** で、「A にだけあるコミット」と「B にだけあるコミット」の両方を表示します
- `git diff A...B` は **A と B のマージベース（共通祖先）から B までの差分** を表示します。つまり「B ブランチで何が変わったか」を見るためのものです
- GitHub の Pull Request 画面で表示される差分は `git diff A...B` 相当です
    - つまり、みんなが普段欲しい diff は `..` でなく `...`

---

## 手元で試すためのセットアップ

以下のスクリプトで、本記事の図と同じブランチ構造を持つリポジトリを作れます。

```bash
#!/bin/bash
set -e

# 一時ディレクトリにリポジトリを作成
dir=$(mktemp -d)
echo "リポジトリを作成: $dir"
cd "$dir"
git init
git checkout -b main

# 共通の履歴: A, B
echo "file A" > file.txt
git add file.txt && git commit -m "A: initial"

echo "file B" >> file.txt
git add file.txt && git commit -m "B: shared base"

# feature ブランチ: C, D, E
git checkout -b feature
echo "feature C" >> feature.txt
git add feature.txt && git commit -m "C: feature start"

echo "feature D" >> feature.txt
git add feature.txt && git commit -m "D: feature middle"

echo "feature E" >> feature.txt
git add feature.txt && git commit -m "E: feature done"

# main ブランチ: F, G
git checkout main
echo "main F" >> main.txt
git add main.txt && git commit -m "F: main progress"

echo "main G" >> main.txt
git add main.txt && git commit -m "G: main latest"

#      C---D---E  (feature)
#     /
# A---B---F---G    (main)

echo ""
echo "=== git log main..feature (差集合: feature にだけあるコミット) ==="
git log --oneline main..feature

echo ""
echo "=== git log main...feature (対称差: 片方にしかないコミット) ==="
git log --oneline --left-right main...feature

echo ""
echo "=== git diff main..feature (G と E の単純な差分) ==="
git diff --stat main..feature

echo ""
echo "=== git diff main...feature (マージベース B と E の差分 = feature の変更だけ) ==="
git diff --stat main...feature

echo ""
echo "リポジトリのパス: $dir"
echo "cd $dir で移動して自由に試せます"
```

実行すると、各コマンドの出力の違いが一目でわかります。特に `git diff` の `--stat` 出力を見比べると、`..` では `main.txt` の変更が含まれるのに対し、`...` では `feature.txt` の変更だけが表示されるのが確認できます。

---

## 二点ドット `..` のおさらい

三点ドットの前に、まず二点ドット `..` の挙動を確認しておきます。

### git log A..B

`A..B` は「A からは到達できないが B からは到達できるコミット」を返します。言い換えると「B にあって A にないコミット」です。

```
      C---D---E  (feature)
     /
A---B---F---G    (main)
```

この状態で `git log main..feature` は `C, D, E` を返します。`feature` にあって `main` にないコミットです。

### git diff A..B

`git diff A..B` は単純に **A と B のスナップショット間の差分** です。`git diff A B` とまったく同じです。`..` に特別な意味はありません。

---

## 三点ドット `...` の挙動

ここからが本題です。同じ `...` 記法ですが、`log` と `diff` で意味が異なります。

### git log A...B — 対称差

`git log A...B` は **対称差** を返します。「A にだけあるコミット」と「B にだけあるコミット」の両方です。言い換えると、どちらか片方からしか到達できないコミットの集合です。

```
      C---D---E  (feature)
     /
A---B---F---G    (main)
```

`git log main...feature` は `C, D, E, F, G` を返します。`main` にだけあるコミット（`F, G`）と `feature` にだけあるコミット（`C, D, E`）の和集合です。

`--left-right` オプションをつけると、各コミットがどちら側のものかを `<` `>` で表示してくれるので、理解しやすくなります。

```bash
$ git log --oneline --left-right main...feature
< G ...
< F ...
> E ...
> D ...
> C ...
```

### git diff A...B — マージベースとの差分

`git diff A...B` は **A と B のマージベース（共通祖先）と B の差分** を返します。

```
      C---D---E  (feature)
     /
A---B---F---G    (main)
```

`git diff main...feature` は、`main` と `feature` のマージベースである `B` と、`feature` の先頭 `E` との差分を表示します。つまり **feature ブランチで加えた変更だけ** が見えます。`main` 側で進んだ `F, G` の変更は含まれません。

これは `git diff $(git merge-base main feature) feature` と同等です。

---

## なぜ diff だけ違う意味なのか

`git log` はコミットの集合を扱うコマンドなので、集合演算（差集合・対称差）との相性が自然です。`..` が差集合、`...` が対称差、と一貫した集合演算になっています。

一方 `git diff` はコミットの集合ではなく **2つのツリーの差分** を出すコマンドです。対称差という集合演算はそのまま使えません。代わりに `...` には「マージベースからの差分」という、ブランチレビューで最も頻繁に使いたい操作が割り当てられています。

意味は違いますが、どちらも「ブランチの分岐を意識した操作」であることは共通しています。

---

## 実務で効いてくる場面

### Pull Request の差分

GitHub の PR 画面に表示される差分は `git diff main...feature` 相当（マージベースとの差分）です。ベースブランチが先に進んでも、PR の差分にはそのブランチで加えた変更だけが表示されます。

ローカルで PR と同じ差分を確認したいときは、`git diff main...feature` を使います。`git diff main feature`（二点ドット、あるいはドットなし）だと main 側の変更も混ざるので、PR 画面と一致しません。

### ブランチ間で変わったコミットの確認

`git log main...feature --left-right` は、main と feature が互いにどれだけ乖離しているかを俯瞰するのに便利です。rebase するかマージするかを判断する材料にもなります。

---

## まとめ

| コマンド | `..`（二点） | `...`（三点） |
|---|---|---|
| `git log` | A にない B のコミット（差集合） | どちらか片方にしかないコミット（対称差） |
| `git diff` | A と B の単純な差分（`git diff A B` と同じ） | マージベースと B の差分 |

`...` は同じ記号ですが、`log` と `diff` で意味が異なるというのがポイントです。特に `git diff A...B` の「マージベースからの差分」は PR レビューの文脈で頻出するので、覚えておくと役立ちます。

---

> **参考**: [git-log](https://git-scm.com/docs/git-log)、[git-diff](https://git-scm.com/docs/git-diff)、[gitrevisions](https://git-scm.com/docs/gitrevisions)
