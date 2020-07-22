---
title: Undertow上でJSF実現
date: 2018-07-08T19:33:26Z
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

# 手順

- [FacesInitializer#onStartup](https://github.com/javaserverfaces/mojarra/blob/2.2.8-28/jsf-ri/src/main/java/com/sun/faces/config/FacesInitializer.java#L120)でやっていることを自力で書く
- 標準パス(`WEB-INF/classes`)に無いので、`ManagedBean`アノテーションを付与したクラスを自前で収集する

ソースは: https://github.com/yukihane/hello-undertow-mojarra

## 関連

- [Tomcat 上で JSF 実現 - Qiita](https://qiita.com/yukihane/items/45c562809360cfa27be9)
- [Does Undertow work with JSF? - Stack Overflow](https://stackoverflow.com/questions/51223600/)
