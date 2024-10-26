---
title: "Spring Boot 開発で SASS や TypeScript を利用するための設定(Vite)"
description: ""
date: 2024-10-26T01:49:44+09:00
draft: false
weight: 0
enableToc: true
tocLevels: ["h2", "h3", "h4"]
tags: ["spring-boot", "vite", "frontend"]
---

## はじめに

次のエントリーで、Spring Boot & Thymeleaf な開発時に TypeScript を利用する設定を書きました。

- [Spring Boot と TypeScript で開発するためのプロジェクト設定(Gradle)]({{< ref "/blog/202107/10/spring-boot-with-typescript" >}})
- [Spring Boot と TypeScript で開発するためのプロジェクト設定(Gradle) - Polyfill も必要とする場合]({{< ref "/blog/202107/11/spring-boot-with-babel" >}})

今回は Spring Boot & Thymeleaf な開発で、もうちょっとちゃんとモダンなフロントエンド開発環境を統合する手順です。

表題の通り Vite を利用します。

また、[こちら]({{< ref "/blog/202410/20/spring-boot-devtools-auto-restart" >}})に書いた問題があるので spring-boot-devtools には依存しないようにします(代わりに IDE(ここでは IntelliJ IDEA Ultimate を利用しますが、Eclipse など他の IDE でも同じはず)の hot swapping 機能を前提にします)。

## 本文の要点

Spring Boot で Thymeleaf(などのテンプレートエンジン) を用いる場合、リソースファイルを `templates` と `static` のディレクトリーに分類して配置する必要があります。

Vite の標準処理フローでは、整合性を保ったままこのように 2 つのディレクトリーに assets を配備することはできなさそうなので、 plugins 機構を使ってマニュアルでファイルを移動させることにしました。

## 実証コード

- https://github.com/yukihane/hello-java/tree/main/spring/with-vite

## 手順

### Spring Boot プロジェクト作成

まず、Spring Boot の環境を整えます。 https://start.spring.io/ で "Spring Web", "Thymeleaf" を含むプロジェクトを作成し、ローカルに展開します。

### Vite プロジェクト作成

続いて、ここにフロントエンド開発環境を整えます。
Spring Boot プロジェクトディレクトリのルート(`gradlew` や `src` ディレクトリがあるところ)で、次のコマンドを実行します:

```
npm create vite@latest
```

([参考](https://vite.dev/guide/#scaffolding-your-first-vite-project))

途中の質問はは次のように回答します:

- Project name: **thymeleaf**
  - 補足: なんでも良いです
- Select a framework: **Vanilla**
- Select a variant: **TypeScript**

以降、作成した `thymeleaf` ディレクトリで作業します。

次のコマンドを実行しモジュールをインストールします。

```
npm install
```

### Vite 設定

自動生成された `index.html` と `src`, `public` ディレクトリ以下のファイルは不要なので削除します。

```
rm -r index.html src/* public/*
```

次に作成するファイルで型を効かせたいので `@types/node` をインストールしておきます:

```
npm install --save-dev `@types/node`
```

`vite.config.ts` ファイルを作成し、次の内容を記述します:

```typescript
// 参考: https://ja.vite.dev/config/
import type { UserConfig } from "vite";
import { resolve } from "path";
import { promises as fs } from "fs";

export default {
  build: {
    minify: false, // 今回、わかりやすいようにminifyは実行しないこととしています
    rollupOptions: {
      // resouces/templates に入れる html ファイルを列挙する
      input: {
        // ここに thymeleaf テンプレートファイルを列挙する
        // "hello/index": "templates/hello/index.html",
      },
      // 出力ファイル名にhashを付けないようにする設定
      // https://github.com/vitejs/vite/issues/378#issuecomment-789366197
      output: {
        entryFileNames: `vite/[name].js`,
        chunkFileNames: `vite/[name].js`,
        assetFileNames: `vite/[name].[ext]`,
      },
    },
  },
  plugins: [
    // ビルドしたファイルを Spring Boot のリソースディレクトリーに移す
    {
      name: "move-resources",
      closeBundle: async () => {
        const srcTemplates = resolve(__dirname, "dist/templates");
        const destTemplates = resolve(
          __dirname,
          "../src/main/resources/templates"
        );

        const srcVite = resolve(__dirname, "dist/vite");
        const destVite = resolve(
          __dirname,
          "../src/main/resources/static/vite"
        );

        try {
          await fs.rm(destTemplates, { recursive: true, force: true });
          await fs.mkdir(destTemplates, { recursive: true });
          await fs.cp(srcTemplates, destTemplates, {
            recursive: true,
            force: true,
          });
          console.log(
            `Moved templates from ${srcTemplates} to ${destTemplates}`
          );

          await fs.rm(destVite, { recursive: true, force: true });
          await fs.mkdir(destVite, { recursive: true });
          await fs.cp(srcVite, destVite, {
            recursive: true,
            force: true,
          });
          console.log(`Moved templates from ${srcVite} to ${destVite}`);
        } catch (err) {
          console.error(`Failed to move templates: ${err}`);
        }
      },
    },
  ],
} satisfies UserConfig;
```

## ページを作成してみる

簡単なページを作成してみます。

`.scss` を扱いたいのでモジュールをインストールします:

```
npm install --save-dev sass-embedded
```

`public` ディレクトリー([参考](https://ja.vite.dev/guide/assets#the-public-directory)) に画像を作成します。このとき、他の(`src` 以下の)ファイルと同じように `vite` ディレクトリに出力されるように `public/vite` 以下に作成します:

```
mkdir -p public/vite/image
# ここでは ImageMagick で画像生成していますが、別に何でも構わないので public/vite/image/hello.png という名前で画像ファイルを保存します
convert -size 300x100 xc:lightblue -gravity center -pointsize 20 -draw "text 0,0 'Hello, World!'" public/vite/image/hello.png
```

`src` ディレクトリーにリソースを作成します:

```typescript
// src/hello/main.ts
document.addEventListener("DOMContentLoaded", () => {
  console.log("Hello, Vite!");
});
```

```scss
/* src/hello/style.scss */
div {
  .hello {
    border: 1px dotted blue;
  }
}
```

上記したリソースを参照する Thymeleaf テンプレート(.html)を `themplates` ディレクトリーに作成します:

```
mkdir -p templates/hello
```

```html
<!DOCTYPE html>
<html lang="ja" xmlns:th="http://www.thymeleaf.org">
  <head>
    <link rel="stylesheet" href="/src/hello/style.scss" />
  </head>
  <body>
    <div>
      <div class="hello" th:text="|Hello, ${name}!|">Hello!</div>
      <div><img src="/vite/image/hello.png" /></div>
    </div>
    <script type="module" src="/src/hello/main.ts"></script>
  </body>
</html>
```

dev モードで起動し、挙動を確かめてみます。

```
npm run dev
```

を実行すると web サーバーが起動するのでブラウザーで http://localhost:5173/templates/hello/index.html にアクセスしてみます。scss が適用されていたり、(ブラウザーの devtools でコンソールを見てみると)TypeScript が実行されていたりするのが確認できたかと思います。

それでは、Spring Boot プロジェクトに出力してみます。

`vite.config.ts` ファイルをひらき、 `build.input` 設定を次のように書き換えます:

```typescript
      input: {
        // ここに thymeleaf テンプレートファイルを列挙する
        "hello/index": "templates/hello/index.html",
      },
```

そして次のコマンドでビルド&配備を行います:

```
npm run build
```

これで Spring Boot プロジェクトの `src/main/resources` 以下にファイルがコピーされました。

最後に Spring Boot 側にコントローラーを作ります:

```kotlin
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping

@Controller
@RequestMapping("/hello")
class HelloController {
    @GetMapping
    fun index(model: Model): String{
        model.addAttribute("name", "Vite")
        return "hello/index"
    }
}
```

これで完成です。 Spring Boot を起動し、 http://localhost:8080/hello へアクセスしてみてください。

## 実際に開発する上での追加設定

### .gitignore 追加設定

Spring Boot の `src/main/resources/static/vite/`, `src/main/resources/templates/` には Vite が生成するファイルが置かれますので、このディレクトリ以下はバージョン管理対象外にします。
具体的には、Spring Boot プロジェクトディレクトリルートの `.gitignore` に次の行を追記します:

```
/src/main/resources/static/vite/
/src/main/resources/templates/
```

### 継続的ビルド

`thyemeleaf/package.json` の `script` 節に `watch` コマンドを追加します:

```json
{
  ...
  "scripts": {
    "watch": "tsc && vite build -w",
    ...
  },
  ...
}
```

`thymeleaf` ディレクトリーで `npm run watch` を実行しておくと、ファイル変更があるたびにビルドが走り Spring Boot のプロジェクトファイルへ同期されるので、リアルタイムで変更が反映されます。

### 既存のプロジェクトへ適用する場合の考慮

既に普通のやり方で `src/resources/templates` に Thymeleaf テンプレートファイルを作成している場合でも、基本的には今回の Vite で管理するようにする方法と同居できます。

ただし上記の設定だと Vite のビルド時に `src/resources/templates` を削除するようにしているので、この辺りの設定を見直す必要があります。
