---
title: "「簡単アニメキャラ抜き出しアプリ」をWSL2 Docker環境で動かす"
date: 2025-06-01T21:22:10+09:00
tags: ["ai"]
draft: false
---

- [【夏休み自由研究】実例で学ぶ画像処理【Python】 | 東京科学大学デジタル創作同好会tra](https://trap.jp/post/1362/)

という記事をたまたま読み、「そういえばひと昔前、アニメ絵の顔検出流行ってたなあ。今どうなってるんだろう」というのが気になって少し調べてみました。

- [レガシーAIシリーズ（１）　高精度アニメ顔検出｜めぐチャンネル](https://note.com/ai_meg/n/n3cbc258dfa3e)

という1年ほど前に作成された記事によると、冒頭の記事でも利用されている [nagadomi/lbpcascade_animeface](https://github.com/nagadomi/lbpcascade_animeface) が長らく使われてきたらしく、私が記憶している当時からそんなに変化は無かったようです。

そのような背景の中、この記事ではより精度の高いアニメ顔検出機構 [animede/anime_face_detection](https://github.com/animede/anime_face_detection) を提案しています。

また、後続の記事

- [レガシーAIシリーズ（２）　簡単アニメキャラ抜き出しアプリ｜めぐチャンネル](https://note.com/ai_meg/n/n7e02b5ac878c)

では、前出の顔検出を基にしたキャラ配置、背景削除、超解像画像拡大機能を組み合わせた [animede/anime-crop](https://github.com/animede/anime-crop) が提案されています。

お、これを使えば冒頭の記事にあるドーナドーナの自作ジンザイ作成処理についてもっと汎用化できるのでは、と考えましたので実際どんな感じなのか動かしてみることにしました。

作った環境がこちらです:

- https://github.com/yukihane/docker-anime-crop

元記事では

> リアルタイム性を要求しないアプリなので**GPU無しで動かすことが可能**です。

とあるのですが、実際に動かしてみると、(おそらく)Real-ESRGANを用いたアップスケール処理が走る条件だと処理が終わらないので、GPUを利用する方式をmainブランチで実装しています。

検証環境は次の通りです:

- WSL2 Ubutnu on Windows11
- NVIDIA GeForce RTX 3070
- NVIDIA-SMI 575.57.04, Driver Version: 576.52, CUDA Version: 12.9

検証画像としてpixivにアップロードされている著作物を利用したのですが、改めて見渡してみると解像度が高い画像が多く、アップスケール機能が無くても問題ない状況が大半なのではと考え、アップスケール機能をomit(アップスケールが発生する状況では"image is too small"というログを出力しエラーにする)したGPU無しのモードも作ってみました。
詳細はREADMEを参照してみて下さい。
