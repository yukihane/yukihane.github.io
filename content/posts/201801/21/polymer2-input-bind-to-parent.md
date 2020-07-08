---
title: Polymer2 で <input>の値を「親エレメントの値と」バインドする
date: 2018-01-21T19:12:25Z
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

[Polymer2 で <input>の値をバインドする](https://qiita.com/yukihane/items/2cf963901a6c49b390dc) で `my-input` なるカスタムエレメントを作成しました。`<input>`の入力値をそのまま表示するだけのエレメントです。

```html
<dom-module id="my-input">
  <template>
    <input type="text" value="{{text::input}}" />
    [[text]]
  </template>
  ...
</dom-module>
```

さて、この入力値を受け取れるよう、親エレメントを次のように作成しました。

```html
<dom-module id="my-parent">
  <template>
    <my-input text="{{parentText}}"></my-input>
    [[parentText]]
  </template>
  ...
</dom-module>
```

そして`<input>`に値を入力してみると…親に反映されない。

いろいろ試行錯誤してみた所、親エレメント側にも `::input` を足して

```html
<dom-module id="my-parent">
  <template>
    <my-input text="{{parentText::input}}"></my-input>
    [[parentText]]
  </template>
  ...
</dom-module>
```

とすれば反映されるようになりました。けど、これはどうなんだろう？
子(`my-input`エレメント)は、まあ自分が`<input>`を扱っているのを知っているから良いとして、親(`my-parent`エレメント)が子の事情を考慮して実装しないといけないとは。

---

これの答えはここでした。

- [Data system concepts - How data flow is controlled](https://www.polymer-project.org/2.0/docs/devguide/data-system#data-flow-control)
- 和訳: [データフローの制御の仕組み](https://qiita.com/jtakiguchi/items/2a89e5c080a58e8b750b#%E3%83%87%E3%83%BC%E3%82%BF%E3%83%95%E3%83%AD%E3%83%BC%E3%81%AE%E5%88%B6%E5%BE%A1%E3%81%AE%E4%BB%95%E7%B5%84%E3%81%BF)

てっきりカーリーブラケット`{{}}`は、子エレメントへも親エレメントへも自動で反映してくれるものだと思っていたのですが、正確には、「親エレメントへも反映**できる**」だけで、デフォルトでは反映してくれないようです。

> **Automatic**, which allows upward (target to host) and downwards (host to target) data flow. Automatic bindings use double curly brackets ({{ }}):

<span></span>

> `notify`. A notifying property supports upward data flow. By default, properties are non-notifying, and don't support upward data flow.

そんなわけで、`notify`を明示的に`true`に設定してやる必要がありました。

子エレメント(今回の場合だと`my-input`)のプロパティ定義で次のようにすれば良いことになります。

冒頭に書いたような、親エレメント(今回の場合は`my-parent`)に`::input`は必要ありません。

```js
      static get properties() {
        return {
          text:{
            type: String,
            notify: true
          }
        }
      }
```
