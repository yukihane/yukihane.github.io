---
title: "これまでのAIコーディングの略歴、Codex Cli ファーストインプレッション"
date: 2025-10-26T13:29:34+09:00
tags: ["ai-coding"]
draft: false
---

最近はもっぱらAIを利用してコーディングしています。
が、blogにそういったことをまだ書いたことがなかったなあということで、記録を残そうと思った次第です。

## AI利用略歴

私は最先鋒でAI-codingを試しているわけではなくて、界隈で盛り上がってるな、というのを見て試し始める、くらいのスピード感です。
[イノベーター理論](https://ja.wikipedia.org/wiki/%E6%99%AE%E5%8F%8A%E5%AD%A6)でいうところのアーリーマジョリティーくらいかな？と自己を認識しています。

GitHub Copilot を利用し始めたのがおそらく2024-10-04で、その1ヶ月後に年間プランに入っています。

「[CLINEに全部賭けろ](https://zenn.dev/mizchi/articles/all-in-on-cline)」という記事が投稿されたのが 2025-02-26 であるのに対し、自分がClineを使い始めたのは [2025-04-04ごろ](https://x.com/yukihane/status/1908146157840404584) 。

その後[入院していて](/blog/202507/21/status-report/)、少しプログラミング環境から離れた後、 Claude Code は 2025-08-18 に仕事に復帰してから本格的に使い始めました。
(それまではCline用に購入していた従量課金のクレジット残額でちょこちょこ触っていた程度)
2025-08-29 にproプランじゃ仕事に使うには足りない、ということでmaxプランにアップグレードしています。

そして現在ですが、ちょうど私が本格的にClaude Codeを使い始めた頃でしょうか、世間ではClaude CodeよりCodex Cliの方が賢い！と話題になっています。
Claude Codeは仕事先に経費として請求できることになったので、自腹でCodex Cliを試してみよう、とplusプランを契約したのがこの記事を書いているちょうど1ヶ月前の 2025-09-25 になります。

なので、現在は、仕事ではClaude Codeを、プライベートではCodex Cliを利用している、ということになります。
GitHub Copilotもまだ契約期間内ですが、ほぼ存在を忘れています...

追記:
この記事を書いてから公開するまでに少し時間が空いてしまったので2026-01現在の状況を追記しておきます:

- Claude Code Max x5 プラン
- Chat GPT Plus プラン(Codex CLI用)
- Google AI Pro 年間プラン(Gemini CLI用; セールしていたので年契約)
- Perplexiy Pro 年間プラン(プログラミング用途には用いていない; paypalのプロモーションで無料だったので)

## これまでの感想

GitHub Copilot 使い始めた頃はこれは便利だ！ということで年間契約したのですが、トレンドが次々に変わるのをすぐ感じたので、それ以降は年間契約できるものも月額契約するようにしています。
おそらく多くの人もそうだと思いますが。

Clineは、私が使っていたころはVSCodeにしか対応していなくて、Kotlin on Intellij IDEAの開発がやや面倒でした。
自分はAIに書かせるときはVSCode上で、自分はIntelliJ IDEAで書く、ということをしていました。
VSCodeだとKotlin LSPが無いので他の言語と比較して不利、なんてことも言われていました。
当時の状況は下のスライドに詳しいです:

- [Kotlinの開発でも AIをいい感じに使いたい](https://speakerdeck.com/kohii00/making-the-most-of-ai-in-kotlin-development)

Claude Codeは、確か私が初めて触れたときはplan modeがまだ無くて、Clineには及ばないな…と感じた記憶があります。
その後、改めて触ったときにplan modeがあるのに気付き、ならKotlinも任せられるのでは…！と徐々にシフトしていきました。

私はplan modeが大好きです。
前述の通り世間ではCodex Cliの方が賢いといわれているのですが、Codexはplan mode相当の機能がなく、皆はその賢さをどうコントロールしているのか不思議でなりません。
また、Claude Cliはコンテキスト容量が小さいといわれており、それは確かに私も痛感していますが、世間で言われているほどcompactしたときに馬鹿になる、という感じもしていません。
私が扱っている対象コードの規模が比較的小さめということもあるでしょうが、世間の人とはAIの使い方が違っているのだろうな、とも感じています。
この辺りはSIerとしてプログラマーをマネージしていた経験が生きているのではないかな、と。

また、Claude Codeはデフォルト(少しの設定)でウェブ検索して実装を考えてくれるのに対し、Codex Cliはウェブ情報を見てくれる設定が無いんですかね？そのせいで、GIMP2 -> GIMP3 への [python-fu](https://github.com/yukihane/python-fu) マイグレーションを頼んだ時に、Claude Codeは一向に動く実装が作れませんでした。

...改めて調べてみると、Codex CliもWebSearchを有効化するオプションがありますね。そりゃそうか。
というわけで、次の記事ではもう少しちゃんとCodex Cliを使ってみた系のことを書こうかなと思います。

ちなみに、Codex Cliでplan modeを実現する提案は次にあります。workaroundについても書かれています。

- [Request: Plan Mode #2101](https://github.com/openai/codex/issues/2101)

追記:
こちらへも追記すると、ちょうどCodex CLIにもplan modeが導入されたようです。まだ使ってはいないので感想は書けませんが。

- [Codex CLI の v0.88.0 で plan mode (Collaboration mode)を使う -Zenn](https://zenn.dev/yorifuji/articles/ac6883cf8fac82)
- https://github.com/openai/codex/blob/main/codex-rs/core/templates/collaboration_mode/plan.md
