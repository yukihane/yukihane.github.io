---
title: "WindowsのpwshからCodexを更新するとGet-FileHashで失敗する"
date: 2026-09-17T23:36:33+09:00
tags: ["codex", "windows", "pwsh"]
draft: false
---

Windows ネイティブで Codex を使っていて `codex update` を実行したところ、次のように失敗しました。

```
iex : 用語 'Get-FileHash' は、コマンドレット、関数、スクリプト ファイル、または操作可能なプログラムの名前として認識されません。
```

更新処理は `powershell -ExecutionPolicy Bypass -c '...'` を実行しており、Codex CLI のダウンロード後に SHA-256 を検証するため `Get-FileHash` を呼び出しています。このため、これはダウンロード元への一時的な接続エラーそのものではなく、検証コマンドを実行できず更新を中断したエラーです。

## 原因

私は PowerShell 7 (`pwsh`) を普段のシェルとして使っていました。Codex の Windows 向け standalone updater は、親プロセスが `pwsh` であっても Windows PowerShell (`powershell.exe`, 5.1) を子プロセスとして起動します。

このとき `pwsh` 用の `PSModulePath` が子プロセスに引き継がれることがあります。Windows PowerShell 側ではモジュール探索が壊れ、通常は搭載されているはずの `Microsoft.PowerShell.Utility` 内の `Get-FileHash` を発見できなくなります。

同じ事象は Codex の Issue [Windows standalone update from pwsh inherits PSModulePath into powershell.exe, causing Get-FileHash to fail #27117](https://github.com/openai/codex/issues/27117) として報告されています。Issue に掲載されている環境では、`PSModulePath` を外して起動すると Windows PowerShell が Windows PowerShell 用のモジュールパスを再構築し、`Get-FileHash` が実行できています。

なお、`Get-FileHash` はダウンロードしたファイルのハッシュを計算するコマンドレットです。[Microsoft のドキュメント](https://learn.microsoft.com/ja-jp/powershell/module/microsoft.powershell.utility/get-filehash)にもあるとおり、ファイルが改変されていないことを確認する用途なので、検証を飛ばすような回避はしない方がよいです。

## 対処法

まずは Windows PowerShell を起動して、そこで更新を実行するのが簡単です。`pwsh` ではなく、スタートメニューの **Windows PowerShell** を起動するか、`Win + R` から次を実行します。

```
powershell.exe
```

開いた Windows PowerShell で更新します。

```
codex update
```

`pwsh` のターミナル内で完結させたい場合は、更新を実行する前に、そのセッションの `PSModulePath` だけを削除します。

```
Remove-Item Env:PSModulePath
codex update
```

これはユーザー環境変数やシステム環境変数を変更しません。一時的に起動中の `pwsh` とその子プロセスから `PSModulePath` を外すだけです。更新が終わったらターミナルを閉じて開き直せば元の環境に戻ります。

更新前に原因を確認したい場合は、`pwsh` から次を実行します。`Get-FileHash` が見つからなければ今回の問題に該当します。

```
powershell.exe -NoProfile -Command "Get-Command Get-FileHash"
```

上記を実行しても Windows PowerShell 単体で `Get-FileHash` が見つからない場合は、`PSModulePath` の継承ではなく PowerShell / Windows 側の環境に問題があります。通常の Windows 10 / 11 に含まれる Windows PowerShell 5.1 では利用できるはずなので、PowerShell のバージョンとモジュールパスを確認します。

```
$PSVersionTable.PSVersion
$env:PSModulePath
```

## 補足

Codex の公式 README では、Windows の standalone installer は既定で `releases.openai.com` から取得し、利用できない場合は GitHub Releases にフォールバックすると説明されています。エラーログ中の「GitHub Releases から再試行」はこの挙動であり、今回の本体はその後の `Get-FileHash` エラーでした。

公式には npm 経由のインストールも案内されているため、standalone installer の問題を避けたい場合は、Node.js を使う運用に切り替える選択肢もあります。ただし、既存の standalone 版との共存でどちらの `codex` が実行されるか分かりにくくなるため、まずは上記の回避策で standalone 版を更新することにしました。

- [Codex CLI README](https://github.com/openai/codex#installing-and-running-codex-cli)
