---
title: "GwtCon2017"
date: 2020-07-26T02:34:19Z
draft: false
---

# スライド要旨

[GwtCon2017のスライド](http://www.gwtcon.org/#slides)を簡単にまとめます。

## [Present and Future of GWT from a developer perspective](https://es.slideshare.net/dodotis/present-and-future-of-gwt-from-a-developer-perspective)

既に陳腐化した(使うべきでない)GWT要素技術の紹介。代替方法は何か。これからはどう作るべきか。 20108/01時点で、最新の情報が反映され、まとまっている資料は他にはない。必読。

Generator, Widget, Element, JavaScriptObject, RPC, RequestFactory, AutoBeans, UiBinder(Widgetを使ったUiBinder方式のことと思われる), JSNI, Classic DevMode, Ant, Designer は Obsolate Stuff。

## 古いの

- [The future of GWT 2.x - By Colin Alworth](https://www.slideshare.net/gwtcon/the-future-of-gwt-2x-by-colin-alworth)

  - GWT2.8.2, 2.9, 2.10, 3について

- [DIY: Split GWT Applications using TURDUCKEN approach By Alberto Mancini](https://www.slideshare.net/gwtcon/diy-split-gwt-applications-using-turducken-approach-by-alberto-mancini)

  - 大きなアプリケーションは複数のGWTモジュールに分割する(この手法をhttps://www.slideshare.net/RobertKeane1/turducken-divide-and-conquer-large-gwt-apps-with-multiple-teams\[TURDUCKEN\]パターンと呼ぶ)。

  - モジュール間のコミュニケーションについて、サービスメッセージはhttps://developer.mozilla.org/ja/docs/Web/API/Window/postMessage\[window.postMessage\]を、それ以外のビジネスメッセージなどはhttps://developer.mozilla.org/ja/docs/Web/API/MessageChannel\[channel messaging\]を使えばうまくいった。
