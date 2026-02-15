---
title: "Git の merge も思いの外危険"
date: 2021-05-18T23:01:49Z
draft: false
tags:
  - git
---

次のblogエントリがバズっていました:

- [Gitのワークフローについての私のスタンス \| おそらくはそれさえも平凡な日々](https://songmu.jp/riji/entry/2021-05-19-my-git-workflow.html)

大局としては同意なのですが、ミクロな点では、 `rebase` 恐怖症というか、 `merge` を信頼し過ぎているというか、少し私とは意見が異なると感じました。 そして、上記のblogのような意見が多数派ではないかと思いますので、改めて `merge` の怖いところを具体例で示したいと思います。

次のようにGitを操作してみてください。

``` bash
#!/bin/bash

set -eux

mkdir sample-git
cd sample-git
git init
git commit --allow-empty -m init

# master で hello.txt 作成
echo 'Hello, world!' > hello.txt
git add hello.txt && git commit -m 'create hello.txt'

# feature で hello.txt 削除、 bye.txt 作成
git checkout -b feature
git rm hello.txt
echo 'さようなら、世界！' > bye.txt
git add bye.txt && git commit -m 'remove hello.txt and create bye.txt'

# master に feature を merge
# ...をしたつもりだが...
git checkout master
git merge --no-ff --no-commit feature
git reset -- hello.txt
git -c core.editor=/bin/true merge --continue

git checkout -- .
```

`git-log` や履歴グラフでは `feature` で行った変更が `master` にマージされているように見えます。 が、実際にはそうなっておらず、 `master` では `feature` で削除した `hello.txt` が存在しています。

このように、 `merge` はぱっと見と実際が異なっている場合があるので注意を要します(このようなマージは、悪意が無くとも、 conflict が発生したときにポカミスとかでやってしまうことがあります)。
