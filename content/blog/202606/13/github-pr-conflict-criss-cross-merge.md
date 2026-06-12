---
title: "GitHub PR が「コンフリクトあり」と言うのにローカルではマージできる"
date: 2026-06-13T00:00:00+09:00
tags: ["git", "github"]
draft: false
---

## TL;DR

- GitHub の Pull Request が "This branch has conflicts" と表示するのに、ローカルで `git merge` すると何事もなく成功する、ということがあります。
- 原因は **criss-cross merge**（交差マージ）で `merge-base` が複数存在する状態です。
- ローカルの git（`ort` / `recursive` ストラテジー）は複数の merge-base を仮想ベースに統合して賢く解決しますが、GitHub のマージエンジンは同じ状況をうまく処理できないことがあります。
- 解決策は `git rebase` で履歴を線形化することです。

---

## 状況

スタックド PR（PR-A の上に PR-B を積む運用）をしていて、次のようなことが起きました。

1. `feature-a` ブランチから `feature-b` ブランチを切って作業
2. 途中で別ブランチ `feature-c` の変更も `feature-b` にマージ（`feature-c` の修正が `feature-b` の作業に必要だった）
3. `feature-a` と `feature-c` がそれぞれ main にマージされた
4. `feature-b` の PR の base が main に切り替わった

この時点で GitHub が "This branch has conflicts that must be resolved" と表示します。ところが手元で試すと：

```console
$ git fetch origin main
$ git merge --no-commit --no-ff origin/main
Automatic merge went well; stopped before committing as requested
```

問題なくマージできてしまいます。

---

## 再現手順

以下のスクリプトでこの状態を手元で再現できます。

```bash
#!/bin/bash
set -e

# 準備
mkdir criss-cross-demo && cd criss-cross-demo
git init
git config user.name "demo"
git config user.email "demo@example.com"

# 初期コミット: 2つのファイル
printf 'function greet() {\n  return "hello"\n}\n' > greet.js
printf 'function farewell() {\n  return "bye"\n}\n' > farewell.js
git add . && git commit -m "initial"

# feature-a: greet.js を変更
git checkout -b feature-a
printf 'function greet() {\n  const name = getName()\n  return "hello, " + name\n}\n' > greet.js
git commit -am "feature-a: greet with name"

# feature-c: farewell.js を変更（main から分岐）
git checkout main
git checkout -b feature-c
printf 'function farewell() {\n  const name = getName()\n  return "bye, " + name\n}\n' > farewell.js
git commit -am "feature-c: farewell with name"

# feature-b: feature-a の上に作り、feature-c もマージ
git checkout feature-a
git checkout -b feature-b
printf 'function greet() {\n  const name = getName()\n  return "hello, " + name + "!"\n}\n' > greet.js
git commit -am "feature-b: add exclamation"
git merge feature-c -m "merge feature-c into feature-b"

# main に feature-a と feature-c を順番にマージ（PR マージに相当）
git checkout main
git merge feature-a -m "merge feature-a into main"
git merge feature-c -m "merge feature-c into main"
```

ここまで実行すると、次のようなコミットグラフになります。

```console
$ git log --oneline --all --graph
*   0fe9585 merge feature-c into main
|\
| | *   cfd8223 merge feature-c into feature-b
| | |\
| | |/
| |/|
| * | 831f6a0 feature-c: farewell with name
| | * 86034d8 feature-b: add exclamation
| |/
|/|
* | ea6a724 feature-a: greet with name
|/
* ea3e8d0 initial
```

`feature-b` と `main` の merge-base を調べると、2つ返ってきます。

```console
$ git merge-base --all main feature-b
ea6a724...  # feature-a のコミット
831f6a0...  # feature-c のコミット
```

この2つは互いに祖先関係にありません。これが criss-cross merge です。

```console
$ git merge-base --is-ancestor ea6a724 831f6a0; echo $?
1    # 祖先ではない
$ git merge-base --is-ancestor 831f6a0 ea6a724; echo $?
1    # こちらも祖先ではない
```

そしてローカルでのマージは成功します。

```console
$ git checkout feature-b
$ git merge --no-commit --no-ff main
Automatic merge went well; stopped before committing as requested
```

この状態で GitHub に push して PR を作ると、GitHub 側では "This branch has conflicts" と表示されうるわけです。

---

## 原因: criss-cross merge とは

通常の 3-way merge では、2つのブランチの共通祖先（merge-base）が **1つに定まります**。しかし上のケースでは、`feature-b` に `feature-a` と `feature-c` が **それぞれ独立に取り込まれ**、main にも **それぞれ独立にマージされている** ため、最近共通祖先が2つ存在します。

```
        main
         │
    ┌────┴────┐
    │         │
 feature-a  feature-c    ← 両方とも main と feature-b の両方に入っている
    │         │
    └────┬────┘
         │
      feature-b
```

このように、DAG 上で同等な merge-base が複数存在する状態を criss-cross merge と呼びます。

---

## ローカル git と GitHub で結果が異なる理由

### ローカルの git（`ort` / `recursive` ストラテジー）

git のデフォルトマージストラテジーは、merge-base が複数ある場合に **仮想的なマージベースを生成** します。複数の merge-base 同士を再帰的にマージして1つの仮想コミットを作り、それを base として 3-way merge を行います。この「再帰マージ」の賢さによって、criss-cross でも多くのケースで自動解決できます。

### GitHub のマージエンジン

GitHub がサーバー側でどのマージアルゴリズムを使っているかは公開されていません。しかし実際の挙動として、criss-cross merge の状況で「ローカルでは解決できるのに GitHub では conflict と判定される」ケースが存在します。

---

## 解決策: rebase で線形化する

`feature-b` を main の上に rebase すると、criss-cross 構造が解消されて merge-base が一意になります。

```console
$ git rebase main  # （リモートなら origin/main）
```

rebase 中にコンフリクトが出る場合がありますが、これは git が正直に示してくれるコンフリクトなので、通常どおり解決して `git rebase --continue` すれば OK です。

rebase 後は merge-base が1つになっていることを確認できます。

```console
$ git merge-base --all main feature-b
（1つだけ返る）
```

rebase 後に force push すれば、GitHub のコンフリクト表示も解消されます。

---

## まとめ

- **スタックド PR + 複数ブランチの交差取り込み** で criss-cross merge が発生しやすいです。
- ローカルの git は merge-base が複数あっても仮想ベースで解決できますが、GitHub のマージ判定は同じ状況に対応できないことがあります。
- 「ローカルでマージできるのに GitHub が conflict と言う」場合は、`git merge-base --all` を確認してみてください。2つ以上返ってきたら criss-cross merge です。
- `git rebase` で履歴を線形化すれば解決します。
