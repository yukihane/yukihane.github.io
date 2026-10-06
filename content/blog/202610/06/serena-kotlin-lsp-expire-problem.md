---
title: "SerenaのKotlin言語サーバーがビルド期限切れで起動しなくなる問題と対処"
date: 2026-10-06T14:09:55+09:00
tags: ["ai-coding", "serena", "kotlin"]
draft: false
---

Claude Codeで [Serena](https://github.com/oraios/serena) を使ってKotlinのコードを読み書きしていると、ある日突然ツールがすべて失敗するようになりました。

原因は、SerenaがKotlinの解析に使っているJetBrains製のKotlin言語サーバーに **ビルドの有効期限がある** ことでした。
しかも自分の環境では、以前直したはずなのに約1か月後にまた同じ問題が起きたので、原因と対処を記録しておきます。

確認日は2026-10-06、Serenaは `1.7.0` です。

## 症状

Serenaのツール（`replace_content` や `find_symbol` など）を呼ぶと、次のエラーで失敗します。

> The language server manager is not initialized, indicating a problem during project initialisation.
> Failed to start 1 language server(s):
> kotlin: Error processing request initialize with params: ...
> (caused by LanguageServerTerminatedException: Language server stdout read process terminated unexpectedly)

「言語サーバーが予期せず終了した」としか書かれていないので、このメッセージだけでは原因が分かりません。
Javaのバージョンやメモリ設定を疑いたくなりますが、今回はどちらも無関係でした。

## 原因はログに

Serenaのログは `~/.serena/logs/<日付>/mcp_*.txt` にあります。
そこを見ると、言語サーバーの標準エラー出力に次のメッセージが残っていました。

```
This build of kotlin-server has expired.
The IDE will now close.
Please download a new build from https://github.com/kotlin/kotlin-lsp
```

SerenaのKotlin対応は、JetBrainsの [Kotlin LSP](https://github.com/Kotlin/kotlin-lsp)（`intellij-server` というバイナリ）を使っています。
このビルドには有効期限があり、期限を過ぎると `initialize` を受け取った直後に自分で終了します。
Serenaのログでも、起動開始から約1秒で失敗していました。

Serena側から見ると、言語サーバーが突然いなくなっただけなので、冒頭の汎用的なエラーになります。

## 関連issue

同じ症状はKotlin LSPのリポジトリで繰り返し報告されています。いずれもクローズ済みです。

| Issue | 起票日 | 内容 |
|---|---|---|
| [#217](https://github.com/Kotlin/kotlin-lsp/issues/217) | 2026-06-04 | This build of intellij-server has expired. |
| [#270](https://github.com/Kotlin/kotlin-lsp/issues/270) | 2026-09-04 | 同上。新しい版の案内が出た |
| [#271](https://github.com/Kotlin/kotlin-lsp/issues/271) | 2026-09-06 | 同上 |

[#270](https://github.com/Kotlin/kotlin-lsp/issues/270) では、JetBrainsの担当者が次のように答えています。

- 現状はIntelliJ Platformの共有コードによる制約であること
- `kotlin-server` が十分に安定したと判断できたら、ビルドの期限をなくすことを検討していること

つまり、当面は定期的に期限切れが起きる前提で付き合う必要がありそうです。

## 対処：使うバージョンを最新にする

Serenaは、使うKotlin LSPのバージョンを設定で指定できます。
グローバル設定の `~/.serena/serena_config.yml` に、次のように書きます。

```
ls_specific_settings:
  kotlin:
    kotlin_lsp_version: '263.6379.0'
```

最新のバージョンは [Kotlin/kotlin-lsp のリリース一覧](https://github.com/Kotlin/kotlin-lsp/releases) で確認できます。
今回は [v263.6379.0](https://github.com/Kotlin/kotlin-lsp/releases/tag/kotlin-lsp%2Fv263.6379.0)（2026-10-03公開）が最新でした。

書き換えたら、Claude Codeの `/mcp` からSerenaを再接続します。
新しいバージョンは再接続のときに自動でダウンロードされ、`~/.serena/language_servers/static/KotlinLanguageServer` の下に追加されます。
古いバージョンを消す必要はありません。

プロジェクトごとの `.serena/project.yml` や `.serena/project.local.yml` にも同じ設定を書けますが、グローバルに書いておけば全プロジェクトに効きます。
特に `git worktree` を多用していると、`.serena` は未追跡のファイルなのでworktreeに引き継がれず、worktreeごとに設定し直す羽目になります。

## 今回の経緯

自分の環境でのバージョンと状況は次のとおりです。

| 日付 | 状況 |
|---|---|
| 2026-09-09 | 使っていた `262.9593.0` が期限切れ。`263.4421.0` に更新して直った |
| 2026-10-06 | 更新した `263.4421.0` が期限切れで起動しない。`263.6379.0` に更新 |

9月9日に直した版が、約4週間後の10月6日には使えなくなっていました。
期限切れの発生はおよそ1か月ごと、という感覚です。
正確な期限は公開されていないので、次回がいつになるかは分かりません。

## 次に起きたときの手順

1. Serenaのログ（`~/.serena/logs/`）で `has expired` を検索して、期限切れだと確認する
2. [リリース一覧](https://github.com/Kotlin/kotlin-lsp/releases)で最新バージョンを確認する
3. `~/.serena/serena_config.yml` の `kotlin_lsp_version` を書き換える
4. Claude Codeの `/mcp` からSerenaを再接続する

## 所感

最初に当たったときは、エラーメッセージが汎用的で、原因にたどり着くまでに時間がかかりました。
今回は、過去のセッションの記録とSerenaのログを突き合わせて、前回と同じ原因だとすぐ分かりました。

バージョンを固定する設定は、期限切れを避けるためのものではなく、新しいビルドに追随するためのものです。
自動で最新に追随してくれるわけではないので、「Serenaが急に動かなくなったら、まずログで `expired` を探す」と覚えておくのがよさそうです。

JetBrainsが言うように、`kotlin-server` が安定して期限が廃止される日が来れば、この問題は解消されるはずです。
それまでは、約1か月ごとにバージョンを書き換えることになりそうです。
