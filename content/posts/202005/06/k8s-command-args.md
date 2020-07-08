---
title: DockerfileのENTRYPOINTに対応するのはcommand, CMDに対応するのがargs
date: 2020-05-06T21:03:24Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [k8s]
# images: []
# videos: []
# audio: []
draft: false
---

CMD と command が対応しているわけではないのでまぎらわしい…

Kubernetes リファレンス:

- [Container v1 core](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#container-v1-core)

参考として Dockerfile リファレンス:

- [ENTRYPOINT](http://docs.docker.jp/engine/reference/builder.html#entrypoint)
- [CMD](http://docs.docker.jp/engine/reference/builder.html#cmd)
