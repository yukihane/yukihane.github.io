---
title: Electronでfs(File IO)
date: 2020-04-22T20:59:12Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [js, electron]
# images: []
# videos: []
# audio: []
draft: false
---

- [Electron で File の Open と Save - Qiita](https://qiita.com/zaburo/items/eb525138b88890c5357c)

を写経させてもらっていますが、、、動かない。
リンク先では Electron v4.x を利用していますが現在の最新版は [v8.2.3](https://www.electronjs.org/releases/stable#release-notes-for-v823)。このバージョン差異が原因のようでした。

# 問題

## 1. Uncaught ReferenceError: require is not defined

v8.2.3 でそのまま実行すると、表題のエラーが出ています。
[v5.0.0](https://www.electronjs.org/releases/stable?version=5&page=3#release-notes-for-v500)([#16235](https://github.com/electron/electron/pull/16235))より `nodeIntegration` 設定のデフォルト値が `false` に変わったためのようです。

セキュリティ上の懸念がある場合は[このへん](https://stackoverflow.com/q/52451675/4506703)に書いてあることを行うのかなと思いますがよくわからない&今回はローカルアプリなので問題ないので単に `nodeIntegration` を `true` にしました([参考ドキュメント](https://www.electronjs.org/docs/api/browser-window#class-browserwindow))。

https://github.com/yukihane/hello-js/commit/18b7d2c01aef737792748ffe788a6cb67f68c897

## 2. Open/Save ボタンを押してファイル選択しても想定通り機能しない

Open ボタンを押してファイル選択ダイアログでファイルを選択すると、その内容をテキストエリアに表示する、というのが想定された動作のはずですが、何も起こりません。

[`dialog.showOpenDialog`メソッドの仕様](https://www.electronjs.org/docs/api/dialog#dialogshowopendialogbrowserwindow-options)が変わっており、 [v5.x までは引数にコールバック関数を採っていた](https://github.com/electron/electron/blob/v5.0.13/docs/api/dialog.md#dialogshowsavedialogbrowserwindow-options-callback)が、v6 より Promise を戻り値に採るようになったようです([#16973](https://github.com/electron/electron/pull/16973))。

https://github.com/yukihane/hello-js/commit/93d429089a6782283ce9d4738c9e7f150abf757f

しかしエラーも吐かずに単に動かなくなるって、JavaScript ってすげーな(褒めてない)。

## 3. Save ボタンを押しても保存できない

上記対応を行うと Save ボタンを押した際にファイルは作成されるようになりましたが中身が空です。また 2 回目以降の Open ボタンも機能しているように見えません。

- [HTMLTextAreaElement - Web API | MDN](https://developer.mozilla.org/ja/docs/Web/API/HTMLTextAreaElement)

を見ると `textContent` でなく `value` プロパティを用いるのが適切に思われます。
(この辺 HTML 童貞なので何が正解かわからない…)

https://github.com/yukihane/hello-js/commit/57c1996adc57a6f4dee9790d1825b65cbbe1835c

# 解決

https://github.com/yukihane/hello-js/tree/master/electron/file-io-example

全体差分: https://github.com/yukihane/hello-js/compare/77e72d9..57c1996
