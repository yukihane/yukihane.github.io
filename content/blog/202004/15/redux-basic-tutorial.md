---
title: ReduxのBasic TutorialにTypeScriptで型を付けただけ
date: 2020-04-15T20:56:22Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [react, redux]
# images: []
# videos: []
# audio: []
draft: false
---

Redux 多分使わないけど理解のため写経。

答え合わせに他の方が似たようなことやってないかググったけれども プラスアルファ要素(Redux Toolkit を使う、feature folders 流派でフォルダ分け、etc)が付いてたりして 1 対 1 で突き合わせて確認できるものが見つからなかった。ので自分が書いたものをリンクしておく:

- https://github.com/yukihane/hello-js/tree/master/redux.js.org/basic-tutorial-typescript

参考にしたのは[Basic Tutorial](https://redux.js.org/basics/basic-tutorial)章の各ページ(そしてそこからリンクされていた[`connect()`](https://react-redux.js.org/api/connect#connect))と Recipes 章の [Usage With TypeScript](https://redux.js.org/recipes/usage-with-typescript)。

写経しているときの所感としては:

- [こっち](https://qiita.com/yukihane/items/c8ff9864925358dbf6cd)にも書いたけどこの tutorial でやってる folders by type 流儀は近い将来書き直されるみたいなので、上記のコードも寿命は長くない。
- `Dispatch`とか `DispatchProp` とかたまたま見つけたけど本来はどうやってライブラリで定義している型を探し当てれば良いのかわからない。(未解決)
- [Basic Tutorial](https://redux.js.org/basics/basic-tutorial)章、最後のページ "[Example: Todo List](https://redux.js.org/basics/example)" は[実際のコード](https://redux.js.org/introduction/examples#todos)と同期が取れているようだがそれ以外のページはコードサンプルが最新化されていない。そのため順に読みながら理解したところを写経していく、というスタイルを取ると整合性が取れなくなる。
  - [コードでは修正済みのバグが残ってたり](https://github.com/reduxjs/redux/pull/3751/files)。
