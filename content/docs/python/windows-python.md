---
title: "Windows Python"
date: 2020-07-26T03:02:03Z
draft: false
---

[ChocolateyでインストールしたPython](Chocolatey)3の運用について。

# proxy

`pip` コマンドは環境変数 `http_proxy` , `https_proxy` を見ているので、プロキシ環境下ではこれらの設定を行っておく。

# Ansible インストール

結論としては色々障害があり諦めた。ただし必要があれば問題を解消してインストールすることは可能と思われる。 おそらく次のリンク先の事象と同じ。

- [Windows(x64)でPython3.6.0(x64)にPyCryptoを入れるメモ - Qiita](http://qiita.com/walkure/items/09516cb711ff1c886286)

`pip` コマンドでインストールしようとすると以下のエラーになる。

``` winbatch
>pip install ansible
(中略)
    warning: GMP or MPIR library not found; Not building Crypto.PublicKey._fastmath.
    building 'Crypto.Random.OSRNG.winrandom' extension
    error: Microsoft Visual C++ 14.0 is required. Get it with "Microsoft Visual C++ Build Tools": http://landinghub.visualstudio.com/visual-cpp-build-tools

    ----------------------------------------
Command "c:\python36\python.exe -u -c "import setuptools, tokenize;__file__='C:\\Users\\xxx\\AppData\\Local\\Temp\\pip-build-6vc171ni\\pycrypto\\setup.py';f=getattr(tokenize, 'open', open)(__file__);code=f.read().replace('\r\n', '\n');f.close();exec(compile(code, __file__, 'exec'))" install --record C:\Users\xxx\AppData\Local\Temp\pip-5ckp1rdw-record\install-record.txt --single-version-externally-managed --compile" failed with error code 1 in C:\Users\xxx\AppData\Local\Temp\pip-build-6vc171ni\pycrypto\
```

メッセージに従い、 <http://landinghub.visualstudio.com/visual-cpp-build-tools> で "Visual C++ Build Tools 2015" をダウンロードしインストールする。インストールオプションはデフォルトのまま。

その後、再度インストールを試みるも、別のエラーが発生。

        C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\BIN\x86_amd64\cl.exe /c /nologo /Ox /W3 /GL /DNDEBUG /MD -Isrc/ -Isrc/inc-msvc/ -Ic:\python36\include -Ic:\python36\include "-IC:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\INCLUDE" "-IC:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt" "-IC:\Program Files (x86)\Windows Kits\8.1\include\shared" "-IC:\Program Files (x86)\Windows Kits\8.1\include\um" "-IC:\Program Files (x86)\Windows Kits\8.1\include\winrt" /Tcsrc/winrand.c /Fobuild\temp.win-amd64-3.6\Release\src/winrand.obj    winrand.c
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(26): error C2061: syntax error: identifier 'intmax_t'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(27): error C2061: syntax error: identifier 'rem'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(27): error C2059: syntax error: ';'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(28): error C2059: syntax error: '}'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(30): error C2061: syntax error: identifier 'imaxdiv_t'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(30): error C2059: syntax error: ';'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(40): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(41): error C2146: syntax error: missing')' before identifier '_Number'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(41): error C2061: syntax error: identifier '_Number'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(41): error C2059: syntax error: ';'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(42): error C2059: syntax error: ')'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(45): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(46): error C2146: syntax error: missing')' before identifier '_Numerator'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(46): error C2061: syntax error: identifier '_Numerator'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(46): error C2059: syntax error: ';'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(46): error C2059: syntax error: ','
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(48): error C2059: syntax error: ')'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(50): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(56): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(63): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(69): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(76): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(82): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(89): error C2143: syntax error: missing'{' before '__cdecl'
        C:\Program Files (x86)\Windows Kits\10\include\10.0.10240.0\ucrt\inttypes.h(95): error C2143: syntax error: missing'{' before '__cdecl'
        error: command 'C:\\Program Files (x86)\\Microsoft Visual Studio 14.0\\VC\\BIN\\x86_amd64\\cl.exe' failed with exit
    status 2

冒頭記載リンク先「PyCryptoとコンパイラのstdint.hがバッティング」と同じ事象だと思われるが、作業中断。
