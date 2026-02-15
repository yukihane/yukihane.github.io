---
title: "UbuntuでKindle for PCを使う"
date: 2020-07-26T01:57:49Z
draft: false
---





書きかけのページです。次のリンク先が参考になります。



- <a href="https://qiita.com/giwagiwa/items/d2e447af5225c1ce9800" class="bare">https://qiita.com/giwagiwa/items/d2e447af5225c1ce9800</a>



Ubuntu16.04上で、PlayOnLinxで管理されたWine環境でKindle for PCを動作させる手順です。



## Wine インストール



PlayOnLinuxを動作させるのに先立ってWineが必要らしいのでインストールします。 なお**このWineはKindleを動作させるものではない**ので、最新安定版をインストールしておけば良いようです。 (後述しますが、**Kindleを動作させるWine**は相性問題で必ずしも最新版が良いとは限らないようです。)


------------------------------------------------------------------------


古い記事では ppa:wine/wine-builds を使用するよう書かれているが、これは既にdeprecatedです(リポジトリ追加時に警告も出る)。



<a href="https://launchpad.net/~wine/+archive/ubuntu/wine-builds" class="bare">https://launchpad.net/~wine/+archive/ubuntu/wine-builds</a>



>
> !!! PLEASE NOTE THAT THIS REPOSITORY IS DEPRECATED !!!
>
>
>
> For more information, please see:
>
>
>
> ``    `https://www.winehq.org/pipermail/wine-devel/2017-March/117104.html[`https://www.winehq.org/pipermail/wine-devel/2017-March/117104.html ``\]
>
>
>
> The following commands can be used to add the new repository:
>
>
>
> ``    wget `https://dl.winehq.org/wine-builds/Release.key[`https://dl.winehq.org/wine-builds/Release.key ``\]  
> `   sudo apt-key add Release.key`  
>
>    sudo apt-add-repository ‘[\`https://dl.winehq.org/wine-builds/ubuntu/](https://dl.winehq.org/wine-builds/ubuntu/)’\`
>



というわけで、ここに書かれているとおり、代わりに新しいリポジトリを用います。 …と、以前はそれでよかったのですが、2018年末、ここから更に公開鍵が変わったようなので、次のコマンドを実行する必要があります([参考](https://wiki.winehq.org/Ubuntu))。




    wget -nc https://dl.winehq.org/wine-builds/winehq.key
    sudo apt-key add winehq.key




リポジトリを追加します。Ubuntuのバージョンごとに異なりますのでhttps://wiki.winehq.org/Ubuntu\[リンク先\]を参照してください。下は18.04の例です。




    sudo apt-add-repository 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'




リポジトリを追加したら、次のコマンドでWineのstable版をインストールします。




    sudo apt-get install --install-recommends winehq-stable






## PlayOnLinux インストール



Ubuntuのリポジトリにも playonlinux は存在するが、オフィシャルサイトにある方がバージョンが新しかったのでそちらを用いることにします。



- <a href="https://www.playonlinux.com/en/download.html" class="bare">https://www.playonlinux.com/en/download.html</a>



に書かれているとおりにインストール。\`playonlinux_xenial.list\`の部分はバージョンによって異なるので適宜読み替えます。




    wget -q "http://deb.playonlinux.com/public.gpg" -O- | sudo apt-key add -
    sudo wget http://deb.playonlinux.com/playonlinux_xenial.list -O /etc/apt/sources.list.d/playonlinux.list
    sudo apt-get update
    sudo apt-get install playonlinux




なお、このページに以下の通り書かれているのが確認できるはず。実際にwineをインストールせずにplayonlinuxを起動するとwineが必要という警告ダイアログが出ます。



>
> Ubuntu Precise (and superior) users : You must install the package wine:i386 to get PlayOnLinux working
>





## インストールするWineとKindleのバージョンの選定



冒頭でも少し触れましたが、WineとKindle for PCは最新版のほうが良いとは限らず、相性があるようです。 次のページに動作検証結果が書かれています。



- <a href="https://appdb.winehq.org/objectManager.php?sClass=application&amp;iId=10597" class="bare">https://appdb.winehq.org/objectManager.php?sClass=application&amp;iId=10597</a>



*Latest Rating* の項目が Platinum か Gold になっているものを選んでおけばよいかと思います。 今回はPlatinumとされている Kindle for PCのバージョン 1.17.x , Wine のバージョン 2.15 を選ぶこととしました。





## Kindle for PC(.co.jp対応版) ダウンロード



Kindle for PCについて、PlayOnLinuxからダウンロードはできるものは.co.jpアカウントでログイン出来ないようですので、別途入手します。 参考にした [こちら](https://qiita.com/giwagiwa/items/d2e447af5225c1ce9800)のページでは [このサイト](https://kindle-for-pc.en.uptodown.com/windows)から入手していました。





## PlayOnLinxにKindle環境を構築



### PlayOnLinux起動


`playonlinux` コマンドで起動できます。




### Kindleを動作させるWineのインストール


ツール \> Wineのバージョンを管理 メニューを選択し、前述の通り決定したバージョン 2.15 をインストールします。




### Kindle for PC のインストール


ファイル \> インストール メニューを選択します。(本来ならここでインストール可能なアプリ一覧が表示されるようですが、私が今回インストールしたバージョンでは読み込み中表示のまま止まっています)



画面下部の"*リストにないプログラムをインストールする*"を選択します。



"*Install a program in a new virtual drive*"を選択します。



好きな名前を入力します。(私は *for_kindle* と入力しました)



"*Use another version of Wine*" と "*Configure Wine*" にチェックを入れます。



Kindle for PCを動作させるWineのバージョンである *2.15* を選択します。



"*32bits windows installation*" を選択します。



MonoインストールとGeckoインストールを促されますが、両方キャンセルします。



"アプリケーション"タブの "Windowsバージョン" を **Windows 8.1** に設定します。



install file の選択に置いて、先にダウンロードしておいた Kindle for PCのインストーラexeを指定します。




### 文字化けの解消


ここまでの設定でKindleは起動できるようになります。 が、起動してみると分かる通りメニューの日本語が豆腐表示になっています。 これを解消します。



- 参考: [LubuntuにplayonlinuxでKindleをインストール](https://pri-light.hatenadiary.org/entry/20170723/p1) - Jiyu na Blog



今回は [Cicaフォント](https://github.com/miiton/Cica)(`Cica-Regular.ttf`)を利用しました。他のフォントを利用する場合は適宜読み替えてください。



#### フォントを配備


`~/PlayOnLinux’s virtual drives/for_kindle/drive_c/windows/Fonts` にフォントファイル `Cica-Regular.ttf` を置きます。




#### レジストリファイル作成


`~/Documents/kindle_font.reg` というファイル名で次の内容を保存します。 エンコーディングはShift JISとします。(なお、改行コードは今回LFで行いましたが、これで問題ありませんでした。)




``` highlight
REGEDIT4

[HKEY_CURRENT_USER\Software\Wine\Fonts\Replacements]
"Andale Mono"="Cica"
"Arial Unicode MS"="Cica"
"Batang"="Cica"
"Dotum"="Cica"
"MS Gothic"="Cica"
"MS Mincho"="Cica"
"MS PGothic"="Cica"
"MS PMincho"="Cica"
"MS UI Gothic"="Cica"
"Tahoma"="Cica"
"ＭＳ ゴシック"="Cica"
"ＭＳ 明朝"="Cica"
"ＭＳ Ｐゴシック"="Cica"
"ＭＳ Ｐ明朝"="Cica"
```




PlayOnLinuxのランチャー画面でKindleアイコンを右クリックし、コンテキストメニューからレジストリエディタを起動します。



レジストリエディタのメニューから「レジストリのインポート」を選択し、上記で作成したファイルを選択するとフォント置換設定がインポートされ、上の設定の通りCicaフォントで表示されるようになります。











