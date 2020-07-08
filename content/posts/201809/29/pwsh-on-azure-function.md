---
title: Azure FunctionsでPowerShell使えなくなっとる
date: 2018-09-29T19:51:56Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [azure]
# images: []
# videos: []
# audio: []
draft: false
---

v1 で実験的サポートだった PowerShell が、実行環境のバージョンが上がったとかで v2 になり、選べなくなっているみたい？一時的な話？

# 実行環境を作る

https://portal.azure.com/ から 「リソースの作成」「Serverless Function App」と選択していきます。

![functions01.png](https://qiita-image-store.s3.amazonaws.com/0/85594/832a26fb-6420-c0b8-75ae-fc2a92045c13.png)

入力項目を適当に埋めていきます。PowerShell で作りたいので当然ながら[^1]OS は「Windows」、ランタイムスタックは「.NET」。
Application Insights は何かよく分からないのでオフ
にしました。

[^1]: いや AWS Lambda の PowerShell(Core)環境は Amazon Linux なので当然ということでもないか。

![functions02.png](https://qiita-image-store.s3.amazonaws.com/0/85594/4219d384-eb5b-face-e53e-74ad6a02b15d.png)

入力を終え画面下部の「作成」ボタンを押すとデプロイ作業が始まり、少し待たされます。
デプロイ作業が完了すると通知が表示されます。その通知からも行けますし、そうでない場合は画面左の「Function App」メニューから関数作成ウィザードに行けます。
「関数」ツリーメニューの右にあるプラスアイコンをクリックし、その次に今回作りたいプロジェクトのひな型を選びます。
今回は「In-portal」を選択しました。
選択が完了したら画面下部の「続行」ボタンを押します。

![functions03.png](https://qiita-image-store.s3.amazonaws.com/0/85594/f5c59661-29d9-526b-99e4-56ce8f76b68c.png)

今回タイマー駆動の処理が行いたいので「タイマー」を選択し、その後画面下部の「作成」ボタンを押します。

![functions04.png](https://qiita-image-store.s3.amazonaws.com/0/85594/4e866cba-1977-dd9f-385e-010337c1321b.png)

すると…めでたく C#の関数が生成されました！

![functions05.png](https://qiita-image-store.s3.amazonaws.com/0/85594/40b97c1e-5d2c-0157-c1d8-c067662768f3.png)

ってなんでやねん！PowerShell で作りたい言うとるやろ！言語選ばせろや 💢

# 作成した実行環境の設定を変更する

## ランタイムバージョンを変更する

現在デフォルトのランタイムバージョンが 2 なので 1 に下げます。PowerShell は今のところバージョン 1 でしか選択できません。

まず、先ほど作成した関数を削除します。残したままだと設定変更できません。

ツリーメニュー上で、作成した関数名の 1 つ上の階層「関数」メニューを選択し、表れた関数名一覧の右端にあるごみ箱アイコンを選択し削除実行します。

![functions06.png](https://qiita-image-store.s3.amazonaws.com/0/85594/0e5b87a0-dff0-d7df-dde6-5874c88ca6af.png)

つづいて、先ほど選択した関数メニューの更に 1 階層上、<app 名>(ここでは hello-azure-functionz)を選択し、右側の表示「プラットフォーム機能」タブがアクティブであることを確認します。
そのタブ表示の中から、「Function App の設置」を選択します。

![functions07.png](https://qiita-image-store.s3.amazonaws.com/0/85594/303fc5ac-2191-ccc4-383d-7c84afadd926.png)

「ランタイムバージョン」が「~2」になっているので、これを **「~1」に変更します**。

![functions08.png](https://qiita-image-store.s3.amazonaws.com/0/85594/3d380c06-ace5-4dc2-fe75-dbbab5e470d6.png)

## アプリケーション設定 FUNCTIONS_WORKER_RUNTIME を削除する

本来であれば、ここまでの設定を行えば v1 がサポートしている言語が使えて然るべきだと思うのですが、まだ PowerShell がウィザードに表れません。

そこで次に説明する設定変更を行います。
さきほどの「プラットフォーム機能」タブに戻り、今度は「アプリケーション設定」を選択します。

![functions09.png](https://qiita-image-store.s3.amazonaws.com/0/85594/b75dbb1c-057c-8c48-2eed-20b6430c1d39.png)

開いたタブを少し下にスクロールし、「アプリケーション設定」セクションを探します。
この中で「**FUNCTIONS_WORKER_RUNTIME**」というアプリ設定名がありますので、これを削除します。

![functions10.png](https://qiita-image-store.s3.amazonaws.com/0/85594/527a38f5-4a83-2bef-9688-f9152a7ea420.png)

そして、その画面の上部にある「保存」アイコンを選択し変更を反映してください。

設定は以上です。

# PowerShell 関数を作成してみる

PowerShell 関数を作成できるようになっていることを確認してみましょう。

関数を新規作成するために、「関数」メニュー右のプラスアイコンを選択します。
そうすると、設定変更作業前とは異なる画面が表示されます。

ここで「カスタム関数を作成する」を選択します。

![functions11.png](https://qiita-image-store.s3.amazonaws.com/0/85594/8266638a-a227-c827-6b9f-ddfd4586582c.png)

次の画面で、「実験的な言語のサポート」を有効にすれば選択肢に PowerShell が表れます。
ここでは「Timer trigger」を選択します。

![functions12.png](https://qiita-image-store.s3.amazonaws.com/0/85594/a57aa37c-644f-6cd6-9c67-c6bcee817232.png)

言語で「PowerShell」を選択し、あとは適当に入力して「作成」を押せば関数作成完了です。

![functions13.png](https://qiita-image-store.s3.amazonaws.com/0/85594/c3449ddf-c714-7819-d550-66f3a2624bb1.png)

# 参考

- [unable to create a python function app in azure function runtime v1 - Stack Overflow](https://stackoverflow.com/a/52523654/4506703)
