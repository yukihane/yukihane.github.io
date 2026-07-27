---
title: "Ubuntu26.04でlsコマンドの不具合。GNU版を入れ直す"
date: 2026-07-27T11:42:47+09:00
tags: ["ubuntu", "linux"]
draft: false
---

Ubuntu 26.04 で `ls` を実行したところ、日本語のファイル名がまともに表示されませんでした。

原因を調べたところ、Ubuntu 26.04 の `ls` は GNU coreutils ではなく **Rust 実装の [uutils/coreutils](https://github.com/uutils/coreutils)** に置き換わっており、そのロケール判定にバグがあることが分かりました。

## Ubuntu 26.04 の coreutils は Rust 実装

[Ubuntu 26.04 LTS のリリースノート](https://documentation.ubuntu.com/release-notes/26.04/summary-for-lts-users/)によると、25.10 以降、OS の core utilities は `rust-coreutils` パッケージが提供するものになっています。`base64` などで性能改善があるとのことです。

ただし互換性はまだ完全ではないため、従来の GNU 版も併せて提供されており、こちらは **コマンド名に `gnu` を前置** して呼び出します。

```
gnuls
```

なお、`cp` / `mv` / `rm` については未解決の不具合があるため、`rust-coreutils` の中でも中身は GNU 版のままだそうです。

## 症状: 日本語ファイル名がエスケープされる

`ls` が非 ASCII 文字をエスケープしてしまう、というものです。ロケールが `C.UTF-8`(あるいは `POSIX.UTF-8`)のときに発生します。

```
$ locale
LANG=C.UTF-8
...
```

これは uutils 側のバグで、以下の PR で修正されました。

- [uucore: fix C.UTF-8 locale incorrectly detected as ASCII #12525](https://github.com/uutils/coreutils/pull/12525)

PR の説明によれば、ロケール名の判定で `.UTF-8` というエンコーディングのサフィックスを見る前に `C` にマッチして早期 return していたため、`C.UTF-8` がバイト比較ロケール(= ASCII)として扱われていた、とのことです。その結果、

- `ls` が非 ASCII のファイル名文字をエスケープしてしまう
- `expr` がマルチバイトデータに対してバイト単位の処理をしてしまう

という影響が出ていました。修正は 2026-07-26 に merge されていますが、当然ながら Ubuntu 26.04 のパッケージに降りてくるのはもう少し先です。

## GNU 版に戻す

リリースノートには、両者を切り替えるコマンドとして次のものが案内されています。

```
sudo apt install coreutils-from-gnu --allow-remove-essential
```

しかし、これだけでは依存関係が解決できず失敗しました。`coreutils-from-uutils` の削除と `coreutils-from-gnu` の導入を **1 回の apt 実行にまとめる** 必要があるようです。

パッケージ名の末尾に `-` を付けると「そのパッケージを削除する」という指定になるので、次のように書きます。

```
sudo apt-get install \
  coreutils-from-gnu \
  coreutils-from-uutils- \
  --allow-remove-essential
```

これで `ls` が GNU 版になり、日本語ファイル名も正しく表示されるようになりました。

Rust 実装に戻したい場合は逆の指定をします。

```
sudo apt install coreutils-from-uutils --allow-remove-essential
```

`--allow-remove-essential` が要求されることからも分かるとおり、essential パッケージを入れ替える操作です。実行前後の変更内容はよく確認しておいたほうがよいでしょう。

## まとめ

- Ubuntu 26.04 の `ls` などは Rust 実装(uutils)に置き換わっている
- `C.UTF-8` ロケールで非 ASCII 文字がエスケープされる不具合があり、upstream では修正済み
- 手っ取り早く回避するなら `gnuls` を使うか、`coreutils-from-gnu` に入れ替える
