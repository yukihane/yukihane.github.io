---
title: "herdrをWindowsで使う場合にはdefault_shellの設定をしよう"
date: 2026-09-05T20:38:28+09:00
tags: ["pwsh", "windows", "herdr"]
draft: false
---

最近WSLでなくWindowsネイティブでcodexなどを使うようになりました。
herdrをpwshで利用しているのですが、JSONをcatしたときに日本語が文字化けしているのに気づきました。

```pwsh
$PSVersionTable.PSVersion
```

を実行してみたところ `5.1` 系。古いな…？
と思い検索してみたところ、シェルを明示する必要があったようです。

```pwsh
notepad $env:APPDATA\herdr\config.toml
```

で設定ファイルを開き、

```toml
[terminal]
default_shell = "pwsh.exe"
```

を追記。
(なおpwsh自体はscoopでインストール済みでした)

そして一旦 `herdr server stop` で終了させた後、再度herdrを起動して上記のバージョン出力を試すと無事 `7.6` が表示されました。
 `cat hoge.json` 実行すると無事日本語が正常に出力されました。
