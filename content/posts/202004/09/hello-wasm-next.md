---
title: rustでwasmでhello, world(2020-04-08版) の次
date: 2020-04-09T20:52:10Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [rust, wasm]
# images: []
# videos: []
# audio: []
draft: false
---

# 目標

[rust で wasm で hello, world](https://qiita.com/yukihane/items/66679cbe076f0bb3a962)の次として、JavaScript で実装されたプロジェクトを Rust に書き直してみます。

最近[N 予備校のプログラミング入門 Web アプリコース](https://www.nnn.ed.nico/pages/programming/)を始めたのでそれを題材にします。

- https://www.nnn.ed.nico/courses/668/chapters/9514

このへんで作っているもので、完成版のコードは

- https://github.com/progedu/assessment-for-download

にあります。

# プロジェクト作成

[前回](https://qiita.com/yukihane/items/66679cbe076f0bb3a962)の通り。

    npm init rust-webpack assessment
    cd assessment

# 元ファイルコピー

```
curl -L -o static/assessment.css https://raw.githubusercontent.com/progedu/assessment-for-download/master/assessment.css
curl -L -o static/assessment.html https://raw.githubusercontent.com/progedu/assessment-for-download/master/assessment.html
curl -L -o js/assessment.js https://raw.githubusercontent.com/progedu/assessment-for-download/master/assessment.js
```

# 実行してみる

`assessmment.html` を開きたいので `webpack.config.js` に[設定を追加](https://webpack.js.org/configuration/dev-server/#devserveropenpage)します:

```
module.exports = {
  //...
  devServer: {
    openPage: '/assessment.html'
  }
};
```

編集がおわったらコマンド実行:

    yarn start

"あなたのいいところ診断"ページが表示されれば OK。ただし devtools の console を見ると `assessment.js` が読み込めていません。

# `asessment`関数を Rust に移植

`src/lib.rs`:

```
const ANSWERS :[&str;16] = [
  "{userName}のいいところは声です。{userName}の特徴的な声は皆を惹きつけ、心に残ります。",
  "{userName}のいいところはまなざしです。{userName}に見つめられた人は、気になって仕方がないでしょう。",
  "{userName}のいいところは情熱です。{userName}の情熱に周りの人は感化されます。",
  "{userName}のいいところは厳しさです。{userName}の厳しさがものごとをいつも成功に導きます。",
  "{userName}のいいところは知識です。博識な{userName}を多くの人が頼りにしています。",
  "{userName}のいいところはユニークさです。{userName}だけのその特徴が皆を楽しくさせます。",
  "{userName}のいいところは用心深さです。{userName}の洞察に、多くの人が助けられます。",
  "{userName}のいいところは見た目です。内側から溢れ出る{userName}の良さに皆が気を惹かれます。",
  "{userName}のいいところは決断力です。{userName}がする決断にいつも助けられる人がいます。",
  "{userName}のいいところは思いやりです。{userName}に気をかけてもらった多くの人が感謝しています。",
  "{userName}のいいところは感受性です。{userName}が感じたことに皆が共感し、わかりあうことができます。",
  "{userName}のいいところは節度です。強引すぎない{userName}の考えに皆が感謝しています。",
  "{userName}のいいところは好奇心です。新しいことに向かっていく{userName}の心構えが多くの人に魅力的に映ります。",
  "{userName}のいいところは気配りです。{userName}の配慮が多くの人を救っています。",
  "{userName}のいいところはその全てです。ありのままの{userName}自身がいいところなのです。",
  "{userName}のいいところは自制心です。やばいと思ったときにしっかりと衝動を抑えられる{userName}が皆から評価されています。"
];

#[wasm_bindgen]
pub fn assessment(user_name: &str) -> String {
  let sum: u32 = user_name.chars().map(|x| x as u32).sum();
  let index = (sum % (ANSWERS.len() as u32)) as usize;

  ANSWERS[index].replace("{userName}", user_name)
}
```

# js 実装

`assessment.js`という名前をそのまま使う方法がわからなかったので仕方なく `index.js` の方で実装しました。
`assessment`関数以外の部分をコピペして `assessment.js` は削除します。
ただし `assessment`関数は Rust 側で実装したものを呼び出すように変更します。

```
import("../pkg/index.js").then(module => {
...
        const result = module.assessment(userName);
```

そして `assessment.html` は `assessment.js` でなく `index.js` を読むようにします。

```
<script src="index.js"></script>
```

`index.html` は不要なので削除します。

# 実行

編集は以上です。実行してみます:

    yarn start

配布するまでにはまだひと手間かかりそうだけれども、取り敢えずここまで。

# 実装コード

- https://github.com/yukihane/hello-js/tree/master/nnn.ed.nico/webapp-primer-2020-rust/assessment
