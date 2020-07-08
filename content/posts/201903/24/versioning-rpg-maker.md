---
title: RPGツクールMVをバージョン管理するための初期設定
date: 2019-03-24T20:02:46Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [rpg-maker]
# images: []
# videos: []
# audio: []
draft: false
---

他の方が同じ話題で次のエントリを書かれていましたが、gulp 何それ状態なので理解できませんでした。理解できる方はそちらの方が良いのかもしれません。

- [RPG ツクール MV プロジェクトをバージョン管理したい話 - Qiita](https://qiita.com/stak/items/edb9431e925d1113c78a)

---

## 問題

RPG ツクール MV のリソースをバージョン管理したい。
`json`, `js` の差分が見られると嬉しいが、そのまま `git diff`, `git diff --word-diff` してもみづらい。

## 対策

`json`, `js` ファイルについて、RPG ツクール MV が出力したファイルをそのまま管理対象にするのではなく、commit 前に整形して管理することで差分を見やすくする。

今回、整形には [`prettier`](https://prettier.io/) を用いることにした。

### 設定手順

RPG ツクール MV 上でプロジェクトを新規作成し、プロジェクトディレクトリに行く。
ついでに無駄に付与されている実行権限も落とす。

    cd ~/Documents/Games/Project1
    find . -type f -print0|xargs -0 chmod 644

git 初期化、初期コミット。

    git init
    git commit --allow-empty -m init
    curl -L -o .gitignore https://gitignore.io/api/node,visualstudiocode
    git add .gitignore
    git commit -m gitignore
    git add .
    git commit -m "auto-generated files"

(以後、適宜 `git commit` )

npm プロジェクト初期化実行。

    npm init -y

`prettier` と、オンデマンド実行用プラグインをインストール。

    npm i -D prettier husky lint-staged onchange

`js/plugins.js` は整形すると正常動作しなかったので整形対象外に設定しておく。

    echo "js/plugins.js" >> .prettierignore

`npm run format` コマンドで明示的に整形、また、 `npm run prettier-watch` コマンドでファイル変更を検知して自動整形するように設定。
(参考: [CLI](https://prettier.io/docs/en/cli.html), [Watching For Changes](https://prettier.io/docs/en/watching-files.html))

`package.json`:

```
{
  ...
  "scripts": {
    "format": "prettier --write **/*.js **/*.json",
    "prettier-watch": "onchange '**/*.js' '**/*.json' -- prettier --write {{changed}}"
  },
  ...
}
```

`husky` と `lint-staged` を使って `git-commit` 時に自動整形するように設定。
(参考: [Pre-commit Hook - Option 1. lint-staged](https://prettier.io/docs/en/precommit.html#option-1-lint-staged-https-githubcom-okonet-lint-staged))

`package.json`:

```
{
  ...
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged"
    }
  },
  "lint-staged": {
    "*.{js,json}": [
      "prettier --write",
      "git add"
    ]
  },
  ...
}
```

自動生成されたコードを整形してコミットしておく。

    npm run format
    git commit -am "format codes"
