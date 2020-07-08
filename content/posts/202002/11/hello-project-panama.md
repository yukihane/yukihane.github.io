---
title: Hello Project Panama
date: 2020-02-11T20:43:43Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [java]
# images: []
# videos: []
# audio: []
draft: false
---

## はじめに

今個人的にすごく知りたいのはこちらです。ご回答よろしくお願いします！！！！

- [動的確保したメモリー領域の解放戦略](https://ja.stackoverflow.com/q/62868/2808) - スタック・オーバーフロー

(質問読んでもらえれば(というかタイトル見てもらえれば)わかると思うんですけど、別に Java がわからん、とか Rust がわからん、という質問では無いです。念の為。もちろん Java も Rust もわからない(多分コード正しくない)ですけどそれは別の話。)

## 目的

プログラミング言語 Rust を勉強したいと考えているのですが、自転車本を頭からスルッと読んだは良いものの全然身についていなくて、取り敢えず何か応用アプリ作ってみるか！と思い立ちました。

…思い立ったものの、Rust で GUI 作るのはハードル高そう(だし、やりたいことの本質から逸れていく)なので GUI 部分は既にある知識でなんとかしようと考えました。

ここで、今どきの Web フロントエンダーの皆様であれば Electron(powered by Node.js)なんかを選択肢に入れるところかと思いますが、自分はそっち方面知らないので Java の Swing でやってみました。

せっかくなんで Project Panama(プロパナ)を使ってみました。

## 全体コード

https://github.com/yukihane/stackoverflow-qa/tree/master/so62868

にあります。
Rust(1.41.0)と Java([14-panama](https://jdk.java.net/panama/))を使っています。
ビルド方法は `build.sh` 参照のこと。

## 実装

ハローワールド案件です。Java で処理を要求&結果を受け取る、Rust では要求された処理を行って結果を返します。

まず Rust 側。`name`を受け取って文字列連結して`message`として返します。

```rust
#[no_mangle]
pub unsafe extern "C" fn greet(name: *const c_char, message: *mut c_char, count: size_t) {
    let name = CStr::from_ptr(name);
    let name = name.to_str().unwrap();
    let text = format!("こんにちは、{}！", name);
    let text = CString::new(text).unwrap();

    message.copy_from(text.as_ptr(), count);
}
```

上の関数に対応する C ヘッダファイルを生成します。
[cbindgen](https://github.com/eqrion/cbindgen)というツールで自動生成できました。

    cbindgen -l c -o bridges/greeter.h librust

自動生成したそのままでも使えると思うのですが、冗長だと思ったので、今回は不要部分を削って commit してしまっています。

続いてヘッダファイルと cdylib から`jextract`を用いてプロパナ の glue 部分を自動生成します。

```shell
jextract \
-L librust/target/release/ \
-l greeter \
-o bridges/greeter.jar \
./bridges/greeter.h
```

上記で生成された jar を利用して Rust 呼び出し部分を Java で実装します。

```java
final JButton greetButton = new JButton("greet");
greetButton.addActionListener((e) -> {
    final Scope scope = Scope.globalScope();

    final Pointer<Byte> name = scope.allocateCString(nameField.getText());
    final long size = 256;
    final Pointer<Byte> message = scope.allocateArray(NativeTypes.UINT8, size).elementPointer();

    greeter_lib.greet(name, message, size);

    final String retval = Pointer.toString(message);
    outputField.setText(retval);
});
```

以上。
