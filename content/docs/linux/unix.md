---
title: "Unix"
date: 2020-07-24T01:51:44Z
draft: false
---

# ログインシェル変更

さくらレンタルサーバのデフォルトログインシェルは\`/bin/csh\`なのでLinuxユーザにはちょっと馴染みがない…

`/etc/shells` に利用可能なシェル一覧がある。

    /bin/sh
    /bin/csh
    /bin/tcsh
    /usr/local/bin/zsh
    /usr/local/bin/rzsh
    /usr/bin/passwd
    /usr/local/bin/bash
    /usr/local/bin/rbash

`chsh -s newshell` で新しいシェルに変更できる。間違えるとログインできなくなるので注意。

今回は `zsh` を使ってみるので `chsh -s /usr/local/bin/zsh`

`.zshrc` は [こちら](http://mollifier.hatenablog.com/entry/2013/02/22/025415) で紹介されている <https://gist.github.com/mollifier/4979906> を採用。

追加で [さくらの共有サーバーでシェルを zsh に変更してから、zsh: permission denied: /var/mail/youraccount と怒られないようにする - make world](http://d.hatena.ne.jp/littlebuddha/20090216/1234785251) の設定も行う。

``` bash
% vi ~/.zshrc
export MAILCHECK=0
% source ~/.zshrc
```

# Ubuntuのbash(dash)には BASH_SOURCE はない

Bad substitution などと言われてしまう。

[5.2 BBash Reference Manual: Bash Variables](https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html):

> BASH_SOURCE
>
> :: An array variable whose members are the source filenames where the corresponding shell function names in the FUNCNAME array variable are defined. The shell function \$\\FUNCNAME\[\$i\]} is defined in the file \$\\BASH_SOURCE\[\$i\]} and called from \$\\BASH_SOURCE\[\$i+1\]}

この `BASH_SOURCE` は `sh` (`dash`)にはない模様。 `/bin/bash hoge.sh` というように、明示的に\`bash\`を指定してやれば良い。

- [bash - SCRIPT_PATH="\${BASH_SOURCE\[0\]}" Bad substitution - Stack Overflow](http://stackoverflow.com/a/15542250/4506703)

# フォント

## インストール

`/usr/share/fonts`, あるいは `~/.fonts` に `ttc`, \`ttf\`ファイルを置けばよい。

## フォント一覧

    fc-list

# ハードディスク関係

参考: [Linux機に接続されているHDDを把握する方法 - kanonjiの日記](http://d.hatena.ne.jp/kanonji/20081220/1229787169)

実行コマンド:

    dmesg | grep -B 5 sd

結果抜粋:

    [    2.492857] scsi 0:0:0:0: Direct-Access     ATA      INTEL SSDSC2CT24 335s PQ: 0 ANSI: 5
    [    2.493181] sd 0:0:0:0: Attached scsi generic sg0 type 0
    [    2.493421] sd 0:0:0:0: [sda] 468862128 512-byte logical blocks: (240 GB/224 GiB)
    [    2.493461] sd 0:0:0:0: [sda] Write Protect is off
    [    2.493463] sd 0:0:0:0: [sda] Mode Sense: 00 3a 00 00
    [    2.493478] scsi 1:0:0:0: Direct-Access     ATA      Hitachi HDP72505 A50E PQ: 0 ANSI: 5
    [    2.493548] sd 0:0:0:0: [sda] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
    [    2.493704] sd 1:0:0:0: Attached scsi generic sg1 type 0
    [    2.493757] sd 1:0:0:0: [sdb] 976773168 512-byte logical blocks: (500 GB/466 GiB)
    [    2.493766] sd 1:0:0:0: [sdb] Write Protect is off
    [    2.493767] sd 1:0:0:0: [sdb] Mode Sense: 00 3a 00 00
    [    2.493781] sd 1:0:0:0: [sdb] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
    [    2.493805] scsi 2:0:0:0: Direct-Access     ATA      SAMSUNG HD154UI  1118 PQ: 0 ANSI: 5
    [    2.493899] sd 2:0:0:0: Attached scsi generic sg2 type 0
    [    2.493951] sd 2:0:0:0: [sdc] 2930277168 512-byte logical blocks: (1.50 TB/1.36 TiB)
    [    2.493959] sd 2:0:0:0: [sdc] Write Protect is off
    [    2.493960] sd 2:0:0:0: [sdc] Mode Sense: 00 3a 00 00
    [    2.493987] sd 2:0:0:0: [sdc] Write cache: enabled, read cache: enabled, doesn't support DPO or FUA
    [    2.494557]  sda: sda1 sda2 sda3 sda4 sda5 sda6 sda7 sda8
    [    2.494846] sd 0:0:0:0: [sda] Attached SCSI disk
    [    2.541827]  sdb: sdb1 sdb2
    [    2.542526] sd 1:0:0:0: [sdb] Attached SCSI disk
    --
    [    3.210440] usb 6-3: New USB device found, idVendor=2833, idProduct=0211
    [    3.210444] usb 6-3: New USB device strings: Mfr=1, Product=2, SerialNumber=3
    [    3.210446] usb 6-3: Product: Rift Sensor
    [    3.210448] usb 6-3: Manufacturer: Oculus VR
    [    3.210450] usb 6-3: SerialNumber: WMTD305P400QJ1
    [    3.262858]  sdc: sdc1 sdc2
    [    3.263624] sd 2:0:0:0: [sdc] Attached SCSI disk

fdisk結果;

    $ sudo /sbin/fdisk -l /dev/sda
    ディスク /dev/sda: 223.6 GiB, 240057409536 バイト, 468862128 セクタ
    単位: セクタ (1 * 512 = 512 バイト)
    セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
    I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
    ディスクラベルのタイプ: gpt
    ディスク識別子: AA735739-B642-4B39-BC7C-C584A2B33C11

    デバイス    開始位置  最後から    セクタ サイズ タイプ
    /dev/sda1       2048    616447    614400   300M Windows リカバリ環境
    /dev/sda2     616448    821247    204800   100M EFI システム
    /dev/sda3     821248   1083391    262144   128M Microsoft 予約領域
    /dev/sda4    1083392 230960116 229876725 109.6G Microsoft 基本データ
    /dev/sda5  230961152 232564735   1603584   783M Windows リカバリ環境
    /dev/sda6  233504768 234426367    921600   450M Windows リカバリ環境
    /dev/sda7  234426368 435130367 200704000  95.7G Microsoft 基本データ
    /dev/sda8  435130368 468860927  33730560  16.1G Linux スワップ

    $ sudo /sbin/fdisk -l /dev/sda
    ディスク /dev/sda: 223.6 GiB, 240057409536 バイト, 468862128 セクタ
    単位: セクタ (1 * 512 = 512 バイト)
    セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
    I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
    ディスクラベルのタイプ: gpt
    ディスク識別子: AA735739-B642-4B39-BC7C-C584A2B33C11

    デバイス    開始位置  最後から    セクタ サイズ タイプ
    /dev/sda1       2048    616447    614400   300M Windows リカバリ環境
    /dev/sda2     616448    821247    204800   100M EFI システム
    /dev/sda3     821248   1083391    262144   128M Microsoft 予約領域
    /dev/sda4    1083392 230960116 229876725 109.6G Microsoft 基本データ
    /dev/sda5  230961152 232564735   1603584   783M Windows リカバリ環境
    /dev/sda6  233504768 234426367    921600   450M Windows リカバリ環境
    /dev/sda7  234426368 435130367 200704000  95.7G Microsoft 基本データ
    /dev/sda8  435130368 468860927  33730560  16.1G Linux スワップ

    $ sudo /sbin/fdisk -l /dev/sdb
    ディスク /dev/sdb: 465.8 GiB, 500107862016 バイト, 976773168 セクタ
    単位: セクタ (1 * 512 = 512 バイト)
    セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
    I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
    ディスクラベルのタイプ: gpt
    ディスク識別子: 6A2BFF42-09CF-485C-9A10-83FAA1AE568E

    デバイス   開始位置  最後から    セクタ サイズ タイプ
    /dev/sdb1        34    262177    262144   128M Microsoft 予約領域
    /dev/sdb2    264192 976771071 976506880 465.7G Microsoft 基本データ

    $ sudo /sbin/fdisk -l /dev/sdc
    ディスク /dev/sdc: 1.4 TiB, 1500301910016 バイト, 2930277168 セクタ
    単位: セクタ (1 * 512 = 512 バイト)
    セクタサイズ (論理 / 物理): 512 バイト / 512 バイト
    I/O サイズ (最小 / 推奨): 512 バイト / 512 バイト
    ディスクラベルのタイプ: gpt
    ディスク識別子: 6A20E8DF-1F2F-4607-ABC6-D00C0A5EE17E

    デバイス     開始位置   最後から     セクタ サイズ タイプ
    /dev/sdc1        2048 1465139199 1465137152 698.6G Microsoft 基本データ
    /dev/sdc2  1465139200 2930276351 1465137152 698.6G Microsoft 基本データ

# コマンドなど

## CRLF → LF 変換

     find . -type f | xargs sed -i -e 's/^M//g'

`sed` はgnu版sed。 `^M` は、 `C-v C-m` で入力できる。 Macだと\`nkf\`を使う例がよく検索でヒットするが、円マークなど、想定していない箇所の文字コードも変わってしまった。
