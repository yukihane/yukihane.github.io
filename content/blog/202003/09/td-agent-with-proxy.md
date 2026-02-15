---
title: "td-agentにプロキシを設定する"
date: 2020-03-09T07:54:53Z
draft: false
tags:
  - fluentd
---

``` sh
sudo systemctl edit td-agent
```

で編集画面を開き、次を記述:

    [Service]
    Environment="HTTP_PROXY=http://myproxy.example.com:8080"
