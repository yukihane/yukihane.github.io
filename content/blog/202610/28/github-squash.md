---
title: "GitHubのSquash & Mergeには考えているほどのメリットはないのかも？"
date: 2026-10-28T00:37:12+09:00
tags: ["git", "github"]
draft: true
---

私はずっとGitHubのSquash and merge方式(以降squash方式と呼称)を採用している人/組織が、Create a merge commit方式(以降merge commit方式と呼称)よりもsquash方式を好む理由って、何を差し置いてもマージ後のコミット履歴がすっきりすることに価値がある、という美意識が理由だと思っていました。

しかし、もしかするとmerge commit方式では実現不可能、あるいは非常に煩雑な操作を行わなければならないことが、squash方式だと解決できると考えている可能性もあることに気づきました。

例えば、「PR単位で履歴を見たい」「PRをまとめてrevertしたい」という理由です。
これらはmerge commit方式でも、Gitの標準機能で実現できます。
しかも、作業中のコミットを事前にきれいに整理しておく必要もありません。

もしこのあたりに誤解があるのなら、

- squash方式のメリットとして挙げられる操作の多くは、merge commit方式でもできる
- むしろ、merge commit方式では必要ない手間がsquash方式では発生することがある

という説明をしたいと考えたのがこの記事の主旨です。

もちろん、途中のコミットをmainの履歴に残さないこと自体が目的なら、両方式には違いがあります。
その違いと、履歴を読む・操作する上での違いを分けて考えてみます。

以下のコマンドと後述のコンフリクトの例は、Git `2.56.0` のローカルリポジトリで確認しました。

## squash方式でしかできないことがある、という誤解について

AIにsquash方式を推している記事を検索し、主張をまとめてほしい、と指示しました。
調査メモには日本語11件・英語14件の計25件が集まりました(比較記事も1件含みます)。
ただし、推奨する記事を中心に集めたものなので、世の中の意見の割合を示すような調査ではありません。

そのうち、この記事を書く際に本文を確認した代表例は次のとおりです。
右欄は私による要約です。

| 記事 | squash方式を選ぶ理由として挙げられていること |
|---|---|
| [featureブランチのGitマージは頼むからSquashを使ってくれ](https://qiita.com/hondaYoshitaka/items/e2c961dc820df8d5705c) | 個人の作業記録をツリーから除き、ApproveされたPRの単位で見やすくする |
| [GitHub のマージ方式を人間に毎回選ばせるのは、もうやめよう（やめた）](https://www.m3tech.blog/entry/github-auto-merge) | blameなどで変更を追う際、PR単位の粒度で履歴が並ぶ方が追いやすい |
| [My preferred merge strategy for Pull Requests](https://dev.to/igorsantos07/my-preferred-merge-strategy-for-pull-requests-1lo5) | 平坦な履歴にし、途中のコミットがblameを煩雑にすることを避ける |
| [Two years of squash merge](https://blog.dnsimple.com/2019/01/two-years-of-squash-merge/) | 変更の意図が分かる履歴にし、作業の自由度を保ち、revertを簡単にする |
| [To Squash or Not to Squash: The Merge Debate](https://spin.atomicobject.com/squash-merge/) | コミットの整理やrebaseの負担を減らし、履歴を読みやすくする |

なお、これらは必ずしも「どんなブランチでもsquashすべき」と主張している記事ではありません。
例えば最初の記事は個人のfeatureブランチに対象を限っていますし、エムスリーの記事でもprotectedブランチやepicブランチからのPRはsquashしない運用です。

読んでいて気になったのは、**履歴をPR単位で扱うことと、途中のコミットを履歴から除くことが、一緒に語られがち**な点です。
前者だけが目的なら、merge commit方式でもできることがかなりあります。

### PR単位で履歴を見る: git log --first-parent

例えば、次のようにfeatureブランチをmainへマージしたとします。
図では左から右に時間が進み、main側の横線をマージコミットの第1親とします。

```text
      A1---A2---A3
     /           \
O-----------------M    main
```

`A1`〜`A3` はPR内の作業コミット、`M` はマージコミットです。
ここで普通に `git log main` を実行すると、作業コミットも出てきます。

しかし、次のようにすればmain側の履歴だけをたどれます。

```sh
git log --first-parent --oneline main
```

この図なら、表示対象は `M` と `O` です。
`A1`〜`A3` がWIPやtypo修正ばかりでも、ここには出てきません。

`--first-parent` は、マージコミットに出会ったときに第1親だけをたどるオプションです。
通常、mainにfeatureをマージしたコミットの第1親は、マージ直前のmainです。[git-logの公式ドキュメント](https://git-scm.com/docs/git-log#Documentation/git-log.txt---first-parent)

GitHubのCreate a merge commitは `--no-ff` によるマージなので、PRごとにマージコミットが作られます。
mainへの取り込みをこの方式に統一していれば、mainのfirst-parentをたどることで、PRの取り込み単位の履歴を見られます。[GitHubの公式ドキュメント](https://docs.github.com/en/pull-requests/reference/pull-request-merges)

つまり、「履歴をPR単位で見たい」というだけなら、途中のコミットをsquashする必要はありません。

なお、この説明はmainをチェックアウトしてfeatureをマージする、という親の向きが揃っていることを前提にしています。
ローカルで逆向きにマージしてmainをfast-forwardした場合など、どんな履歴でも自動的にPR単位になるわけではありません。

### PR全体の差分を見る

履歴だけでなく、差分もPR単位で見られます。

```sh
git log --first-parent -p main
```

確認したGitでは、`--first-parent` を付けると、マージコミットの差分も第1親との比較で表示されます。
明示するなら次の書き方です。[git-logの差分表示オプション](https://git-scm.com/docs/git-log#Documentation/git-log.txt---diff-mergesfirst-parent)

```sh
git log --first-parent --diff-merges=first-parent -p main
```

特定のマージコミットだけを見たいなら、マージ前後を直接比較してもよいです。
以下の `MERGE_COMMIT` は実際のコミットIDに置き換えます。

```sh
git diff MERGE_COMMIT^1 MERGE_COMMIT
```

`^1` は第1親です。
これなら、mainへそのPRを取り込むことで何が変わったのかを、コンフリクト解消の結果も含めて確認できます。

### PR単位でblameする: git blame --first-parent

`git log --first-parent` は知っていても、blameにも同じオプションがあることは知らない、という人はいるかもしれません。

```sh
git blame --first-parent main -- path/to/file
```

通常のblameでは、featureブランチ内でその行を変更したコミットまでさかのぼります。
`--first-parent` を付けると、その行がmainへ入った時点を調べられます。
先ほどの図でfeature側から追加された行なら、作業コミットではなく `M` に帰属します。[git-blameの公式ドキュメント](https://git-scm.com/docs/git-blame#Documentation/git-blame.txt---first-parent)

したがって、merge commit方式でも、

- 普段はPR単位で変更の導入元を調べる
- 必要になったら通常のblameで個別の作業コミットまで調べる

という使い分けができます。

前掲の [My preferred merge strategy for Pull Requests](https://dev.to/igorsantos07/my-preferred-merge-strategy-for-pull-requests-1lo5) には、ツールやオプションで途中のコミットを無視できても、blameでは無理か、少なくとも煩雑になるだろう、という趣旨の記述があります。
しかし、少なくとも現在のGitなら、この目的のためのオプションが用意されています。

### PR単位でbisectする: git bisect start --first-parent

「作業途中の壊れたコミットがbisectの対象になる」という問題も、同じ考え方で対処できます。

```sh
# BAD_COMMITは問題のあるmainのコミット、GOOD_COMMITは正常だったコミット
git bisect start --first-parent BAD_COMMIT GOOD_COMMIT

# 選ばれたコミットでテストし、結果に応じてどちらかを実行する
git bisect good
# または git bisect bad

# 調査が終わったら元の状態に戻る
git bisect reset
```

これならmainのfirst-parent上を探索するので、featureブランチ内の未完成なコミットをテストする必要はありません。
公式ドキュメントでも、マージされたブランチにビルドできないコミットが含まれている場合に有用だと説明されています。[git-bisectの公式ドキュメント](https://git-scm.com/docs/git-bisect#Documentation/git-bisect.txt---first-parent)

また、merge commit方式なら、原因のPRが分かった後に、そのPR内のコミットをさらに調べる余地も残ります。
途中のコミットがテスト可能とは限らないので、必ず細かくbisectできるという意味ではありませんが。

「mainの各時点がレビュー済み・CI通過済みになる」という話も、ここで区別した方がよさそうです。
merge commit方式では作業コミットもmainから到達可能ですが、mainのfirst-parent上の各取り込み時点とは別です。
マージ結果に対して必要なレビュー・CIを要求する運用なら、後者を検証済みの状態として扱えます。
squashしただけでCI通過が保証されるわけでもなく、どの状態を検証してから取り込むかは別途決める必要があります。

### PR全体をrevert・cherry-pickする

「PRを1コミットにまとめると、一度のrevertで戻せる」というメリットもよく挙がります。
しかし、マージコミットも一度でrevertできます。

```sh
git revert -m 1 MERGE_COMMIT
```

`-m 1` は、第1親を基準に変更を打ち消す指定です。
PR内のコミットを1つずつrevertする必要はありません。[git-revertの公式ドキュメント](https://git-scm.com/docs/git-revert#Documentation/git-revert.txt--mparent-number)

別のブランチへPR全体の変更を持っていく場合も同様です。

```sh
git cherry-pick -m 1 MERGE_COMMIT
```

こちらは、第1親からマージ結果への差分を適用します。[git-cherry-pickの公式ドキュメント](https://git-scm.com/docs/git-cherry-pick#Documentation/git-cherry-pick.txt--mparent-number)

もちろん、後続の変更とのコンフリクトはどちらの方式でも起こり得ます。
また、merge commitをrevertしても「マージした」という履歴は残るので、同じブランチをもう一度マージするだけでは変更は復活しません。
再導入するときはrevertのrevertなどを考える必要があります。この点もgit-revertのドキュメントに注意書きがあります。

ただ、「PR内のコミットが複数あると、まとめて戻したり移したりできない」ということではありません。

### 作業コミットをきれいにする必要はあるのか

ここまでの操作に、作業コミットの整理は必要ありません。
mainのfirst-parentを見る限り、途中にWIPが何個あっても、表に出るのは取り込み時のマージコミットです。

そのマージコミットにPRのタイトル・番号や変更の理由を残せば、PR単位の説明と差分を対応させられます。
squash commitのメッセージに気を配るのと同じように、マージコミットのメッセージに気を配ればよいです。

「merge commit方式を採用するなら、全員にrebaseで完璧なコミット列を作ってもらわなければならない」というのは、少なくとも上記の用途では前提になりません。
途中の履歴まで読みやすく保つことをチームの要件にするなら別ですが、それは追加の運用方針です。

## それでもsquash方式に残るメリット

では、両方式に違いはないのかというと、そうではありません。

merge commit方式では、WIPなどのコミットは表示から隠れるだけで、mainからたどれる履歴には残ります。
「後で必要になったら詳しく調べられる」と考えるか、「不要な作業記録が残ってしまう」と考えるかは、方針の違いです。
squash方式なら、途中のコミットはmainの祖先にはなりません。

また、ここまではGitのコマンドを使う話でした。
GitHubのWeb画面や普段使っているGUI・IDEで、同じ見方を簡単に選べるとは限りません。
何もオプションを付けず、誰がどの画面から見てもPR単位で並んでほしい、という要求にsquash方式が合うことはあると思います。

私としては、mainの履歴を読む際に `--first-parent` を付ける程度なら、それほど大きな負担ではないと感じます。
しかし、チーム全員がCLIを使うわけではない、という事情もあるでしょう。

したがって、調べた記事に `--first-parent` が出てこないからといって、筆者が機能を知らないと断定することもできません。
知った上で、普段使うツールでの操作の少なさを選んでいる可能性もあります。

ただ、「merge commit方式ではできない」ことと「普段使う画面ではsquash方式の方が楽」なことは、分けて説明してほしいと思います。

## squash方式で問題があるシチュエーション

ここからは、squash方式にすることで増える手間についてです。
以下は特定のプロジェクトの事例ではなく、説明用の例です。

### 先行PRに依存するPRがある

mainからブランチAを作り、そのAからブランチBを作ったとします。
Bの実装はAに依存しているので、Aのレビュー完了を待つ間にもBを進めたい、という状況です。

```text
O                     main
 \
  A1---A2             feature-a
         \
          B1---B2     feature-b
```

Aをmerge commit方式でmainへ入れると、こうなります。

```text
O----------M          main
 \        /
  A1---A2             feature-a
         \
          B1---B2     feature-b
```

`A2` はmainの祖先になります。
したがって、Bをmainへマージするときには、Aまでがすでに取り込まれていることをGitが認識できます。
Aの取り込み後にmain側で何も変わっていなければ、Bの取り込みで新たに加わるのはBの変更です。

一方、Aをsquashした場合は次のようになります。

```text
O----------S          main
 \
  A1---A2             feature-a
         \
          B1---B2     feature-b
```

`S` はAの変更をまとめた新しいコミットです。
内容が同じでも、`A2` と同じコミットではなく、`A2` はmainの祖先になりません。
mainとBの共通祖先は、この例では依然として `O` です。

この状態でも、mainの内容がAと同じままならBを問題なくマージできることはあります。
**squashしたら必ずコンフリクトする、という話ではありません。**
しかし、main側でその後変更があると、Aの変更まで再び比較の対象になり、余計なコンフリクトが起こり得ます。

### Bでは触っていない行でコンフリクトする例

例えば次の順番で変更した場合です。

| 時点 | value.txtの内容 | B独自の変更 |
|---|---|---|
| 分岐前のO | `value=0` | なし |
| Aの実装完了時点 | `value=2` | なし |
| AからBを分岐して作業 | `value=2` | 別ファイルb.txtを追加 |
| Aをmainに取り込んだ後、mainで修正 | `value=3` | mainにはまだ入っていない |

Bでは `value.txt` を一切変更していません。
それでも、Aをsquashしていると、Bにmainをマージした際に `value=2` と `value=3` が衝突します。
共通祖先が `value=0` なので、Gitからは「両方のブランチが同じ行を別々に変更した」と見えるためです。

Aをmerge commit方式で取り込んでいれば、共通祖先はAの末尾になり、その時点の値は `value=2` です。
B側ではそこから変えていないので、mainの `value=3` をそのまま取り込めます。

手元では、次の手順でsquash方式のコンフリクトを再現できました。
空の作業ディレクトリで実行する例です。コミット用のuser.name・user.emailは設定済みとします。

```sh
git init -b main
printf 'value=0\n' > value.txt
git add value.txt
git commit -m 'Initial'

git switch -c feature-a
printf 'value=2\n' > value.txt
git commit -am 'Implement A'

git switch -c feature-b
printf 'B\n' > b.txt
git add b.txt
git commit -m 'Implement B'

git switch main
git merge --squash feature-a
git commit -m 'Squash A'
printf 'value=3\n' > value.txt
git commit -am 'Update value on main'

git switch feature-b
git merge main
# CONFLICT (content): Merge conflict in value.txt
```

別の空ディレクトリで、Aを取り込む2行を次の1行に置き換えて同じ手順を試すと、コンフリクトせずに `value=3` を取り込めます。

```sh
git merge --no-ff feature-a -m 'Merge A'
```

これはBが長寿命だから起きる、というより、squashで祖先関係がつながらないことによる問題です。
短い期間の作業でも、依存先のマージ後にmainで変更があれば起こり得ます。

### squash後はBの変更だけを載せ替える必要がある

先ほどのような問題を避けるには、Aのsquash後に、B独自の変更だけを新しいmainへ載せ替える方法があります。

```sh
# A_TIPは、Bに含まれているAの末尾コミットのID
git rebase --onto main A_TIP feature-b
```

これなら `A1`・`A2` を再適用せず、`B1`・`B2` だけを新しいmainの上へ載せられます。
単に `git rebase main` とするのとは、再適用する範囲の指定が違います。
このように分岐元を変更する例は、[git-rebaseの公式ドキュメント](https://git-scm.com/docs/git-rebase#_transplanting_a_topic_branch_with_onto)にも載っています。
上の再現例の直後なら、まず `git merge --abort` で失敗したマージを中止し、`A_TIP` に `feature-a` を指定して実行できます。

ただし、BのコミットIDは変わります。
すでに共有しているブランチなら、利用者との調整や、リモートの履歴を更新する作業が必要になります。
また、B独自の変更とmainの変更が本当に衝突している場合は、rebaseでも解消作業が必要です。

直列のstackであれば、この載せ替えをツールで自動化することもできます。
それは有用だと思いますが、merge commit方式なら祖先関係を保ったまま進められるところに、載せ替えとその管理が加わっていることには変わりません。

なお、squash方式でも、作業ブランチへmainをマージする運用は可能です。
ただし上の例のような解消作業が必要になり得ますし、作業ブランチも常に線形に保つ方針なら、その方法は選べません。
「mainへの取り込みはsquash」と「作業ブランチでもmergeを禁止」は、別の制約です。

### 複数の未マージPRに依存する作業

さらに、次のような場合も考えられます。

- PR Aで追加するAPIを使いたい
- PR Bで追加するデータ構造も使いたい
- AとBは独立してレビューされ、別々にmainへ入る予定
- 両方を使うPR Cの実装を、先に進めたい

Cの作業ブランチにAとBをmergeしておけば、両方を使って実装できます。
その後AとBがmainへmerge commit方式で入れば、mainとCの双方がA・Bのコミットを祖先として持ちます。
取り込み済みの依存部分と、C独自の変更を区別するために、コミットを載せ替える必要はありません。
もちろん、並行した実装どうしの本当の競合までなくなるわけではありません。

squash方式だと、AとBの元のコミットはmainの祖先になりません。
どちらが先にmainへ入り、どの変更が残っているかを見ながら、依存部分を組み直す必要が出てきます。
マージを含むCの履歴を、そのまま直列のstack向けの手順でrebaseすれば済む、という形ではありません。

A→B→Cと直列に並べ直すことはできますが、本来独立しているAとBに順序を付けることになります。
先に小さなPRをmainへ入れる、機能フラグで分割する、といった設計上の工夫が可能ならそれも選択肢です。
ただ、そのために作業の進め方を変える必要があること自体は、方式を比較するときに考慮したいです。

### 実装の経緯を差分と一緒に追いにくくなる

もう1つは、途中のコミットを残すこと自体に価値がある場合です。

例えば、ある機能を既存実装に合わせて作った後、レビューで仕様の解釈が違うと分かり、判定条件を修正したとします。

```text
A1: 既存実装に合わせて機能を追加
A2: 仕様の確認結果に合わせて判定条件を修正
A3: レビュー指摘の命名を修正
```

後から「なぜこの機能だけ既存実装と条件が違うのか」を調べるとき、`A2` の差分とコミットメッセージを一緒に読めると助かります。
最終的なPR全体の差分だけでは、一度既存実装に合わせてから変更したことは分かりません。

squash commitに全コミットのメッセージを残したり、PRへのリンクを残したりすれば、情報の一部は保てます。
GitHub上のPRから元のコミットをたどれる場合もあるので、「squashするとすべての経緯が消える」という主張ではありません。

それでも、mainをcloneして調べるだけでは、個別コミットの差分と理由を対応させて追えなくなります。
履歴の調査がGitHub上のPRに依存することと、Gitの履歴の中で完結することには違いがあります。

merge commit方式なら、普段はfirst-parentで概要を読み、必要なときだけ途中のコミットへ降りていけます。
私は、この選択肢が残っていることに価値を感じます。

## まとめ

squash方式のメリットとしてよく挙げられる操作と、merge commit方式での対応をまとめると、次のようになります。

| やりたいこと | merge commit方式での操作 |
|---|---|
| PR単位で履歴を見る | `git log --first-parent` |
| PR単位で差分を見る | `git log --first-parent -p` |
| 行がどのPRでmainに入ったかを調べる | `git blame --first-parent` |
| PRの取り込み単位で不具合を絞る | `git bisect start --first-parent` |
| PR全体をrevertする | `git revert -m 1` |
| PR全体の変更を別ブランチへ移す | `git cherry-pick -m 1` |

これらが使えるなら、履歴をPR単位で扱うために途中のコミットを除く必要はありません。
途中のコミットの整理を全員に義務付ける必要もありません。

一方で、squash方式には、何も指定せずにPR単位の履歴を見られることや、作業コミットをmainの祖先に残さない、という違いがあります。
そこに価値を感じて選ぶのなら、理解できます。

ただ、そのために依存ブランチの載せ替えを管理したり、過去の個別差分の調査をGitHubのPRに頼ったりすることまで含めて考えると、私はmerge commit方式を選びたいです。
履歴をすっきり読む方法を知った上でも、途中の履歴を残さない方がよいのか。その点を確認してから、squash方式を選んでもよいのではないでしょうか。
