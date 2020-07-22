---
title: redux-devtools-extension をTypeScriptで使う
date: 2020-04-24T21:00:56Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [react, redux]
# images: []
# videos: []
# audio: []
draft: false
---

https://github.com/zalmoxisus/redux-devtools-extension/blob/master/README.md#13-use-redux-devtools-extension-package-from-npm

というわけで型付けされているので

    const store = createStore(rootReducer, undefined, devToolsEnhancer({}));

で良い。

何か Qiia の記事とかを見てると[こっちの方法](https://github.com/zalmoxisus/redux-devtools-extension/blob/master/docs/Recipes.md#using-in-a-typescript-project)でばっかり書いてあるが。

---

Electron から使う場合は[Electron 公式](https://www.electronjs.org/docs/tutorial/devtools-extension#how-to-load-a-devtools-extension)からも[redux-devtools-extension 公式](https://github.com/zalmoxisus/redux-devtools-extension#3-for-electron)からもリンクされている [electron-devtools-installer](https://github.com/MarshallOfSound/electron-devtools-installer) が利用できた。
