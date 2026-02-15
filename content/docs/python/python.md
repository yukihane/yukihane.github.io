---
title: "Python"
date: 2020-07-26T02:59:15Z
draft: false
---

# セットアップ

## pip

`pip` を使い、非rootでインストールするには `--user` オプションを付ける。 このオプションをつけると `~/.local` 以下にインストールされる。

ただ、 `pip` のアップグレードは

``` bash
pip install --user --upgrade pip
```

とせず、 `--user` を付けなくても `~/.local` にインストールされた。

## 環境変数

前述の通り `pip` を使うと `~/.local/bin` に実行ファイルがインストールされるので、ここにPATHを通しておく。

# UNIXコマンド実行 subprocess

- <https://docs.python.jp/3/library/subprocess.html>

``` python
import subprocess

proc = subprocess.Popen(['ls', '-l'], stdout=subprocess.PIPE)
res = proc.communicate()
text = res[0].decode('utf-8').rstrip()
```

# 標準入力

[sys.stdin](http://docs.python.jp/3.5/library/sys.html) か [fileinput.input()](http://docs.python.jp/3.5/library/fileinput.html#module-fileinput) を使用する？

``` python
    with sys.stdin as f:
```

とすればストリーム的に扱えたが、正しい利用法なのか確証がない(ドキュメントに書かれているのを見つけられていない)。

# 正規表現

- <https://docs.python.jp/3/library/re.html>

``` python
import re

pattern = re.compile("xxx")
res = pattern.match(target_text)
```

\`match\`あるいは\`search\`が使用できる。

# データ構造

- [list](http://docs.python.jp/3.5/library/stdtypes.html#lists)

- [set](http://docs.python.jp/3.5/library/stdtypes.html#set-types-set-frozenset)

- [dict](http://docs.python.jp/3.5/library/stdtypes.html#mapping-types-dict)

- <http://docs.python.jp/3.5/tutorial/datastructures.html>
