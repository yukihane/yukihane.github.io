---
title: "DaVinci Resolve"
date: 2020-07-23T16:26:52Z
draft: false
---

## 録画フォーマット

OBS Studioでオーディオをマルチトラックで録画する場合にはmkvを使うのがよさそう。
ただしそのままではDavinci Resolveが認識できないのでffmpegで変換を行う。

```
 ffmpeg -i <入力ファイル>.mkv -c copy  -map 0 output.mov
```

実際には次のようなシェルスクリプトを使ってgit-bashのbashで実行している:

```
#!/bin/bash
# https://stackoverflow.com/a/8200370/4506703

set -eu

for i in *.mkv; do
    name=$(echo "$i" | cut -d'.' -f1)
    output=$name.mov
    if [ ! -f "$output" ]; then
      echo "PROCESSING $i"
      ffmpeg -i "$i" -c copy -map 0 "$output"
    else
      echo "skip $i, processd file exists"
    fi
done
```

- 追記1: OBS Studioにremux(再多重化)という機能があり、これを使えば同等のことができる。 **ファイル > 録画の再多重化** メニューで実行できる
- 追記2: 現行バージョンのDaVinci Resolveは直接mkvを扱えるようになったのでもはやこの変換は不要
- 追記3: OBS Studioで Hybrid MP4という録画形式を選べるようになったので、mkvでなくそちらを選んで良いかもしれない

## HowTo

### 字幕を挿入する

[本当の字幕機能もある](https://www.youtube.com/watch?v=mH9jMdorT-c)が、いわゆるゲーム実況での字幕はこの機能では十分ではないはず。

エフェクトライブラリ > ツールボックス > タイトル > テキスト
から挿入できるものが欲しかったもののはず。

### 瞬間的なピーク音を低減する

参考: https://www.youtube.com/watch?v=E8Q2MhGw3wk&t=3m10s

インスペクタ > オーディオ > クリップのボリューム
で特定の区間のボリュームを調整できる。

### 複数音声トラックを含む動画ファイルをタイムラインで編集する

Editタブのメニューで **Edit > Edit Options > Automatically**

この設定を有効にしておかないと、タイムラインにDnDしたとき音声トラックが自動では1つしか現れない。
以前のバージョンではこの設定がONの状態がデフォルトの挙動だったので、昔から使っているユーザー(自分含め)が混乱していることが多い。
