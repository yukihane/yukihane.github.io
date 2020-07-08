---
title: Polymer2 で <input>の値をバインドする
date: 2018-01-21T19:08:22Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [polymer, frontend]
# images: []
# videos: []
# audio: []
draft: false
---

ドキュメントの[start](https://www.polymer-project.org/2.0/start/)を読み終えて、さあなにか作ってみるか、そうだよく 2-way binding の例で出てくる`input`タグ入力値を画面に反映させるのをやってみよう、と思って

```html
<template>
  <div><input type="text" value="{{text}}" /></div>
  <div>[[text]]</div>
</template>
```

とかやってみたものの上手く行かなかった。

答えはここにありました。

- [Two-way binding to a non-Polymer element](https://www.polymer-project.org/2.0/docs/devguide/data-binding#two-way-native)
- 和訳: [Polymer 要素でない要素への双方向データバインディング](https://qiita.com/jtakiguchi/items/60f877d907e3d1fd51af#polymer%E8%A6%81%E7%B4%A0%E3%81%A7%E3%81%AA%E3%81%84%E8%A6%81%E7%B4%A0%E3%81%B8%E3%81%AE%E5%8F%8C%E6%96%B9%E5%90%91%E3%83%87%E3%83%BC%E3%82%BF%E3%83%90%E3%82%A4%E3%83%B3%E3%83%87%E3%82%A3%E3%83%B3%E3%82%B0)

[`input`](https://developer.mozilla.org/ja/docs/Web/Events/input)イベントを拾うために次のように **`::input`** を後ろにくっつける必要がある。

```html
<template>
  <div><input type="text" value="{{text::input}}" /></div>
  <div>[[text]]</div>
</template>
```

参考: [Cannot data bind to &lt;input&gt; in Polymer 2.0 - Stack Overflow](https://stackoverflow.com/q/44711223/4506703)

---

全文はこちら:
https://jsfiddle.net/2eqkymLf/

```html
<!DOCTYPE html>
<html lang="ja">
  <head>
    <meta charset="UTF-8" />
    <meta http-equiv="X-UA-Compatible" content="ie=edge" />
    <base href="https://polygit.org/components/" />
    <script src="webcomponentsjs/webcomponents-lite.js"></script>
    <link rel="import" href="polymer/polymer.html" />
    <link rel="import" href="polymer/polymer-element.html" />
  </head>
  <body>
    <my-input></my-input>

    <dom-module id="my-input">
      <template>
        <div><input type="text" value="{{text::input}}" /></div>
        <div>[[text]]</div>
      </template>

      <script>
        // For Firefox
        // https://github.com/Polymer/polymer-bundler/issues/234#issuecomment-133379949
        window.addEventListener("WebComponentsReady", function () {
          class MyInput extends Polymer.Element {
            static get is() {
              return "my-input";
            }
            static get properties() {
              return {
                text: String,
              };
            }
            constructor() {
              super();
            }
          }
          customElements.define(MyInput.is, MyInput);
        });
      </script>
    </dom-module>
  </body>
</html>
```
