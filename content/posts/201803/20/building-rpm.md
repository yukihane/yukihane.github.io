---
title: 手っ取り早くRPMパッケージを作成したかった
date: 2018-03-20T19:21:51Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [linux, centos]
# images: []
# videos: []
# audio: []
draft: false
---

## 前提

既にビルド方法は確立しており、パッケージシステムに配布方法だけ任せたい、という場合に最小限の手間で RPM パッケージを作ることを考えます

- ビルドは RPM パッケージングのフロー中では行いません。既存のビルド方法でまかないます。
- 依存関係の設定は今回無視します。

## 参考リンク

- [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)

## インストール

RPM パッケージ作成のために必要なパッケージをインストールします。

```
$ sudo yum install -y rpm-build rpmdevtools
```

## ディレクトリの作成

次のコマンドを実行し、rpm パッケージング作業に必要なディレクトリを作成します。

```
$ rpmdev-setuptree
```

ホームディレクトリ直下に次のようなディレクトリが作成されます。

```
$ tree ~/rpmbuild
/home/yuki/rpmbuild
├── BUILD
├── RPMS
├── SOURCES
├── SPECS
└── SRPMS
```

また、 `~/.rpmmacros` ファイルが生成されます。

## インストール対象ファイルの配置

インストールするファイルを先ほど作成したディレクトリ `~/rpmbuild/BUILD` ディレクトリに置きます。

今回は `hello-world.sh` と `goodby-world.sh` の 2 ファイルを対象とすることにします。

```
$ mv hello-world.sh ~/rpmbuild/BUILD/
$ mv goodby-world.sh ~/rpmbuild/BUILD/
```

## spec ファイル作成

次のコマンドを実行すると、カレントディレクトリに `spec` フファイルの雛形が作成されます。
今回は `my-package` という名前のパッケージを作成することにします。

```
$ rpmdev-newspec my-package
```

## 必要最小限な spec ファイル

上記で作成したファイルを編集します。必須でないものについては削除することにすると、最終的に次のようなものになります。

```
Name:           my-package
Version:        0.0.1
Release:        1%{?dist}
Summary:        my first package

License:        proprietary

BuildArch:      noarch

%description


%install
mkdir -p %{buildroot}%{_bindir}
install -m 0755 hello-world.sh %{buildroot}%{_bindir}/hello-world.sh
install -m 0755 goodby-world.sh %{buildroot}%{_bindir}/goodby-world.sh

%files
%{_bindir}/hello-world.sh
%{_bindir}/goodby-world.sh
```

- 今回は bash スクリプトなので `BuildArch: noarch` を追記しましたが、このセクションを追加しなければビルドした環境(`x86_64` など)が自動で付与されますので省略可能です。
- `%install`セクションにインストール時に実行するコマンドを書き下します。　`%{buildroot}` が実際のインストール時のルートディレクトリ、と覚えておけばひとまず良いかと。
- `%files` セクションにはインストールしたファイルを記述します。
- `%{buildroot}`, `%{_bindir}` といったものはマクロ(macro)です。実際には事前定義された文字列で置き換えられます。詳しくは後述「Macro について」節を参照してください。
- `Version` 及び `Release` については Fedora の[Guidelines for Versioning Fedora Packages](https://fedoraproject.org/wiki/Packaging:Versioning)が参考になるかも。

## RPM パッケージ生成

次のコマンドを実行すると `~/rpmbuild/RPMS` ディレクトリ以下に RPM パッケージが生成されます。

```
$ rpmbuild -bb hello-world.spec
```

## 補足: Macro について

[More on Macros](https://rpm-packaging-guide.github.io/#more-on-macros)節及びそのリンク先が詳しいです。

- `rpm --eval %{buildroot}` など、 `rpm --eval`コマンドでマクロ展開結果を表示できます。
- `/usr/lib/rpm/macros` に、システムが定義している macro があります。

## 付録: インストール先を変更できるように

Relocatable RPM というそうです。
`spec` ファイルに `Prefix` セクションを追加します。

```
Prefix:         %{_prefix}
```

(※ `%{_prefix}` は実際には `/usr` )
これを追加してビルドした RPM パッケージの情報を見ると次のように表示されます。

```
$ rpm -qip my-package-0.0.1-1.el7.centos.noarch.rpm
...
Relocations : /usr
...
```

このようなパッケージをインストールする際に `--prefix` オプションを付与して

```
$ sudo rpm -ivh --prefix /usr/local my-package-0.0.1-1.el7.centos.noarch.rpm
```

のようにインストールすると、 `/usr/bin` の代わりに `/usr/local/bin` 以下にスクリプトがインストールされます。

ちなみに `Prefix` を設定しない場合は "(not relocatable)" と表示されており、同じように `--prefix` オプションを付けてインストールしようとすると
次のようにエラーになりインストールできません。

```
$ sudo rpm -ivh --prefix /usr/local my-package-0.0.1-1.el7.centos.noarch.rpm
エラー: パッケージ my-package は再配置できません。
```
