---
title: "Git"
date: 2020-07-26T03:10:06Z
draft: false
---

# オンラインマニュアル

<https://git-scm.com/docs>

# password記憶

    git config --global credential.helper 'cache --timeout=21600'

21600秒(6時間)デーモンがパスワードを保持する。

# 単語単位diff

    git config --global alias.diffw "diff --word-diff-regex=."

上記で日本語が文字化けする場合は、代わりに以下の設定でいける、はず。

    git config --global diff.wordRegex $'[^\x80-\xbf][\x80-\xbf]*'
    git config --global alias.diffw "diff --word-diff"

参考: [Gitで日本語長文のdiffをとる方法 - Qiita](https://qiita.com/skoji/items/28f1d6582cf81638cd3f)

# logの1行簡易なカスタム表示

    git config --global alias.logshort 'log --pretty=format:"%h %an %ai %s"'

# 枝分けを行った最初のポイントを見つける

\`zsh\`があることが前提になっているので、例えばWindowsのgit bash環境などでは動かない。 その場合は後述の同名節記載のコマンドで代替すれば良い。

    git config --global alias.oldest-ancestor '!zsh -c '\''diff -u <(git rev-list --first-parent "${1:-master}") <(git rev-list --first-parent "${2:-HEAD}") | sed -ne "s/^ //p" | head -1'\'' -'

# 枝分けを行った最初のポイントを見つける

    diff -u <(git rev-list --first-parent topic) \
                 <(git rev-list --first-parent master) | \
         sed -ne 's/^ //p' | head -1

ちなみに\`\<(…​)\`という書き方はProcess Substitution[^1]という。

- [Finding a branch point with Git? - Stack Overflow](http://stackoverflow.com/questions/1527234/finding-a-branch-point-with-git)

# stats

<https://github.com/arzzen/git-quick-stats>

実行例

    _GIT_SINCE=today.0:00am git quick-stats detailedGitStats

# excel の diff をとる

- <http://qiita.com/shuhei/items/6a18d968051378d7ac1a>

- <https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%82%AB%E3%82%B9%E3%82%BF%E3%83%9E%E3%82%A4%E3%82%BA-Git-%E3%81%AE%E5%B1%9E%E6%80%A7>

[Apache Tika](https://tika.apache.org/)を利用する。

tikaコマンドをpathの通った場所にインストールする:

    brew install tika

リポジトリ内の\`.gitattributes\`ファイル(他者と共有してしまって良い場合)、あるいは\`YOUR_REPO/.git/info/attributes\`(設定するのは自分だけなので共有してはまずい場合)に次のように記述する:

    *.xlsx diff=excel

`~/bin/`(等、パスの通った場所)に次のように記述したファイル\`tika-text\`を作成する。

    #!/bin/bash
    tika -t "$1"

また、上記ファイルに実行権限を付与する。

次のコマンドを実行し、\`~/.gitconfig\`ファイルに設定を追記する:

    git config --global diff.excel.textconv tika-text

補足:

- tikaをhomebrewでインストールしない場合は、tika-app-x.x.jar をダウンロードして `tika -t "$1"` の代わりに `java -jar tika-app-x.x.jar -t "$1"` とすれば良いはず。

- gitattributes ファイルの置き場所について - [git - Where should I place my global 'gitattributes' file? - Stack Overflow](https://stackoverflow.com/questions/28026767/where-should-i-place-my-global-gitattributes-file/)

# author を書き換える

<https://help.github.com/articles/changing-author-info/>

[^1]: <https://www.gnu.org/software/bash/manual/html_node/Process-Substitution.html>
