---
title: "ReduxのFundamentalsにTypeScriptで型を付けただけ(2021年版)"
date: 2021-07-28T16:14:18Z
draft: true
tags:
  - react
  - redux
---

[ReduxのBasic TutorialにTypeScriptで型を付けただけ]({{< relref"blog/202004/15/redux-basic-tutorial" >}})の最新版です。

当時は "Basic Tutorial" という名前の章がありましたが、少し古なっておりリライト作業の最中でした。 その時の成果が今回の "Fundamentals" だと思います。

[Tutorials Index](https://redux.js.org/tutorials/index) にもある通り、現在はトップダウンで説明している [Redux Essentials tutorial](https://redux.js.org/tutorials/essentials/part-1-overview-concepts) と、 ボトムアップで説明している [Redux Fundamentals tutorial](https://redux.js.org/tutorials/fundamentals/part-1-overview) の2つの章からなるようです。

また、TypeScriptに対するサポートも厚くなっているようで、今からやろうとしている表題のことは、実は公式ドキュメント内で網羅されている可能性も有ります(この文章、作業を始める前に書いています)。

- [テンプレート(`cra-template-redux-typescript`)](https://github.com/reduxjs/cra-template-redux-typescript)が既に用意されているのではじめから組み込む場合はこれを使えば良い

  - `redux-toolkit` も組み込み済みの模様。 `@types/react-redux` も入っている。

- 後から追加する場合は `yarn add react-redux @reduxjs/toolkit`
