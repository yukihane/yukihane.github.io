---
title: "CentOS7実行環境を整える"
date: 2024-11-16T05:30:06+09:00
draft: false
tags: ["linux"]
---

今さらCentOS7環境で検証する必要が出たので環境を整えました。
その時のメモです。
ホストOSはWindows11です。

## インストール

### Vagrant

scoop でインストールしました。

プロバイダーの推奨は現在でもVirtualBoxなようですが、Hyper-Vでも利用できそうなので今回はHyper-Vをプロバイダーとして利用することにしました(VirtualBox はインストールしないことにしました)。

- ref. https://developer.hashicorp.com/vagrant/docs/cli/up#provider-x

## セットアップ
### Hyper-V 管理者設定

- [hyper-v + vagrant環境構築 > Hyper-V Administratorsグループに入れる](https://zenn.dev/oto/articles/8dbdb48d9a10ce#hyper-v-administrators%E3%82%B0%E3%83%AB%E3%83%BC%E3%83%97%E3%81%AB%E5%85%A5%E3%82%8C%E3%82%8B)

で説明されている通り、自分を **Hyper-V Administrators** グループに追加しました。
```pwsh
Add-LocalGroupMember -Group "Hyper-V Administrators" -Member yukihane
```

(`yukihane` というのが私のアカウント名です)

設定有効化にはOSの再起動が必要なようでした。


### Vagrant

[centos/7](https://portal.cloud.hashicorp.com/vagrant/discover/centos/7) のboxを利用することにしました。
(これって信頼している人が作ったものだというのをどうやったら確認できるんだっけ？)

```bash
vagrant init centos/7 --box-version 2004.01
```

## 実行
### 仮想マシン起動

自動的に適切なプロバイダーが選ばれるはずなのですが、起動しなかったので明示的にプロバイダーを指定しています。

```bash
vagrant up --provider=hyperv
```

そうすると次のエラーが出て起動しませんでした:

```
Bringing machine 'default' up with 'hyperv' provider...
==> default: Verifying Hyper-V is enabled...
The Hyper-V cmdlets for PowerShell are not available! Vagrant
requires these to control Hyper-V. Please enable them in the
"Windows Features" control panel and try again.
```

検索してみたところ同じエラーが出ている人がいましたが、そちらとは同じ原因では無さそうでした。

- [What is needed to use Vagrant with Hyper-V - Super User](https://superuser.com/a/1626789)
- [What is needed to use Vagrant with Hyper-V - Vagrant - HashiCorp Discuss](https://discuss.hashicorp.com/t/what-is-needed-to-use-vagrant-with-hyper-v/20941/3)

私の環境では部分的にしか(?)Hyper-Vが有効になっていなかったのが原因のようでした。
次のコマンドを実行後再起動することで `vagrant up` がうまく動くようになりました。

```pwsh
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All
```

- ref. [Hyper-V Provider | Vagrant | HashiCorp Developer](https://developer.hashicorp.com/vagrant/docs/providers/hyperv)

## CentOS 初期セットアップ
### Yum リポジトリー設定

CentOS7はEOLを迎え、デフォルトで設定されているリポジトリーはもはや接続できなくなっており、 `yum` コマンドが利用できません。
これを修復します。

```bash
vagrant ssh
```
で仮想マシンに入ります。
以下、仮想マシン内での操作です。

```bash
curl -L -O https://gist.githubusercontent.com/yukihane/5c8ad63ee07c51893d9cae4050d05372/raw/7796d9af0c9e3f162101cca7327b65f7266e9b84/replace-centos7-repo.sh
sudo bash ./replace-centos7-repo.sh
sudo yum update -y
```

次のQiitaエントリーに記載されているスクリプトを [gist](https://gist.github.com/yukihane/5c8ad63ee07c51893d9cae4050d05372) からダウンロードして実行しています。

-ref. [緊急対応！CentOS 7 サポート終了後のyumエラー解消法 - Qiita](https://qiita.com/owayo/items/81c843fb11d27b217433)

以上でCentOS7実行環境が用意できました。

<!--
- [VirtualBoxのネットワークアダプタの種類と動作の違い - あんたいとる](https://shin569.hatenablog.com/entry/2020/04/11/220835)
-->
