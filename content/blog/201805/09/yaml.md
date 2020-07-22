---
title: yamlの継承っぽいのは継承というよりハッシュのマージ
date: 2018-05-09T19:26:26Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [yaml]
# images: []
# videos: []
# audio: []
draft: false
---

なので配列(Array)には使えない。

```
database: &default
  ip: 192.168.1.5
  port: 2000
  db_name: test
foo_database:
  <<: *default
  port: 2001
  db_name: foo
```

上は実現できても下のようにはできない。

```
database_attr: &default
  - ip
  - port
www_attr:
  <<: *default
  - name
```

関連: https://github.com/yaml/yaml/issues/35
