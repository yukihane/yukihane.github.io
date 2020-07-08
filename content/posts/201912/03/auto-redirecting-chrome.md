---
title: "https://hatena.ne.jp/ にアクセスできてるとお思いで？"
date: 2019-12-03T20:39:39Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [web, chrome]
# images: []
# videos: []
# audio: []
draft: false
---

# はじめに: 試した環境

Windows10 の現時点での最新安定版 Google Chrome および Firefox を用いました。

- Google Chrome 78.0.3904.108
- Firefox 70.0.1

また実行に際しては、キャッシュ等の影響を避けるため、Chrome では[ゲストモード](https://support.google.com/chrome/answer/6130773?co=GENIE.Platform%3DDesktop&hl=ja)、Firefox では今回[新規作成したプロファイル](https://support.mozilla.org/ja/kb/profile-manager-create-and-remove-firefox-profiles#w_cucgciaaacceagluna)で確認しました。

# やってみよう

Google Chrome の URL バー(Omnibar)に https://hatena.ne.jp/ と入力してエンターを押してみよう！

![01hatenatop.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/85594/5cba0dec-7211-e5ab-41e8-1d4093413617.png)

トップページが表示されましたか？

## あちゃー！😣 表示されちゃいましたか！😵

それでは次に Firefox で同じことをやってみます。

![02firefox.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/85594/d457f05a-0f38-2e09-11eb-12c2bca63099.png)

## あれ ❔Chrome と Firefox で表示されてるものが違うんですけど ❔❔🤔🤔 どっちが正しいの ❔❔❔😟😟😟

あっあれだ。Google が URL を殺すって言ってたやつだ。Omnibar に殺された URL を掘り返してみれば何かわかるかも！！！(Omnibar のクリックを繰り返しつつ)

![03www.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/85594/c951823e-9150-e9eb-131c-9ac1be98b085.png)

はい出たーやっぱりねー `https://www.` 隠れてたーそら Firefox と違う URL なんだから違う内容表示されるわー

## ってなんで入力した URL と違うページ表示してんねん

いやいやおつちけそれこそよくある`302`でリダイレクトさせてるやつやろあれでもじゃあ Firefox がリダイレクトされてないのはなんでなんだ

## そうだ DevTools、行こう

はい `302` が出て…

![04devtools.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/85594/a570d777-2b28-6a87-70ba-7af31c6b45e9.png)

## なーい！なんや "(failed)" て！

(余白)

# 解決編

いやまあ、DevTools の console を見ればわかることなんですけれども。

> Redirecting navigation hatena.ne.jp -> www.hatena.ne.jp because the server presented a certificate valid for www.hatena.ne.jp but not for hatena.ne.jp. To disable such redirects launch Chrome with the following flag: --disable-features=SSLCommonNameMismatchHandling

関連する issue は多分これ:

- [Issue 507454: Implement Redirect for the WWW Subdomain Mismatch case](https://bugs.chromium.org/p/chromium/issues/detail?id=507454)

証明書見てサブドメイン違うかったら勝手に証明書に書いてある方にリダイレクトするよ、という挙動みたいです。

`--disable-features=SSLCommonNameMismatchHandling` 付けて起動すると Firefox と同じ挙動になります。

![05chromeerror.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/85594/9420ef92-a907-706d-e116-9839871ef908.png)

# まとめ

Google Chrome は、

- Omnibar がサブドメインを隠す
- サブドメイン間違ってたら勝手リダイレクトする

という仕様のコンボで、思ってた URL と違うものを表示していることがあります。
