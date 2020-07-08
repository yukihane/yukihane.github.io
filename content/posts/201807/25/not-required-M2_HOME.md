---
title: M2_HOMEは不要
date: 2018-07-25T19:38:38Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java]
# images: []
# videos: []
# audio: []
draft: false
---

`M2_HOME` は削除されました。

- [MNGSITE-283 Remove M2_HOME from documentation](https://issues.apache.org/jira/browse/MNGSITE-283)
- [MNG-5607 Don't use M2_HOME in mvn shell/command scripts anymore](https://issues.apache.org/jira/browse/MNG-5607)
- [3.5.0 リリースノート](https://maven.apache.org/docs/3.5.0/release-notes.html) "Based on problems in using M2_HOME related to different Maven versions installed and to simplify things, the usage of M2_HOME has been removed and is not supported any more [MNG-5823](https://issues.apache.org/jira/browse/MNG-5823), [MNG-5836](https://issues.apache.org/jira/browse/MNG-5836), [MNG-5607](https://issues.apache.org/jira/browse/MNG-5607)."
- ([変更 commit](https://github.com/apache/maven/commit/065281c43d7435be204aa963e1f94d1128bb5351))

敢えて設定するのであれば、 上の変更 commit リンク先にある通り、`M2_HOME`でなく`MAVEN_HOME`にしましょう。
ただし、敢えて設定すべき状況は通常発生しないと思います。
