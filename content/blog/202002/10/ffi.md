---
title: "現実世界のFFI実装について調べる"
date: 2020-02-10T12:58:59Z
draft: true
---

# Dart

- [ドキュメント](https://dart.dev/guides/libraries/c-interop)

- [caller](https://github.com/dart-lang/samples/blob/b8bac3a6c45c5b330dc5be70ed86df2dfd94b1b1/ffi/structs/structs.dart#L74) - Dart

- [callee](https://github.com/dart-lang/samples/blob/b8bac3a6c4/ffi/structs/structs_library/structs.c#L22) - C

calee が `malloc` で領域確保し関数戻り値でポインタを返している。 サンプルコードだからか、領域を開放する実装は無い(ためこのままだとメモリリークする)。

# Go

- ドキュメント - [Command cgo](https://golang.org/cmd/cgo/), [wiki](https://github.com/golang/go/wiki/cgo), [blog](https://blog.golang.org/c-go-cgo)

> Memory allocations made by C code are not known to Go’s memory manager. When you create a C string with C.CString (or any C memory allocation) you must remember to free the memory when you’re done with it by calling C.free.
>
> The call to C.CString returns a pointer to the start of the char array, so before the function exits we convert it to an unsafe.Pointer and release the memory allocation with C.free. A common idiom in cgo programs is to defer the free immediately after allocating (especially when the code that follows is more complex than a single function call), as in this rewrite of Print:
>
> ``` golang
> func main() {
>     cs := C.CString("Hello from stdio")
>     C.myprint(cs)
>     C.free(unsafe.Pointer(cs))
> }
> ```
>
> —  2011年のblog記事

> Of course, you aren’t required to use defer to call C.free(). You can free the C string whenever you like, but it is your responsibility to make sure it happens.
>
> —  wiki
