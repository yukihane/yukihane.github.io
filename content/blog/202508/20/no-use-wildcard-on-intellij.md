---
title: "IntelliJの自動整形でimportのwildcardを使わないようにする"
date: 2025-08-20T19:48:29+09:00
tags: ["kotlin"]
draft: false
---

[前回のエントリー](/blog/202507/21/status-report) では休職について記載しましたが、現在、無事職に着くことができています。

さて、そのプロジェクトでの話ですが、CIでKotlinコードに対して[ktlint](https://pinterest.github.io/ktlint/latest/)でソースコードのチェックを行っています。
ルールは(ほぼ)デフォルト設定を用いているのですが、このデフォルト設定とIntelliJ IDEAのデフォルト設定が競合するルールがあります。
つまり、IntelliJ IDEAの設定でフォーマットをかけると、CIが失敗してしまいます。

具体的に引っかかったのは、タイトルにある通り、importのwildcard(`*`)利用です。
IntelliJ IDEAのデフォルト設定では、5個以上同じパッケージのクラスをimportしようとした場合に `*` でまとめられます(Editor > Code Style > Kotlin > Imports 設定より)。

しかし、ktlintのデフォルト設定では [standard:no-wildcard-imports](https://pinterest.github.io/ktlint/1.7.1/rules/standard/#no-wildcard-imports)が有効になっており、wildcard利用は禁止されています。

なので、IntelliJ IDEAの設定を変えないといけないのか、と思っていたのですが、ktlintの公式ドキュメントに対応方法が書いてありました。

- [Intellij IDEA configuration](https://pinterest.github.io/ktlint/1.7.1/rules/configuration-intellij-idea/)

ということで、 `.editorconfig` にリンク先の通り設定を行うか、 ktlint-intellij-plugin をインストールすればktlint設定の通り整形してくれるようです。

ちなみに、ktlint関係なしにimportの `*` を使わないようにしたい場合は、前述の設定 Editor > Code Style > Kotlin > Imports で値を極端に大きく設定すれば良さそうです。
