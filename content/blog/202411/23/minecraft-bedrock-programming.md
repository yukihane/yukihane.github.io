---
title: "Minecraft Bedrock で Add-on 開発環境を利用して Hello, world!"
date: 2024-11-23T19:19:20+09:00
draft: false
tags: ["minecraft"]
---

## はじめに

Minecraft Bedrock Edition(いわゆる統合版)には、Java EditionでいうところのMODに相当するAdd-onを開発する環境があります。
これを利用して、自作プログラミングをMinecraft上で実行する環境をセットアップします。

## 参考資料

- [Minecraft: Bedrock Edition ドキュメント > Bedrock Edition の追加コンテンツ開発の概要](https://learn.microsoft.com/ja-jp/minecraft/creator/documents/gettingstarted)
    - 日本語があってうれしい、と思うのも束の間、英語版と比べると記述が古い(というか説明が不足している)ことが多々あるので英語版を参照する方が良さそうです。英語版はURLの `ja-jp` の部分を `en-us` に変えれば辿り着けます。
- MicrosoftのGitHubリポジトリー
    - 上記リンク先のドキュメント群を読んでいると登場します
    - https://github.com/microsoft/minecraft-scripting-samples
    - https://github.com/microsoft/minecraft-samples
- [Starting Scripting | Bedrock Wiki](https://wiki.bedrock.dev/scripting/starting-scripts.html)

## 事前準備

- Minecraft Bedrock の preview release 実行環境
    - 今回はbeta版のAPIも利用したいのでpreviewを用います
    - beta版のAPIはstable releaseでも動く、という説明も見かけましたが、少なくとも私が試した限り動作しませんでした(ただstableにもbeta APIを使用する設定はあるので、もしかすると一時的な不具合なのかも？)
- Node.js開発環境
    - Node.js, VSCodeあたり。VSCodeの代わりに [bridge.](https://wiki.bedrock.dev/guide/software-preparation#bridge) というIDEが推奨されているのも見かけましたが私はまだ触れていません

## セットアップ
### 初期ファイル作成

プロジェクトを構成するのに必要な初期ファイル群を作成します。
作成するやり方はいくつかあって、次のような方法が公式ドキュメントでは解説されていました:
- GitHubリポジトリーにある[ts-starter](https://github.com/microsoft/minecraft-scripting-samples/tree/main/ts-starter) をコピペして情報を書き換えて使いまわす
    - UUIDとか手動で設定しないといけないので面倒
- https://mctools.dev/ でテンプレートを生成する
- [`mct` コマンド](https://www.npmjs.com/package/@minecraft/creator-tools)で生成する

後者2つは本質的に同じっぽいので、コマンドで生成することにします。

```bash
npx -p @minecraft/creator-tools -c 'mct create'
```
ウィザードの質問には次のように回答:
```
? What's your preferred project title? hello_world
? What's your preferred project description? My first programming for Minecraft
? What's your creator name? yukihane
? What's your preferred folder name? hello_world
? What's your preferred project short name? (<20 chars, no spaces) hello_world
? What template should we use? tsStarter: TypeScript Starter
```
そうすると(上で入力した情報は無視されて) `out` というディレクトリーにプロジェクトが生成されます。

### 生成されたファイルの編集
#### 依存モジュール設定

ディレクトリー名を変更してVSCodeで開きます:

```bash
mv out hello-world
cd hello-world
code .
```

`package.json` を開いて、一旦 `dependencies` セクションに入っているモジュールを全部削除します:
```diff
diff --git a/package.json b/package.json
index cc7d3b6..52b3306 100644
--- a/package.json
+++ b/package.json
@@ -20,10 +20,5 @@
     "enablemcloopback": "CheckNetIsolation.exe LoopbackExempt -a -p=S-1-15-2-1958404141-86561845-1752920682-3514627264-368642714-62675701-733520436",
     "enablemcpreviewloopback": "CheckNetIsolation.exe LoopbackExempt -a -p=S-1-15-2-424268864-5579737-879501358-346833251-474568803-887069379-4040235476"
   },
-  "dependencies": {
-    "@minecraft/math": "^1.4.0",
-    "@minecraft/server": "^1.13.0",
-    "@minecraft/server-ui": "^1.2.0",
-    "@minecraft/vanilla-data": "^1.21.20"
-  }
-}
\ No newline at end of file
+  "dependencies": {}
+}
```

beta版のモジュールをインストールします:

```bash
npm i @minecraft/server@beta
```

ちなみにこのモジュール、 `node_modules/@minecraft/server/` を覗くとわかりますがTypeScriptの型定義だけです。
実際に利用するAPIのバージョンを指定するのは次の設定です。

#### APIバージョン指定

`node_modules/@minecraft/server/index.d.ts` の冒頭に書かれている通り `manifest.json` でバージョンの指定を行います。
`behavior_packs/yuki_hell/manifest.json` を開き次のように変更します:
```diff
diff --git a/behavior_packs/yuki_hell/manifest.json b/behavior_packs/yuki_hell/manifest.json
index 9671af5..541b044 100644
--- a/behavior_packs/yuki_hell/manifest.json
+++ b/behavior_packs/yuki_hell/manifest.json
@@ -20,7 +20,7 @@
   "dependencies": [
     {
       "module_name": "@minecraft/server",
-      "version": [1, 15, 0]
+      "version": "1.18.0-beta"
     },
     {
       "uuid": "6f97a93c-67e7-4c14-894d-e227d5c35053",
```
ちなみに利用可能なバージョンは以下のリンク先に一覧があります:
- https://learn.microsoft.com/ja-jp/minecraft/creator/scriptapi/minecraft/server/minecraft-server?view=minecraft-bedrock-stable#available-versions

今回は `1.18.0-beta` を利用することになっていますが、このバージョンがリンク先の Available Versions に含まれていることを確認してください。

あとついでに説明してしまいますが、このリンク先で説明されているExperimentalバージョンというのとbetaバージョンというのは同じ意味のようです。
(正確に言うとexperimentalなAPIを実装しているのがbetaバージョン、ということかなと思いますが。気づくまで私は少し混乱しました)

#### インストール先を preview 環境にする

`.env` を開き `MINECRAFT_PRODUCT` の値を `PreviewUWP` に変更します:
```diff
diff --git a/.env b/.env
index 46c9fa1..84917bd 100644
--- a/.env
+++ b/.env
@@ -1,3 +1,3 @@
 PROJECT_NAME="yuki_hell"
-MINECRAFT_PRODUCT="BedrockUWP"
+MINECRAFT_PRODUCT="PreviewUWP"
 CUSTOM_DEPLOYMENT_PATH=""
 ```

### 実行確認

取り敢えずテンプレートにデフォルト実装されている挙動 `scripts/main.ts` が動作することを確認します。

#### デプロイ

```bash
npm run local-deploy
```

でデプロイします。

#### Minecraft起動

Minecraft Launcher から Bedrock Edition を選択し、「最新のプレビュー」に切り替えて「プレイ」。
ワールドの新規作成へ進み、次の設定を変更します:
- (optional) 一般 > ゲームモード: クリエイティブ
    - 動作確認中に攻撃されたりするとうっとおしいので。ちなみに難易度を変更するとモブの挙動が変わるそうです。その辺りに依存しないプログラムを書くのなら難易度を変更しても良いのかも
- (optional) 詳細設定 > 平坦な世界: ON
    - プログラミングしやすいように
- (required) ビヘイビアーパック: hello_world を有効化
    - 今回実装したプログラムを実行できるようにします
- (required) 実験 > ベータ API: ON
    - 今回betaバージョンを利用しているのでONにしないと動作しません

設定を終えたらワールドを「作成」し、ゲームプレイを始めると、定期的に "Hello starter! Tick: XXX" というメッセージが出力されるようになっていると思います。
これで `scripts\main.ts` で実装した処理が実行されていることが確認できました。 

### Hello, world!

最後にプログラムを編集し、内容が反映されることを確認します。

まず次のコマンドをプロジェクトディレクトリーで実行します:

```bash
npm run local-deploy -- --watch
```

これで継続的に変更したファイルがデプロイされるようになります。

続いて `scripts\main.ts` を編集します。
何かMinecraft上で実行したいとき、チャットメッセージをトリガーにするのがぱっと思いつく方法かと思いますのでそれを実現してみます。

- [Simple Chat Commands | Bedrock Wiki](https://wiki.bedrock.dev/scripting/custom-command)

がまさにそういうサンプルなので、これを `main.ts` に反映します。
最終的に次のようなコードになりました(テンプレートのコードも、動作しているかどうかを確認するためにそのまま残しています):

```ts
import { world, system } from "@minecraft/server";

function mainTick() {
  if (system.currentTick % 100 === 0) {
    world.sendMessage("Hello starter! Tick: " + system.currentTick);
  }

  system.run(mainTick);
}

system.run(mainTick);

world.beforeEvents.chatSend.subscribe((eventData) => {
  const player = eventData.sender;
  switch (eventData.message) {
    case "!gmc":
      eventData.cancel = true;
      player.runCommandAsync("gamemode c");
      break;
    case "!gms":
      eventData.cancel = true;
      player.runCommandAsync("gamemode s");
      break;
    default:
      break;
  }
});
```

上記コードを保存するとdeployが自動で行われますので、ゲーム内コマンドでリロードします:
```
/reload
```
(スラッシュを入力するとメッセージ入力欄が現れますので続けて入力します)

リロード後もちゃんと "Hello starter! Tick: XXX" が継続的に出力されていれば、正常に読み込まれています。

それではメッセージで命令を行ってみましょう。 `t` キーを押すとメッセージ入力欄が現れますので、続けて `main.ts` で定義した通り

```
!gms
```

と発言してみます。
"ゲームモードがサバイバルに変更されました" と出れば成功です。
