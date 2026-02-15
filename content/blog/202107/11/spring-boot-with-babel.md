---
title: "Spring BootとTypeScriptで開発するためのプロジェクト設定(Gradle) - Polyfillも必要とする場合"
date: 2021-07-10T23:53:20Z
draft: false
tags:
  - spring-boot
  - javascript
---

# はじめに

[前回]({{< relref"/blog/202107/10/spring-boot-with-typescript" >}}) は `ts-loader` を用いて TypeScript をビルドしました。

簡潔にセットアップできたのは良いのですが、実際にはPolyfillを行いたいので `babel-loader` をベースに再構築することにします。また、自動テスト( `jest` )も導入します。

今回の実証コードはこちらです:

- <https://github.com/yukihane/hello-java/tree/master/spring/with-ts-babel>

# 手順

## Spring Boot プロジェクトを構成する

[前回]({{< relref"/blog/202107/10/spring-boot-with-typescript" >}}) と同じです。

## Yarn プロジェクトを構成する

今回は `webpack init` コマンドを利用せず、必要なものを明示的に導入します。 次のコマンドで dependencies を追加します:

    yarn init -y
    yarn add --dev typescript webpack webpack-cli babel-loader @babel/core @babel/plugin-proposal-class-properties @babel/preset-env @babel/preset-typescript
    yarn add core-js

`package.json` に前回自動で追加された `scripts` セクションを手動で追加します:

<div class="formalpara-title">

**package.json**

</div>

    "scripts": {
        "build": "webpack --mode=production --node-env=production",
        "build:dev": "webpack --mode=development",
        "build:prod": "webpack --mode=production --node-env=production",
        "watch": "webpack --watch"
      }

`webpack.config.js`, `tsconfig.json` は [前回]({{< relref"/blog/202107/10/spring-boot-with-typescript" >}}) のものをコピーしてきます。

その上で、 `webpack.config.js` に記述されている `ts-loader` 部分を `babel-loader` に書き換え、 `@babel/preset-env` の設定を追記します。

<div class="formalpara-title">

**webpack.config.js**

</div>

``` javascript
...
      {
        loader: "babel-loader",
        options: {
          exclude: [
            // \\ for Windows, \/ for Mac OS and Linux
            /node_modules[\\\/]core-js/,
            /node_modules[\\\/]webpack[\\\/]buildin/,
          ],
          presets: [
            [
              "@babel/preset-env",
              {
                useBuiltIns: "usage",
                corejs: "3",
                shippedProposals: true,
              },
            ],
            "@babel/preset-typescript",
          ],
          plugins: ["@babel/plugin-proposal-class-properties"],
        },
      },
...
```

更に、 `package.json` へ `browserslist` の設定を追記します。

<div class="formalpara-title">

**package.json**

</div>

      "browserslist": [
        "defaults"
      ]

### 補足

必要な dependencies は次を参照しました:

- [babel-loader \| webpack](https://webpack.js.org/loaders/babel-loader/)

- [microsoft / TypeScript-Babel-Starter - GitHub](https://github.com/microsoft/TypeScript-Babel-Starter)

`browserslist` など、 `@babel/preset-env` の設定は次を参考にしました:

- [@babel/preset-env \> Browserslist Integration · Babel](https://babeljs.io/docs/en/babel-preset-env#browserslist-integration)

- [browserslist / browserslist - GitHub](https://github.com/browserslist/browserslist#browserslist-)

`browserslist` で設定する値は [公式のFull List](https://github.com/browserslist/browserslist#full-list)に記載されています。 また、設定値が具体的にどのブラウザを対象にしているかは、次のコマンドで確認できます:

    npx browserslist "defaults"

## Yarn を Gradle に統合する

[前回]({{< relref"/blog/202107/10/spring-boot-with-typescript" >}}) と同じです。

## ビルドしてみる

[前回]({{< relref"/blog/202107/10/spring-boot-with-typescript" >}}) と同じく、 `UAParser.js` をインストールし、同じサンプルコードを追加します。

加えて、 `babel-loader` の設定で、 `ua-parser-js` を除外するよう設定します。

<div class="formalpara-title">

**webpack.config.js**

</div>

``` javascript
...
  module: {
    rules: [
      {
        loader: "babel-loader",
        options: {
          exclude: [
            ...
            /node_modules[\\\/]ua-parser-js/,
          ],
...
```

### 補足

上記の設定追加を行わない場合、コンパイル時に次の警告

    WARNING in ./src/main/js/index.ts 3:19-27
    export 'UAParser' (imported as 'UAParser') was not found in 'ua-parser-js' (module has no exports)

及び実行時に次のエラー

    Uncaught TypeError: ua_parser_js__WEBPACK_IMPORTED_MODULE_0__.UAParser is not a constructor

が発生します。

この件に関して詳細は次を参照してみてください:

- [UAParser.js をインポートできない - スタック・オーバーフロー](https://ja.stackoverflow.com/q/78174/2808)

## Spring Boot プロセスにデバッガ(Eclipse)をアタッチする

同じく [前回]({{< relref"/blog/202107/10/spring-boot-with-typescript" >}}) を参照してください。

## 自動テストを実行する(Jest)

いくつかやり方はあるようですが、今回は `ts-jest` を利用します。

    yarn add --dev jest @types/jest ts-jest

`package.json` に `jest` セクションを追加します:

<div class="formalpara-title">

**package.json**

</div>

``` json
  "jest": {
    "roots": [
      "<rootDir>/src/main/js"
    ],
    "transform": {
      "^.+\\.tsx?$": "ts-jest"
    },
    "testRegex": "(/__tests__/.*|\\.(test|spec))\\.(tsx?|jsx?)$",
    "moduleFileExtensions": [
      "ts",
      "tsx",
      "js",
      "json",
      "jsx"
    ]
  }
```

`script` セクションを編集し、testを組み込みます。

<div class="formalpara-title">

**package.json**

</div>

``` json
  "scripts": {
    "build": "yarn run test && webpack --mode=production --node-env=production",
    ...
    "test": "jest"
  },
```

### 補足

Jest の設定は次を参考にしています:

- [Jest - TypeScript Deep Dive 日本語版](https://typescript-jp.gitbook.io/deep-dive/intro-1/jest)

Jest の公式ドキュメントでは、別の実現手段として、Babel経由でテストする設定が説明されています:

- [はじめましょう \> TypeScript を使用する · Jest](https://jestjs.io/ja/docs/getting-started#typescript-%E3%82%92%E4%BD%BF%E7%94%A8%E3%81%99%E3%82%8B)

## 型チェックを行う

`@babel/preset-typescript` は [型チェックを行ってくれない](https://github.com/babel/babel/issues/9028) ので、別途チェックする必要が有ります。これは `tsc` で実現します。

そのために `tsconfig.json` を再編集します。

<div class="formalpara-title">

**tsconfig.json**

</div>

    {
      "include": ["src/main/js/**/*"],
      "compilerOptions": {
        "strict": true,
        "module": "es6",
        "target": "es5",
        "moduleResolution": "Node",
        "noEmit": true
      }
    }

`package.json` の `script` セクションを書き換え、型チェックも行うようにします:

<div class="formalpara-title">

**package.json**

</div>

      "scripts": {
        "build": "yarn run test && webpack --mode=production --node-env=production",
        "build:dev": "webpack --mode=development",
        "build:prod": "webpack --mode=production --node-env=production",
        "watch": "webpack --watch",
        "test": "tsc && jest"
      },

### 補足

`tsconfig.json` の設定については下記を参考にしました:

- [TypeScript: Documentation - Using Babel with TypeScript](https://www.typescriptlang.org/docs/handbook/babel-with-typescript.html)

- [Producing ES6-module output from TypeScript, with Jest installed, without producing errors - Stack Overflow](https://stackoverflow.com/a/43019209/4506703)

  - [Typescript cannot find redux - Stack Overflow](https://stackoverflow.com/a/43019209/4506703)
