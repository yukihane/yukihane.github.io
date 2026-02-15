---
title: "Restful API, path を使うか query を使うか"
date: 2020-08-23T17:24:37Z
draft: false
tags:
  - web
  - rest
---

特に結論はなく、情報収集です。

> Google の検索 URI「http://www.google.com/search?q=jellyfish」について考えてみよう。Google Web アプリケーションがパス変数を使用していたならば、この URI はアルゴリズムの実行結果というよりも、ディレクトリのようになっていただろう（http://www.google.com/search/jellyfish）。
>
> これらの URI はどちらも「クラゲに関する Web ページのディレクトリ」リソースに対する正当なリソース指向の名前である。私たちは URI を調べる方法に順応してしまっているので、2 つ目の URI は正しくないように見える。パス変数は階層をトラバースしているように見えるし、クエリ変数はアルゴリズムに引数を渡しているように見える。「検索」にはアルゴリズムのような響きがある。たとえば、 http://www.google.com/directory/jellyfish は/search/jellyfish よりもよさそうに思える。
>
> クエリ変数に対するこの認識は、私たちが Web を使用するたびに強化される。Web ブラウザで HTML フォームに入力しているとき、入力したデータはクエリ変数になる。「クラゲ」をフォームに入力して、 http://www.google.com/search/jellyfish に送信する方法はない。HTML フォームの送信先は http://www.google.com/searchに ハードコーディングされているので、そのフォームに入力すると、 http://www.google.com/search?q=jellyfish になる。ブラウザはクエリ変数をベースURI に追加する方法を知っている。だが、変数を http://www.google.com/search/{q}のような汎用URI に置き換える方法は知らない。
>
> —  [RESTful Webサービス](https://www.oreilly.co.jp/books/9784873113531/) - 5.5.3 アルゴリズムリソースに対するクエリ変数の使用

> When should we use the query string?
>
> (snip) the main use-case of the query string is filtering and specifically two special cases of filtering: searching and pagination.
>
> —  [REST API Design Best Practices for Parameter and Query String Usage](https://www.moesif.com/blog/technical/api-design/REST-API-Design-Best-Practices-for-Parameters-and-Query-String-Usage/)
