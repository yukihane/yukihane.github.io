---
title: "Kubernetes the hard way を最新版の1.18.2でやってみた"
date: 2020-04-26T13:00:50Z
draft: false
tags:
  - kubernetes
---

# 要約

`kube-apiserver` の起動引数を `--runtime-config=api/all=true` に修正すれば v1.18.2 でも記述どおりで動作する。

# 本文

現時点で本家 [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) は1.15.3をターゲットにして構築を行っていますが、せっかくなので最新版である v1.18.2 でやってみることにしました。

結果、1点を除いて記述されているままで構築完了までもっていくことができました。

問題があった1点とは、 [マスターコンポーネント](https://kubernetes.io/ja/docs/concepts/overview/components/#%E3%83%9E%E3%82%B9%E3%82%BF%E3%83%BC%E3%82%B3%E3%83%B3%E3%83%9D%E3%83%BC%E3%83%8D%E3%83%B3%E3%83%88) のうちのひとつ、 [kube-apiserver](https://kubernetes.io/ja/docs/concepts/overview/components/#kube-apiserver) の起動オプションです。

Bootstrapping the Kubernetes Control Plane 章の [Configure the Kubernetes API Server](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/5c462220b7f2c03b4b699e89680d0cc007a76f91/docs/08-bootstrapping-kubernetes-controllers.md#configure-the-kubernetes-api-server)セクションで `kube-apiserver.service` ファイルを作成していますが、その中のコマンド引数 `--runtime-config=api/all` に問題がありました。

このコマンドをそのまま実行すると、

> Error: invalid value api/all=

というエラーが `/var/log/syslog` に出力され、プロセスが終了してしまいます。

[現在のドキュメント](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/) では設定すべき値がわかりやすく書き直されていますが、正しくは **`--runtime-config=api/all=true`** です。

これについては、既にIssuesに登録されていました:

- [This was required before the apiserver would come up with v1.17.0 \#535](https://github.com/kelseyhightower/kubernetes-the-hard-way/pull/535)

作業中の気づいた点などは直接ドキュメントに書き込んでいきました。 というわけで作業ログはこちらになります:

- <https://github.com/yukihane/kubernetes-the-hard-way/compare/5c462220b7f2c03b4b699e89680d0cc007a76f91..master>
