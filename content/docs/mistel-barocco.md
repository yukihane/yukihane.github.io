---
title: "Mistel Barocco"
date: 2020-07-24T00:37:41Z
draft: false
---

# Windows(Windows10)

## Windows10でUSキーボード設定を行う

`Windowsメニュー > 設定(ギアのアイコン) > 時刻と言語 > 地域と言語 > 日本語 > オプション > レイアウトを変更する`

でキーボードレイアウトを変更できる。

参考: [Windows10日本語版で英語配列キーボードを使用する - Qiita](http://qiita.com/shimizu14/items/000cceb9e72a492b9176)

## 日本語/英語 入力切り替え設定

1.  タスクバー右下のIMEアイコンを右クリックし プロパティ \> 詳細設定 を開く

2.  「編集操作」の「変更」を選択する

3.  \`Ctrl+SPACE\`の箇所に \`IME-オン/オフ\`を設定する

参考: [Windows10を英語配列キーボードで使っている人向け日本語入力切り替えの設定方法 - 三流SEの技術LOG](http://ko-log.net/archives/2561460.html)

# Barocco キーマップ変更(マクロ設定)

オフィシャルマニュアルは次のページより:

- [ノーマル版(英語配列)](http://www.archisite.co.jp/products/mistel/Barocco-en/)

- [RBG版(英語配列)](http://www.archisite.co.jp/products/mistel/Barocco-rgb-en/)

次のページは、マニュアルには書かれていない、経験で分かったことも書かれているので一読の価値あり。

- [Baroccoキーボード設定 (for Mac) - Qiita](http://qiita.com/khiri-co/items/2e509be9ad94f09b3be9)

- [ぼくのBAROCCO MD600キー配置 - Qiita](http://qiita.com/Takuan_Oishii/items/0f7a0d278980265b69a5)

## 工場出荷状態に戻す

`FN + R` を長押しで、LED2が白色で点滅。5秒後、選択中のレイヤーが工場出荷状態に戻ります。

## CapsLockをCtrlキーにする(通常のキーの設定変更方法)

1.  `FN + <` キーを押しLayer1に移動する。

2.  `FN + 右Ctrl` キーを押しプログラミングモードに入る。

3.  プログラムしたいキーである `左CapsLock` キーを押す

4.  プログラム内容を入力する。すなわちここでは `左Ctrl` キーを押す。

5.  `PN` キーを押しプログラム入力を完了する。

6.  `FN + 右Ctrl` キーを押しプログラミングモードを終了する。

## 左CtrlキーをFNキーにする

FNキー(及びPNキー)の変更はほかのキーとは異なり少し特殊な模様。詳細はマニュアル参照。

1.  `FN + 左Shift` キーを約3秒押し続ける。LED3が赤色で点滅する。

2.  いったん手を放し、再び変更するキーである `FN` キーを押す。

3.  変更先のキーである `左Ctrl` キーを押す。

FNキー(PNキーも)は1つのキーしか設定できないらしい。

# 自分の変更内容

- CapsLockをCtrlにする

- 左CtrlをFNキーにする

- 矢印キーをviの挙動と同様にする

  - hを左、jを下、kを上。(lはそのまま右)

- uをページダウン、iをページアップ、yをホーム、oをエンドに設定する

- 右スペースバーをEscに設定する
