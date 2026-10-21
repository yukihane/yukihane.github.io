---
title: "Firefoxを起動しているとWindows11がスリープしない"
date: 2026-10-21T19:22:15+09:00
tags: ["windows", "firefox"]
draft: false
---

最近、Windowsがスリープしていないことに気づきました。
ウェブブラウザーで動画コンテンツ(YouTubeとか)を開きっぱなしにしているとそうなってしまうのでそれと混同していたのですが、どうもそれ以外にも原因があるようでした。

## 状況

pwshコンソールを管理者権限で開きます。そこで次のコマンドを実行して現状を確認します:

```
powercfg /requests
```

すると次のような出力が出ます:

```
DISPLAY:
なし。

SYSTEM:
なし。

AWAYMODE:
なし。

実行:
なし。

PERFBOOST:
なし。

ACTIVELOCKSCREEN:
なし。
```

https:/x.com/ でログインして、画面をスクロールします。その後、上記のコマンドを再実行してみると次の出力に変わります(変化が無いところは省略):

```
SYSTEM:
[DRIVER] High Definition Audio Device (HDAUDIO\FUNC_01&VEN_10EC&DEV_0892&SUBSYS_18497893&REV_1003\5&2a972a77&0&0001)
現在 1 つのオーディオ ストリームが使用中です。
```

何かメディアが画面に表示されたりしているのならまだわかるのですが、特に動画埋め込みファイルなどが表れていなくてもなぜか上記のようになります。
ちなみに似たような事象がbugzillaに登録されているようでした:
- [x.com causes audio interface to be opened (with PipeWire) despite nothing being played](https://bugzilla.mozilla.org/show_bug.cgi?id=1984881)
- [Twitter/X won't let PC enter sleep mode](https://bugzilla.mozilla.org/show_bug.cgi?id=1983044)

そして、この状態でWindowsを放置するとスリープが阻害されます。

## 効果があった対処法

- 上記の状態は、Windowsに付属しているMicrosoft製の標準オーディオドライバーが使われています。代わりに、マザーボードメーカーのサイトから取得できる、メーカー純正のオーディオドライバーをインストールし、再起動します
    - 私のPCのマザーボードはAsrock B450 Steel Legendなので[こちら](https://www.asrock.com/mb/AMD/B450M%20Steel%20Legend/index.jp.asp#Download)から入手しました。
- 管理者権限のpwshで次のコマンドを実行します:
    ````
    powercfg /requestsoverride DRIVER "Realtek High Definition Audio" SYSTEM
    ````
    - このコマンドは、RealtekのオーディオドライバーがWindowsに対して「PCをスリープさせないでほしい」と要求していても、その要求を無視して自動スリープできるようにする設定です
        - なので、Realtek社製の物でない場合は別のコマンドになります。いまならAIに聞けば調べ方は簡単に教えてくれると思います

少し詰まった点としては、Microsoft製ドライバーを使っている状態で、上記のスリープ阻止要求を無視する設定を行っても無視されずにスリープが阻止されてしまうところです。
これが私の環境だけの話なのか一般的な話なのかは分かりませんが。

## まとめ

- FirefoxがなぜかXを開く(&スクロールする)だけでオーディオストリームを要求する
- その状態だとスリープが阻害される
- スリープ阻止要求を無視する設定を行っても、MS純正ドライバーだと効果が無い
- サウンドチップメーカー純正ドライバーをインストールすれば無視されずにスリープに入るようになった
