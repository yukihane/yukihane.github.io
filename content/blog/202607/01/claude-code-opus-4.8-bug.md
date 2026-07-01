---
title: "Claude Code + Opus 4.8 で tool call が壊れるバグがいつまで経っても直らない"
date: 2026-07-01T09:39:21+09:00
tags: ["ai-coding", "claude-code"]
draft: false
---

Claude Code で Opus 4.8 (1M context) を使っていると、ツールコールが壊れて処理が止まるバグに頻繁に遭遇します。

この問題は 2026 年 5 月末から報告され始め、7 月に入った現在もまだ修正されていません。自分も何度も遭遇しているので、関連 issue をまとめておきます。

## 症状

セッション中に突然、以下のようなエラーが表示されて処理が止まります。

> Your tool call was malformed and could not be parsed. Please retry.

または、リトライも失敗して完全に止まるパターンもあります。

> The model's tool call could not be parsed (retry also failed).

ユーザーから見ると、Claude がしばらく考えたあと **何も起こらずに沈黙する** ように見えます。ツールは実行されず、テキストの応答も表示されません。手動で再度プロンプトを送り直す必要があります。

## 原因

モデルが `stop_reason: tool_use` で応答を終了しているにもかかわらず、レスポンス中に構造化された `tool_use` ブロックが含まれていない、というのが直接の原因です。

より具体的には、Opus 4.8 がツールコールを構造化 JSON ではなく、レガシーの `<invoke name="...">` という XML 形式で出力してしまい、かつ `antml:` 名前空間プレフィックスが欠落しているため、パーサーが拒否する、という現象が起きています ([#64658](https://github.com/anthropics/claude-code/issues/64658))。

さらに厄介なのは、一度壊れた XML がコンテキストに残ると、モデルがそのパターンを繰り返しやすくなる（自己強化する）という報告もある点です ([#72015](https://github.com/anthropics/claude-code/issues/72015))。セッションが長くなるほど悪化していきます。

## 悪化しやすい条件

複数の issue から共通して報告されている悪化条件は以下の通りです。

- **1M context モード**での長いセッション
- **xhigh effort** の設定
- **非 ASCII 文字**（日本語、韓国語、中国語などの CJK 文字）を多く含むセッション
- ツール密度が高い（MCP ツールを大量に使う）セッション
- `Write` / `Edit` など引数が大きいツールコール

## Opus 4.7 では起きない

複数の報告者が、同じセッション・同じプロンプトで **Opus 4.7 に切り替えると問題が解消する** ことを確認しています ([#63604](https://github.com/anthropics/claude-code/issues/63604), [#64658](https://github.com/anthropics/claude-code/issues/64658))。これは Opus 4.8 固有のリグレッションです。

ただし、Opus 4.7 でも 2026-05-20 頃に一時的に同様の問題が発生した報告があります ([#61133](https://github.com/anthropics/claude-code/issues/61133))。この issue では、thinking ブロックのシグネチャをデコードして内部モデル名が `claude-quoll-v7-hr-fast-ab-high-p` に変わったタイミングと障害発生が一致していることが示されており、サーバーサイドのモデル入れ替えが原因だった可能性があります。この issue は現在 CLOSED になっています。

## 関連 issue 一覧

| Issue | タイトル | 状態 |
|---|---|---|
| [#72015](https://github.com/anthropics/claude-code/issues/72015) | Opus 4.8 (1M) が legacy `<invoke>` XML を出力、長い非 ASCII セッションで自己強化 | Open |
| [#64235](https://github.com/anthropics/claude-code/issues/64235) | 2026-05-29 以降のリグレッション、トランスクリプトレベルの詳細分析 | Open |
| [#63604](https://github.com/anthropics/claude-code/issues/63604) | Opus 4.8 で malformed tool_use、テキストブロックごと破棄される問題 | Open |
| [#64658](https://github.com/anthropics/claude-code/issues/64658) | Desktop アプリ (Code タブ) でも再現、CJK テキストとの相関 | Open |
| [#63875](https://github.com/anthropics/claude-code/issues/63875) | Windows 環境での報告、大きい引数・特殊文字との相関 | Open |
| [#62123](https://github.com/anthropics/claude-code/issues/62123) | Opus 4.7 での多発報告（日本語環境） | Open |
| [#61133](https://github.com/anthropics/claude-code/issues/61133) | Opus 4.7 での発生、内部モデル名変更との相関分析 | Closed |

## 現状の回避策

確実な回避策はありませんが、以下の対処で発生頻度を下げられる可能性があります。

- **Opus 4.7 を使う**: 最も確実な回避策ですが、4.8 の性能向上を享受できません
    - `/model claude-opus-4-7[1m]`
- **セッションをこまめにリセットする**: コンテキストの蓄積を防ぎ、自己強化ループを避けます
- **effort を下げる**: xhigh ではなく high 以下にする

個人的には、長いセッションで Opus 4.8 を使い続けるのは現状リスクが高いと感じています。壊れ始めるとそのセッションでは回復しにくいので、早めにセッションを切り替えるのが実用的な対処です。

## 所感

[以前の記事]({{< relref "/blog/202605/20/current-ai-coding" >}})でも書いた通り、普段から Opus 4.8 と 4.7 / 4.6 を使い分けていますが、このバグのせいで 4.8 の利用を躊躇する場面が増えています。

ツールコールが壊れると、そのターンの作業が丸ごとロストするだけでなく、壊れたレスポンスがコンテキストに残ることで後続のターンも巻き込まれるという二重の被害があります。特に日本語環境で顕著に発生するという報告が複数あり、日本語話者としては早急に修正してほしいところです。

issue は 5 月末から積み上がっていますが、Anthropic からの公式な対応状況のコメントは確認できていません。続報があれば追記します。
