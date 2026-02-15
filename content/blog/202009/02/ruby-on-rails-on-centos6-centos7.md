---
title: "Ruby on Rails 6 を Centos6 や Centos7 で動かす"
date: 2020-09-01T15:12:18Z
draft: false
tags:
  - centos
  - ruby
  - rails
---

- [CentOS6 上で rails new できません - スタック・オーバーフロー](https://ja.stackoverflow.com/a/70025/2808)

- [VagrantとCentOS7環境下でRuby及びRailsをインストールしたい。 - スタック・オーバーフロー](https://ja.stackoverflow.com/a/66035/2808)

でそれぞれ、 CentOS6 + Rails6, CentOS7 + Rails6 の Vagrant Box を作成しました。ググってみたけれど、あまり無いものなんですね。

ちなみに私、 Ruby/Rails はミリ知らです。

- [CentOS6の `Vagrantfile` リンク](https://github.com/yukihane/stackoverflow-qa/tree/master/jaso69924)

- [CentOS7の `Vagrantfile` リンク](https://github.com/yukihane/stackoverflow-qa/tree/master/so65998)

苦労した点のメモ:

- Rails6を動かすにはNodeが必要だが、最新版のNode(v12)を動かすには glibc 2.17 が必要っぽい。そして glibc をオフィシャルが提供していないものに置き換えると、それはもはやCentOSとは呼べなくなる気がする。

- glibc 2.20 くらいまでは GCC10.x でビルドしようとすると gcc が too old って言われる。おそらく2桁バージョンをちゃんと認識できていないのではないか。なので古いバージョンのglibcをビルドしたい場合には GCC9 以下でビルドする必要がありそう。

- CentOS6 の glibc をどうしてもアップグレードしたい場合、 [Fedoraのもので置換する方法](https://gist.github.com/harv/f86690fcad94f655906ee9e37c85b174) がぐぐったらヒットした。

- CentOS6はもはやいろんなものが古すぎて、あるものが欲しくなってもバイナリは提供されておらずソースからビルドする必要があり、ソースからビルドしようと思うと別のビルドに必要なものが古すぎて…というループに陥る。さすがにもう古すぎるので避けるべき。
