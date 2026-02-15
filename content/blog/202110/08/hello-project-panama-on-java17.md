---
title: "Hello Project Panama, on Java17"
date: 2021-10-08T04:49:30Z
draft: false
tags:
  - java
  - rust
---

# はじめに

- [Hello Project Panama – 発火後忘失](https://yukihane.github.io/blog/202002/11/hello-project-panama/)

で、 Project Panama ([リンク1](https://openjdk.java.net/projects/panama/), [リンク2](https://jdk.java.net/panama/)) の機能を利用して、 Java から Rust を呼び出してみました。

当時(Java14)は Project Panama 用にビルドされた JDK を利用する必要がありましたが、 Java17 では incubator ではあるものの [JEP 412: Foreign Function & Memory API](https://openjdk.java.net/jeps/412) が標準 JDK に導入された

- [Java 17新機能まとめ - Qiita](https://qiita.com/nowokay/items/ec58bf8f30d236a12acb)

ので、標準の JDK でも冒頭にリンクしたコード相当のものをビルド、実行できるようになりました(※ 後述の通り [`jextract` コマンド](https://github.com/openjdk/panama-foreign/blob/foreign-jextract/doc/panama_jextract.md) は標準 JDK に含まれていないので別途取得する必要があります)。

API, `jextract` コマンド引数など、 Java14 当時と結構変わっていましたので、改めて project Panama を使って Hello, world してみたいと思います。

今回の成果物は次のリンク先にあります:

- <https://github.com/yukihane/hello-java/tree/master/project-panama/java17>

# 環境

- Ubuntu 20.04

  - 後で Windows10 上でも試してみましたが、こちらも上手く動作しました

- Java Corretto-17.0.0.35.1

- `jextract` Build 17-panama+3-167 (2021/5/18)

- rustc 1.55.0

# 作成手順

## Rust でダイナミックリンクライブラリ作成

`greeter` という名前でプロジェクトを作成します。 プロジェクトルートディレクトリで次のコマンドを実行します。

``` sh
cargo new --lib greeter
cd greeter
```

[`libc` クレート](https://crates.io/crates/libc)を依存関係に追加します。 また、ダイナミックリンクライブラリを生成するように `crate-type` に `cdylib` を設定します。

<div class="formalpara-title">

**Cargo.toml**

</div>

``` toml
[dependencies]
libc = "0.2.103"
[lib]
crate-type = ["cdylib"]
```

Rust 側で行う処理を実装します。

<div class="formalpara-title">

**src/lib.rs**

</div>

``` rust
use libc::size_t;
use std::ffi::{CStr, CString};
use std::os::raw::c_char;

#[no_mangle]
pub unsafe extern "C" fn greet(name: *const c_char, message: *mut c_char, count: size_t) {
    let name = CStr::from_ptr(name);
    let name = name.to_str().unwrap();
    let text = format!("こんにちは、{}！", name);
    let text = CString::new(text).unwrap();

    message.copy_from(text.as_ptr(), count);
}
```

ビルドします。

``` sh
cargo build --release
```

### 参考

- [The Cargo Book \> 3.2.1. Cargo Targets \> The crate-type field](https://doc.rust-lang.org/cargo/reference/cargo-targets.html#the-crate-type-field)

- [The Rustonomicon \> 11. Foreign Function Interface \> Calling Rust code from C](https://doc.rust-lang.org/nomicon/ffi.html#calling-rust-code-from-c)

## ダイナミックリンクライブラリの C ヘッダ自動生成

上で作成したライブラリのヘッダファイルを自動生成します。

[`cbindgen`](https://github.com/eqrion/cbindgen) コマンドをインストールします。

``` sh
cargo install --force cbindgen
```

プロジェクトルートディレクトリで次のコマンドを実行します。

``` sh
cbindgen -l c -o bridges/greeter.h greeter
```

上記コマンド実行により `bridges/greeter.h` ヘッダファイルが生成されます。

<div class="formalpara-title">

**bridges/greeter.h**

</div>

``` c
#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

void greet(const char *name, char *message, size_t count);
```

## C ヘッダから Java API 自動生成

`jextract` コマンドを利用してヘッダファイルから Java API を自動生成します。

`jextract` コマンドは [Project Panama の Early Access Build](https://jdk.java.net/panama/) をダウンロードし展開すると `bin` ディレクトリ下にあります。

プロジェクトルートディレクトリで次のコマンドを実行します。

    /path/to/jextract \
    -l greeter \
    -d classes \
    -t com.example \
    ./bridges/greeter.h

上記コマンドを実行すると `classes` ディレクトリ下にクラスファイルが生成されます。

### 補足/参考

- 上で自動生成した `bridges/greeter.h` は、実際には不必要なインクルードを含んでいます。 これを削減し、 `#include <stddef.h>` (`size_t` を定義しているヘッダファイル) だけにすると、ここで自動生成されるファイルも減ります。

- `jextract` コマンドに `--source` オプションを付与すると、 `.class` ファイルでなく `.java` ファイルが生成されます。

- `jextract` コマンドの詳細は次のリンク先を参照:

  - [Using the jextract tool - openjdk/panama-foreign](https://github.com/openjdk/panama-foreign/blob/foreign-jextract/doc/panama_jextract.md)

    - 同階層 `doc` ディレクトリには他にも参考になるドキュメントあり

## 呼び出し側を Java で実装

`jdk.incubator.foreign` 機能を用いてメモリ領域を確保し、自動生成した API `com.example.greeter_h.greeter()` を呼ぶコードを実装します。

<div class="formalpara-title">

**src/Main.java**

</div>

``` java
import static com.example.greeter_h.*;
import static jdk.incubator.foreign.CLinker.*;

import jdk.incubator.foreign.*;
import java.awt.BorderLayout;
import java.io.Serial;
import java.nio.charset.StandardCharsets;
import javax.swing.*;

public class Main extends JFrame {

    @Serial
    private static final long serialVersionUID = 4648172894076113183L;

    public Main() {
        super("Rust GUI Frontend by Java Swing");
        setLayout(new BorderLayout());

        final JTextField nameField = new JTextField(20);

        final JTextField outputField = new JTextField(30);
        outputField.setEditable(false);

        final JButton greetButton = new JButton("greet");
        greetButton.addActionListener((e) -> {
            try (ResourceScope scope = ResourceScope.newConfinedScope()) {
                final SegmentAllocator allocator = SegmentAllocator.ofScope(scope);
                final MemorySegment name = toCString(nameField.getText(), scope);
                final long size = 256;
                final MemorySegment message = allocator.allocateArray(C_CHAR, size);

                greet(name, message, size);

                // Project PanamaのJDKには存在するが、通常のJDK17には無い
                // final String retval = toJavaString(message, StandardCharsets.UTF_8);
                final String retval = toJavaString(message);
                outputField.setText(retval);
            }
        });

        add(nameField, BorderLayout.WEST);
        add(greetButton, BorderLayout.EAST);
        add(outputField, BorderLayout.SOUTH);
        pack();
    }

    public static void main(final String[] args) {
        SwingUtilities.invokeLater(() -> {
            final Main app = new Main();
            app.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            app.setVisible(true);
        });
    }
}
```

### 補足

- IDE を用いる場合、次のリンク先に IntelliJ の設定方法が説明されています。

  - <https://github.com/carldea/panama4newbies/blob/main/README.md>

    - こちらのリンク、IDE の設定方法だけでなく、 Project Panama 全体の説明もわかりやすいと思います

## Java コードビルド

上記のコードを JDK17 でビルドするには `--add-modules jdk.incubator.foreign` オプションを付与する必要があります。

``` sh
javac \
-encoding utf-8 \
-d ./classes \
-cp ./classes \
--add-modules jdk.incubator.foreign \
./src/Main.java
```

## 実行

`--enable-native-access=ALL-UNNAMED`, `--add-modules jdk.incubator.foreign` オプションが必要です。

``` sh
LD_LIBRARY_PATH=./greeter/target/release \
java \
-Dfile.encoding=utf-8 \
--enable-native-access=ALL-UNNAMED \
--add-modules jdk.incubator.foreign \
-cp ./classes Main
```

### 参考/補足

- Windows で実行する場合、 `LD_LIBRARY_PATH` は機能しません。 代わりに、 `./greeter/target/release/greeter.dll` をカレントディレクトリにコピーしてから上のコマンドを実行します。

- [Using the jextract tool \> Running the Java code that invokes helloworld](https://github.com/openjdk/panama-foreign/blob/foreign-jextract/doc/panama_jextract.md#running-the-java-code-that-invokes-helloworld)
