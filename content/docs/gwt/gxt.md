---
title: "GXT"
date: 2020-07-26T02:19:25Z
draft: false
---

<div id="header">

</div>

<div id="content">

<div class="sect1">

## オフィシャルサイト

<div class="sectionbody">

<div class="ulist">

- [GXT3](https://docs.sencha.com/gxt/3.x/)

- [GXT4](https://docs.sencha.com/gxt/4.x/)

</div>

<div class="paragraph">

GXTのマニュアルのURLはこれまで頻繁に変わってきたので、上記のリンクもいつの間にか切れている可能性もある。

</div>

<div class="paragraph">

またSencha社は独自のMavenリポジトリ <a href="https://maven.sencha.com/repo/webapp/browserepo.html" class="bare">https://maven.sencha.com/repo/webapp/browserepo.html</a> (※経験上、頻繁にダウンしている)を持っている。 商用バージョンを使用する場合はこちらから取得することになるだろう。

</div>

<div class="paragraph">

GPLv3バージョンについても、 [Maven Central Repository](http://search.maven.org/)より新しいバージョンが上がっていることもあったかもしれないので、一応チェックはしておくのが吉。

</div>

</div>

</div>

<div class="sect1">

## セットアップ

<div class="sectionbody">

<div class="paragraph">

gxtを組み込むには[gxtのマニュアル Getting started general configuration](https://docs.sencha.com/gxt/3.x/guides/getting_started/Getting_Started.html#getting_started-%3Cem%3E-Getting_Started%3C/em%3E-_getting_started_general_configuration)参照。

</div>

<div class="paragraph">

`pom.xml` にdependencyを追加すること(ちなみにGPL版の3.x最新バージョンは3.1.1なので例の通りのバージョン指定では駄目)、\`\[module名\].gwt.xml\`にinheritを追加する。

</div>

<div class="paragraph">

[最初からGXTが使えるarchetype](https://docs.sencha.com/gxt/3.x/guides/getting_started/maven/Archetypes.html)もあるようだが使用したことはない。

</div>

</div>

</div>

</div>

<div id="footer">

<div id="footer-text">

Last updated 2026-02-15 15:48:50 +0900

</div>

</div>
