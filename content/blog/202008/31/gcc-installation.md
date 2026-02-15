---
title: "CentOS6にGCC10.2.0をインストールしたときのメモ"
date: 2020-08-30T21:32:44Z
draft: false
tags:
  - linux
---

ビルド作業は次のページを参考にしました:

- [gcc-10.1.0をCentOS7にソースインストール \| 株式会社オルタ](https://aulta.co.jp/archives/7554)

環境は [こちら]({{< ref"/blog/202008/30/gcc-compilation-time" >}}) に記載したものです。

    curl -L -O http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-10.2.0/gcc-10.2.0.tar.xz
    tar xf gcc-10.2.0.tar.xz
    cd gcc-10.2.0
    ./contrib/download_prerequisites
    ./configure --enable-languages=c,c++ --prefix=/opt/gcc-10.2.0 --disable-bootstrap --disable-multilib
    make -j 5
    sudo make install

つづいて `ldoconfig` での登録ですが、そのまま行うとエラーが出たので [こちら](https://qiita.com/knutpb1205/items/4a9b39bf69f1788ef69c#%E3%82%A8%E3%83%A9%E3%83%BC%E5%AF%BE%E7%AD%96) を参照にして事前に1つのファイルをリネームしておきました:

    sudo mv /opt/gcc-10.2.0/lib64/{,bak.}libstdc++.so.6.0.28-gdb.py

そして `ldconfig` のコンフィグを設定し実行:

    sudo bash -c 'cat > /etc/ld.so.conf.d/gcc-10.2.0.conf' << EOF
    /opt/gcc-10.2.0/lib64
    EOF
    sudo ldconfig

`gcc` へのPATHを設定:

    echo 'PATH=/opt/gcc-10.2.0/bin:$PATH' >> ~/.bashrc
    source ~/.bashrc

以上です。
