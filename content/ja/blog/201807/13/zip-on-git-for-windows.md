---
title: Git for Windowsでzipコマンドを再現する
date: 2018-07-13T19:36:48Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [windows, git]
# images: []
# videos: []
# audio: []
draft: false
---

[`git-archive`](file:///C:/Program%20Files/Git/mingw64/share/doc/git-doc/git-archive.html)使えば何とかなることに気付きました。
ちなみに`unzip`コマンドは標準で使えます。

    mkdir workrepo
    cd workrepo
    git init
    cp -r [target_file_or_dir] .
    git add .
    git commit -m commit
    git archive -o ../myarchive.zip @
    cd ..
    rm -rf workrepo

あんまり自信ないんですけどスクリプトファイルに落とすとこんな感じ？

    #!/usr/bin/bash

    set -eu

    unset workdir
    onexit() {
      if [ -n ${workdir-} ]; then
        rm -rf "$workdir"
      fi
    }
    trap onexit EXIT

    workdir=$(mktemp --tmpdir -d gitzip.XXXXXX)


    cp -r "$2" "$workdir"

    pushd "$workdir"
    git init
    git add .
    git commit -m "commit for zip"
    popd

    git archive --format=zip -o "$1" --remote="$workdir" HEAD
