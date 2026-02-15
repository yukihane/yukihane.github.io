---
title: "GKE(Goole Kubernetes Engine)の始め方"
date: 2020-04-26T14:05:12Z
draft: false
tags:
  - kubernetes
---

Kubernetes入門の書籍やドキュメントの中には、Kubernetes環境が既に手元にある前提で書かれているものも多いです。

そういう場合、どうやってKubernetes環境を調達して良いのかわからず、一つの手段として自前で環境を作る [Kubernetes the hard way](https://yukihane.github.io/posts/202004/26/kubernetes-the-hard-way-v1.18.2/) をやってみたのですが、一旦環境を作ってしまうとインスタンスを起動させ続けねばならず(作り直すの面倒だし)、財布に優しくないので断念しました。

代わりに、表題のKubernetesマネージド環境であるところのGKEを利用することにしました。初回の3万円無料枠で利用可能です。

ドキュメントはここですね:

- <https://cloud.google.com/kubernetes-engine/docs/how-to?hl=ja>

「単一ゾーンクラスタの作成」を読めば良いでしょう。

katacodaのplaygroundは完全無料で試すことができます。レスポンスは少し遅いです。

- <https://www.katacoda.com/courses/kubernetes/playground>
