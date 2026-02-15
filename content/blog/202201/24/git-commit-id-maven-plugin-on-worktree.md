---
title: "git worktree を利用していると git-commit-id-maven-plugin でエラー"
date: 2022-01-24T11:11:35+09:00
draft: false
tags:
  - git
---

…​になりました。

- [Support of git worktree option (for JGIT) · Issue \#215 · git-commit-id/git-commit-id-maven-plugin · GitHub](https://github.com/git-commit-id/git-commit-id-maven-plugin/issues/215)

コマンドライン引数でスキップさせるには、 [\#278](https://github.com/git-commit-id/git-commit-id-maven-plugin/pull/278) で導入された `maven.gitcommitid.skip` オプション([現時点最新版の該当コードリンク](https://github.com/git-commit-id/git-commit-id-maven-plugin/blob/v5.0.0/src/main/java/pl/project13/maven/git/GitCommitIdMojo.java#L241-L251))を利用して、

    mvn -Dmaven.gitcommitid.skip package

などとすれば良さそうです。
