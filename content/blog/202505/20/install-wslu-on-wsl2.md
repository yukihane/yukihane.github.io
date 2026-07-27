---
title: "WSL2環境にwslu(wslview)をインストールしよう"
date: 2025-05-20T12:50:13+09:00
tags: ["wsl", "rust"]
draft: false
---

久しぶりに Rust の学習を行っています。

URL をウェブブラウザーで開くのに [open](https://crates.io/crates/open) というクレートがあるのを見つけ、add してみました。

依存関係で [is-wsl](https://crates.io/crates/is-wsl) というものも追加されているようだったので、おお、ちゃんと WSL2 環境にも対応しているんだな、と思い利用してみたところ…ブラウザーが開かない。

[検索してみると](https://github.com/Byron/open-rs/blob/f196640a9c0def100401f6e97ebe5dd4b4f2bb0e/src/lib.rs#L80)、WSL 環境では `wslview` というコマンドを使うそう。

それは何だろう、と検索してみたところ、 "wslu - A collection of utilities for WSL" というパッケージに含まれているコマンドのうちのひとつのようでした。

```
sudo apt install wslu
```

でインストールできます。

ただ、メンテナンスはもうされてなさそうです...

- https://github.com/wslutilities/wslu

## 追記(2026-07-27): Ubuntu 26.04 では apt でインストールできない

上記のとおり wslu は上流の開発が終了しており、GitHub リポジトリーも 2025-03-01 にアーカイブされています。

その影響で、**Ubuntu 26.04 では wslu が公式 APT リポジトリーから削除されました**。

```
sudo apt install wslu
```

としてもインストールできません。

また、PPA リポジトリー

- https://launchpad.net/~wslutilities/+archive/ubuntu/wslu

を追加すればよい、という記事も見かけましたが、こちらも 26.04 向けのパッケージが用意されておらず駄目でした。

### 自前でビルドする

こちらの記事で紹介されているとおり、アーカイブされた GitHub リポジトリーから clone してビルドすれば、引き続き `wslview` を利用できます。

- [WSL2のCLIからWindows側のブラウザ起動を解決する記事。「Ubuntu-26.04」以降もwsluのwslviewを使う](https://zenn.dev/tazzae999jp/articles/f0c2dd85136303)

```
cd /tmp
rm -rf wslu
git clone https://github.com/wslutilities/wslu.git
cd wslu
make
sudo make install
```

`/usr/bin/wslview` が配置されるので、動作確認します。

```
which wslview
wslview https://www.google.co.jp
```

Windows 側の既定ブラウザーが開けば OK です。

### xdg-open 経由でも呼べるようにする

CLI ツールによっては `wslview` を直接呼ぶのではなく、`xdg-open` や `BROWSER` 環境変数を見にいくものがあります。そのため、以下も設定しておくとよいです。

```sh
# ~/.bashrc
export BROWSER="/usr/bin/wslview"
```

```
sudo ln -sf /usr/bin/wslview /usr/local/bin/xdg-open
```

さらに古い CLI やライブラリーは `x-www-browser` / `www-browser` を参照することがあるので、必要に応じて `update-alternatives` にも登録します。

```
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/wslview 1
sudo update-alternatives --install /usr/bin/www-browser www-browser /usr/bin/wslview 1
```

なお、この方法は APT 管理下ではなく、保守終了した upstream ソースからの手動インストールです。将来リポジトリーが削除される可能性を考えると、自分の GitHub アカウントへミラーしておくと安心です。

```
git clone --bare https://github.com/wslutilities/wslu.git
cd wslu.git
git push --mirror https://github.com/<your-github-account>/my_wslu.git
```
