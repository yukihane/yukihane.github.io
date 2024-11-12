---
title: "Stable Diffusion Installation on Windows11"
date: 2024-11-12T21:16:11+09:00
draft: false
tags: ["ai", "windows"]
---

Windows11へStable Diffusionをインストールしたときの作業ログです。

## 簡単に

現時点では [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui) というパッケージが最もメジャーな様なので、このREADMEに従ってインストールを進めることにしました。
(webuiという名前なので別途本体のインストールが必要なのかと思いましたが、all-in-oneなパッケージのようです)

いくつか詰まった点もあったのでそれらも記録しています。

## 作業ログ

READMEの [Automatic Installation on Windows](https://github.com/AUTOMATIC1111/stable-diffusion-webui/tree/82a973c04367123ae98bd9abdf80d9eda9b910e2?tab=readme-ov-file#automatic-installation-on-windows) の記述に従います。
(注: 上記リンクは私が参照した時点の最新コミット)

### Python インストール

WindowsでPythonのバージョン管理は [pyenv-win](https://github.com/pyenv-win/pyenv-win) が主流な様なのでこれをインストールします。

初めはscoopでインストールしたのですが不具合がありPythonインストールに失敗するので、scoopからはアンインストールし [pyenv-winのREADMEl](https://github.com/pyenv-win/pyenv-win?tab=readme-ov-file#quick-start) に書かれている PowerShellでのインストール法で実施しました。

- ref: [scoop-installed pyenv install fails with 'error installing "core" component MSI' #449](https://github.com/pyenv-win/pyenv-win/issues/449)

Pythonのバージョンは `3.10.6` を使えとREADMEにあるので、このバージョンをインストールします:
```bash
pyenv update
pyenv install 3.10.6
```

デフォルトの `python` コマンドが利用されるのを停止します。READMEにある次の文章に相当する作業です:
> NOTE: If you are running Windows 10 1905 or newer, you might need to disable the built-in Python launcher via Start > "Manage App Execution Aliases" and turning off the "App Installer" aliases for Python

スタートメニューから「アプリ実行エイリアスの管理」を選択し、表示されたリストから次の項目をオフにします:
- アプリ インストーラー python.exe
- アプリ インストーラー python3.exe

### git clone

Gitはインストール済み。
Git Bash上で作業します。
stable-diffusion-webui リポジトリーをclone:

```bash
git clone git@github.com:AUTOMATIC1111/stable-diffusion-webui.git
```

### Python呼び出し方法編集

```bash
cd stable-diffusion-webui
pyenv local 3.10.6
python -V # バージョン確認
```
利用したいバージョンの `python` が使われることを確認したら、 `webui-user.bat` を次の通り編集します:
```diff
diff --git a/webui-user.bat b/webui-user.bat
index e5a257be..0ce2cfd4 100644
--- a/webui-user.bat
+++ b/webui-user.bat
@@ -1,6 +1,6 @@
 @echo off
 
-set PYTHON=
+set PYTHON=call python
 set GIT=
 set VENV_DIR=
 set COMMANDLINE_ARGS=
```

- ref: [\[Bug\]: Calling webui-user.bat hangs because python commands are not called with 'call' statement #16205](https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/16205#issuecomment-2250949619)

### 実行

上で編集した `webui-user.bat` をダブルクリック(あるいは右クリック > 開く)で実行します。

正しく設定が行えていればダウンロード処理などが始まります。

ダウンロードが終わればウェブブラウザーが起動し http://127.0.0.1:7860/ が開かれました。
