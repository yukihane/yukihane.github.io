---
title: "MSYS2インストール"
date: 2020-07-24T00:46:39Z
draft: false
---

[RustでデバッグするためのGDBと](Rust)、Qtコンパイル用環境をMSYS2上でセットアップします。

# インストール

オフィシャルページ <http://www.msys2.org/> から64bit用インストーラをダウンロードし、書かれている手順に沿って進めるだけです。

# PATH 設定

\`C:\msys64\mingw64\bin\`を\`PATH\`に追加しておきます。 (Eclipseからgdbが実行できるようにするためにはこの設定が必要です。)

なお、優先度は低く(つまり、PATHの最後に追記する)しておいた方が良いかと思います。

# 各種パッケージのインストール

## デバッガ, コンパイラ

`pacman -S base-devel mingw-w64-x86_64-toolchain`

## Qt

`pacman -S mingw-w64-x86_64-qt-creator mingw-w64-x86_64-cmake`

スタティックリンク版が必要なら

`pacman -S mingw-w64-x86_64-qt5-static`

参考:

- <https://wiki.qt.io/MSYS2#Obtain_Pre-Built_Qt_.26_QtCreator_binary_files_and_Use_instantly_without_Building.2FCompiling>\[MSYS2

  - Qt Wiki\]

- [MinGW-64-bit - Qt Wiki](https://wiki.qt.io/MinGW-64-bit)
