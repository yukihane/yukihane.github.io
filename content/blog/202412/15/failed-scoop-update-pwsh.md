---
title: "Scoopでpwshのupdateに失敗する"
date: 2024-12-15T02:36:06+09:00
draft: false
tags: ["windows", "scoop"]
---

Scoop で

```bash
scoop update pwsh
```

を実行してもプロセスが起動しているからスキップする

```
ERROR The following instances of "pwsh" are still running. Close them and try again.

 NPM(K)    PM(M)      WS(M)     CPU(s)      Id  SI ProcessName
 ------    -----      -----     ------      --  -- -----------
     71    42.12     104.00       0.52   26500   1 pwsh
```

というメッセージが出てアップデートできない事象がずっと続いていました。
(ちゃんと読んでいないのですが)公式のGitHubでissueがいくつか建っているようです。

- [Scoop fails to update pwsh #3572](https://github.com/ScoopInstaller/Main/issues/3572#issuecomment-2177998661)

など。
ワークアラウンドとしては、Windows11(やWindows10)に初期インストールされているPowerShellを用いればよいようです。

具体的には、上記リンク先のように `Win + R` で出現させたダイアログに

```
powershell -Command "scoop update pwsh"
```

と打ち込んだり、Windowsメニューから(Power Shell Coreでなく) **Windows PowerShell** を起動して、そこで `soop update pwsh` を実行すればOKのようです。
