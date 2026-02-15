---
title: "WSL2上のGUIアプリケーションを動かす"
date: 2022-04-16T17:56:11+09:00
draft: false
tags:
  - windows
  - wsl
  - tauri
---

[Tauri]({{< relref"/blog/202110/03/hello-tauri" >}}) の開発環境を Windows10 の WSL2 に移行するために、 WSL2 上の GUI アプリを Windows で表示するようにセットアップしました。

とは言いつつ、既に次の手順でセットアップしたことがあるので、今回はこれが動くかどうかを確認しただけですが。

- [npx playwright codegen wikipedia.org を実行してもブラウザが開かない - スタック・オーバーフロー](https://ja.stackoverflow.com/a/83575/2808)

ちなみに、 Windows11 の場合は公式のドキュメントに手順が存在するようです。

- [WSL で Linux GUI アプリを実行する \| Microsoft Doc](https://docs.microsoft.com/ja-jp/windows/wsl/tutorials/gui-apps)

Windows側の初期設定:

1.  [VcXsrv](https://sourceforge.net/projects/vcxsrv/) をインストールします (補足: 私は [`scoop`](https://github.com/ScoopInstaller/Extras/blob/master/bucket/vcxsrv.json) でインストールしました )

2.  `XLauncher`(`xlaunch.exe`) を起動し、次の設定を行います:

3.  "Multiple windows" をチェック

4.  "Start no client" をチェック

5.  "Native opengl" のチェックを外す、**"Disable access control" をチェック**(重要)

6.  "Save configuration" で設定を保存

7.  "完了" を押すと上記の設定で起動します

8.  (`xlaunch.exe` のショートカットを作成して引数に `-ac -run <設定ファイル>` を設定しておくと、次回起動はこのショートカットから行えます([参考](https://sourceforge.net/p/vcxsrv/wiki/Using%20VcXsrv%20Windows%20X%20Server/)))

Ubuntu側の初期設定:

1.  `~/.bashrc` に次を追記:

        export DISPLAY=$(route.exe print | grep 0.0.0.0 | head -1 | awk '{print $4}'):0.0

2.  `source ~/.bashrc` で上の設定を読み込み

参考:

- [Can’t use X-Server in WSL 2 \#4106](https://github.com/microsoft/WSL/issues/4106#issuecomment-917564903)

WSL2 に Google Chrome をインストール方法は、前述の [Windows11 向け公式ドキュメント](https://docs.microsoft.com/ja-jp/windows/wsl/tutorials/gui-apps#install-google-chrome-for-linux) に記載があります。

    cd /tmp
    curl -L -O https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb
    sudo apt install --fix-broken -y
    sudo dpkg -i google-chrome-stable_current_amd64.deb

`google-chrome &` コマンドで、 WSL2 上の Google Chrome が起動します。
