---
title: "WSL2でWindows Terminalがクラッシュするので利用をやめた"
date: 2026-02-15T15:27:13+09:00
tags: ["windows", "wsl"]
draft: false
---

- [Windows Terminalで日本語入力中 頻繁にクラッシュする]({{< ref "blog/202511/03/windows-terminal-crash/" >}})

でも書きましたが、Windows Terminalが旧MSIMEを使っていると頻繁にクラッシュして困ったので新しいMSIMEを使うことにしました。
しかし、新しいMSIMEだとShift+Spaceで日英入力切替ができないのでAutoHotKeyを利用して解決を図りました。

- [Windows11でShift+Spaceで日本語/英語切り替えを行えるようにする]({{< ref "blog/202511/03/shift_space_with_autohotkey/" >}})

一応これで解決はしたのですが、[Copilot Keyboard](https://blogs.windows.com/japan/2026/01/20/copilot-keyboard-japanese-input/)があるということを最近知りました。

- 新しいアプリケーションなのでWindows Terminalとの相性は良いのではないか
- Shift+Spaceの日英入力切替に標準で対応している
- Macのように、変換・無変換キーで日本語・英語入力切替の設定ができる
  - 最近キーボードを変えたのでこちらのボタンを使うようにしている

ということで、AutoHotKeyのように変化球を使わなくてもクラッシュ問題が解消するのでは、と使ってみました。

結果。
旧MSIMEよりはクラッシュ頻度は下がったように思うのですが、ゼロではありませんでした。

そんななか、逆にWindows Terminalをやめればよいじゃないという結論に達しました。

AIのおすすめされるまま、[WezTerm](https://wezterm.org/)を使ってみたのですが、これもクラッシュする。

GPUを使うターミナル全般が駄目なのか…？ということで、最終的に[WSL Terminal](https://github.com/mintty/wsltty)に落ち着きました。
これはGPUを使っていないので安定しています。
