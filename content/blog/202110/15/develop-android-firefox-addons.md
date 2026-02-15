---
title: "Android Firefox Webextensions 開発/デバッグ覚え書き"
date: 2021-10-15T16:36:00+09:00
draft: false
tags:
  - android
  - webextensions
  - firefox
---

- HAXM を有効化するためには [今でも Hyper-V を無効化しておく必要があるらしい](https://github.com/intel/haxm/wiki/Installation-Instructions-on-Windows?utm_source=pocket_mylist#tips-and-tricks)です。つまり Android 開発と WSL2 は両立できないということに。

  - 私は最初 Hyper-V 有効か状態で開発環境インストールを進めたのですが、やはりインストール失敗しました。

- 最初コマンドラインツール(`sdkmanager`)だけインストールしようとしたものの、どこからダウンロードすればいいのか分からなかったのですが、 [Android Studio のダウンロードページ](https://developer.android.com/studio)にリンクがありました([Command line tools only](https://developer.android.com/studio#span-idcommand-toolsa-namecmdline-toolsacommand-line-tools-onlyspan))。

  - …ですが結局面倒くさくなって All-in-One でインストールしてくれる Android Studio をインストールすることでセットアップを済ませてしまいましたｗ

- `adb` コマンドは `%LOCALAPPDATA%\Android\sdk\platform-tools` にインストールされていました(参照: [Where is adb.exe in windows 10 located? - Stack Overflow](https://stackoverflow.com/a/35854344))。

- **開発手順はこちら: [Developing extensions for Firefox for Android - Firefox Extension Workshop](https://extensionworkshop.com/documentation/develop/developing-extensions-for-firefox-for-android/)**

  - `web-ext` コマンド引数に `--firefox-apk org.mozilla.fenix` を指定していますが、通常の Firefox を対象にする場合は `--firefox-apk org.mozilla.firefox`, beta版の場合は `--firefox-apk org.mozilla.firefox_beta` を指定すればよかったです。

    - Firefox を Google Play ストアからインストールのが面倒だったので(Google アカウントでログインする必要がある)、 [GitHub のリリースページ](https://github.com/mozilla-mobile/fenix/releases)から `apk` をダウンロードしてインストールしました。
