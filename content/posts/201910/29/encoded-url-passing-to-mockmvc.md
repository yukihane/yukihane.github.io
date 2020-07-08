---
title: "MockMvc でURLエンコード済みのpathを渡したいときは new URI(...) を引数にする"
date: 2019-10-29T20:36:42Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [spring-boot]
# images: []
# videos: []
# audio: []
draft: false
---

OAuth2.0 の `redirect_uri` をゴニョった実装をテストしたいときにハマった。

    mockMvc.perform(get(new URI("/line/oauth/authorize?redirece_uri=https%3A%2F%2Fexample.com")

ってやらないと二重にエンコードされてしまう。

# 参考

- [MockMvc needs to accept prepared URI with encoded URI path variables [SPR-11441] #16067](https://github.com/spring-projects/spring-framework/issues/16067)
- [EncodedUriTests.java](https://github.com/spring-projects/spring-framework/blob/master/spring-test/src/test/java/org/springframework/test/web/servlet/samples/spr/EncodedUriTests.java)
