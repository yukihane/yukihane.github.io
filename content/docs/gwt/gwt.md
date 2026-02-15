---
title: "GWT"
date: 2020-07-26T02:07:09Z
draft: false
---

# プロジェクトのセットアップ

## 手順

Mavenを用い、次のコマンドで `pom.xml` を生成する。

``` bash
mvn archetype:generate \
   -DarchetypeGroupId=net.ltgt.gwt.archetypes \
   -DarchetypeVersion=2017.10.20 \
   -DarchetypeArtifactId=modular-webapp
```

## 備考

- [オフィシャルサイト](http://www.gwtproject.org/gettingstarted.html)にはAntでのセットアップ方法が書かれているが、この方法は古いため用いない方が良い。

- 現在ではMavenを用いるのが良い。gwt pluginは2つ並行で開発されていたことがあるが、そのうちの一方 [**mojo** GWT maven plugin](https://gwt-maven-plugin.github.io/gwt-maven-plugin/)は自身をレガシーと呼び、もう一方を使用することを推奨している。

# 旧記述

GWTおよびGXTについて。

都合上このページは最新版でないgwt2.7とgxt3.1.xの利用を前提に記載。最新バージョンでも基本は変わらないはず。

# オフィシャルサイト

- [GWT Project](http://www.gwtproject.org/)

- [GXT3](https://docs.sencha.com/gxt/3.x/)

- [GXT4](https://docs.sencha.com/gxt/4.x/)

GXTのマニュアルのURLは頻繁に変わる…

またSencha社は独自のMavenリポジトリ <https://maven.sencha.com/repo/webapp/browserepo.html> を持っている(が、商用プロダクトを購入しないなら不要だろう)。

# Maven archetype

[Mojo’s Maven Plugin for GWT – GWT Archetype](https://gwt-maven-plugin.github.io/gwt-maven-plugin/user-guide/archetype.html)

``` bash
 mvn archetype:generate \
   -DarchetypeGroupId=org.codehaus.mojo \
   -DarchetypeArtifactId=gwt-maven-plugin \
   -DarchetypeVersion=2.7.0
```

gxtを組み込むにはhttps://docs.sencha.com/gxt/3.x/guides/getting_started/Getting_Started.html#getting_started-*-Getting_Started*-\_getting_started_general_configuration\[gxtのマニュアル Getting started general configuration\]参照。

`pom.xml` にdependencyを追加すること(ちなみにGPL版の3.x最新バージョンは3.1.1なので例の通りのバージョン指定では駄目)、 `[module名].gwt.xml` にinheritを追加する。

[最初からGXTが使えるarchetype](https://docs.sencha.com/gxt/3.x/guides/getting_started/maven/Archetypes.html)もあるようだが使用したことはない。

# 実行

## SuperDevMode

昔は普通のDevModeというのがあり、これを本プラグインのドキュメントではClassicと呼んでいるが、既にdeprecatedな仕様であり気にする必要はない。 <https://gwt-maven-plugin.github.io/gwt-maven-plugin/run-mojo.html>

``` bash
mvn process-classes war:exploded gwt:run
```
