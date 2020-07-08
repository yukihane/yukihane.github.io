---
title: React Router <Route> で描画したいコンポーネントの指定方法が人によってまちまちなんだけどどれが正解なの？
date: 2020-04-13T20:54:12Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [react]
# images: []
# videos: []
# audio: []
draft: false
---

https://reacttraining.com/react-router/web/api/Route/route-render-methods

> **The recommended method of rendering something with a <Route> is to use children elements**, as shown above. There are, however, a few other methods you can use to render something with a <Route>. These are provided mostly for supporting apps that were built with earlier versions of the router before hooks were introduced.
>
> - &lt;Route component>
> - &lt;Route render>
> - &lt;Route children> function

つまり、引用部の直前にあるこの書き方:

      <Route exact path="/">
        <Home />
      </Route>
      <Route path="/news">
        <NewsFeed />
      </Route>
