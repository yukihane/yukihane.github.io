---
title: "Centos7 に Homebrew を導入して Puppeteer を実行する"
date: 2024-11-16T12:09:03+09:00
draft: false
tags: ["linux"]
---

次の回答の検証になります:

- [CentOS7 環境で glibc を 2.27 にアップデートすると、どんな影響がありますか？ - スタック・オーバーフロー](https://ja.stackoverflow.com/a/100397/2808)

環境は[前回のエントリー](/blog/202411/16/centos7-environment)で用意したものです。

## セットアップ
### Development Tools インストール

あとでHomebrewに要求されるので先にインストールしておきます:
```bash
sudo yum groupinstall -y 'Development Tools'
```

### Git 最新化

Homebrewインストール時にGitが古いと怒られるので最新版をインストールします:
```bash
sudo yum remove -y git
sudo yum -y install https://repo.ius.io/ius-release-el7.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo yum -y install libsecret pcre2 emacs-filesystem
sudo yum -y install git --enablerepo=ius --disablerepo=base,epel,extras,updates
```

- ref. [CentOS7でYumを使って最新版gitを導入する - Qiita](https://qiita.com/Crow314/items/5e99c9933546d6577e34)

### Curl 最新化

Curl も古いと怒られるので最新化します。

- https://gist.github.com/thesuhu/bccd43a4dc998e738d1f3578f34949ce


```
#! /bin/bash

set -eux

# Tested on CentOS 7 and CentOS 8
# Check the latest version at https://curl.se/download/
VERSION=8.11.0

cd ~
sudo yum update -y
sudo yum install wget gcc openssl-devel make libpsl-devel -y
wget https://curl.haxx.se/download/curl-${VERSION}.tar.gz
tar -xzvf curl-${VERSION}.tar.gz 
rm -f curl-${VERSION}.tar.gz
cd curl-${VERSION}
./configure --prefix=/usr/local --with-ssl
make
sudo make install
sudo ldconfig
cd ~
rm -rf curl-${VERSION}
```

またこれもHomebrewに怒られるので先に設定しておきます:
```bash
echo 'export HOMEBREW_CURL_PATH=/usr/local/bin/curl' >> ~/.bashrc
export HOMEBREW_CURL_PATH=/usr/local/bin/curl
```

### Homebrew インストール

公式サイト https://brew.sh/ にある通りコマンドを実行します:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

インストール後に指示される通り `.bashrc` への書き込みと、 `brew` コマンドでのGCCインストールを実行します。

```bash
echo >> /home/vagrant/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/vagrant/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
```

```bash
brew install gcc
```

## Puppeteer実行

```bash
sudo yum install -y chromium-browser
brew install node@18
mkdir ~/hello-puppeteer
cd ~/hello-puppeteer
npm init -y
npm i puppeteer-core
cat <<EOF > main.js
const puppeteer = require('puppeteer-core');

(async () => {
  // Launch the browser and open a new blank page
  const browser = await puppeteer.launch({executablePath: '/usr/bin/chromium-browser'});
  const page = await browser.newPage();

  // Navigate the page to a URL
  await page.goto('https://developer.chrome.com/');

  // Set screen size
  await page.setViewport({width: 1080, height: 1024});

  const title = await page.title();
  console.log('page title:', title);

  await browser.close();
})();
EOF
```
実行してみます:
```bash
node main.js
```
