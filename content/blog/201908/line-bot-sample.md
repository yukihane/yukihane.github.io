---
title: LINE Messaging API を試してみる
date: 2019-08-25
draft: false
tags:
  - java
  - spring-boot
  - line
:jbake-type: post
:jbake-status: published
:jbake-tags: java,springboot,line
:idprefix:
---

# 準備

## Spring Boot セットアップ

<https://start.spring.io/> でテンプレートを作成して次の依存関係を追加します。

    <dependency>
        <groupId>com.linecorp.bot</groupId>
        <artifactId>line-bot-spring-boot</artifactId>
        <version>2.7.0</version>
    </dependency>

- リポジトリ: <https://github.com/line/line-bot-sdk-java/tree/master/line-bot-spring-boot>

## Heroku セットアップ

今回は `linebotbeta` というアプリケーション名にしました。

    heroku create -n -a linebotbeta

- 参考: [HerokuでSpringBootアプリを動かしてみる \> ローカルでビルドした jar をデプロイする](https://himeji-cs.jp/blog2/blog/2019/08/hello-heroku-with-springboot.html) 及びそのリンク先

## LINE platform セットアップ

[LINEデベロッパーコンソール](https://developers.line.biz/console/) で今回のbotが利用するプロバイダ、チャネルを作成します。

- 参考: [Herokuでサンプルボットを作成する \> 始める前に](https://developers.line.biz/ja/docs/messaging-api/building-sample-bot-with-heroku/)

「チャネル基本設定」タブで次の設定を行います。

| 設定項目                       | 設定値                                       |
|--------------------------------|----------------------------------------------|
| アクセストークン(ロングターム) | (発行しておく)                               |
| Webhook送信                    | 利用する                                     |
| Webhook URL                    | <https://linebotbeta.herokuapp.com/callback> |

Webhook URL の設定値について、 `linebotbata` というのは先に作成したHeroku上のapp名、 `/callback` は line-bot-spring-bootのデフォルトのコールバックエンドポイントです。 これは [`line.bot.handler.path` プロパティで変更可能です](https://github.com/line/line-bot-sdk-java/tree/master/line-bot-spring-boot#configuration)。

# 実装

## コントローラ(ハンドラ)実装

今回はとりあえず [README](https://github.com/line/line-bot-sdk-java/tree/master/line-bot-spring-boot#usage) にあるオウム返しするハンドラを試しに実装しておきます。

    @LineMessageHandler
    public class MyController {

        @EventMapping
        public TextMessage handleTextMessageEvent(final MessageEvent<TextMessageContent> event) throws Exception {
            System.out.println("event: " + event);
            return new TextMessage(event.getMessage().getText());
        }
    }

## プロパティ設定

`src/main/resources/application.properties` に、デベロッパーコンソールの今回使用するチャネルに表示されている次の項目をセットします。

| 設定項目               | 設定値                                  |
|------------------------|-----------------------------------------|
| line.bot.channelToken  | `アクセストークン（ロングターム）` の値 |
| line.bot.channelSecret | `Channel Secret` の値                   |

# ビルド&デプロイ

    mvn package
    heroku deploy:jar target/line-bot-sample-0.0.1-SNAPSHOT.jar -a linebotbeta

# 実行してみる

デベロッパーコンソールのチャネルページにQRコードが表示されていると思いますので、スマートフォンのLINEアプリで読み取ってチャネルにアクセスします。

トーク画面で何かメッセージを入力すると、botがオウム返ししてきます。

botのログは `heroku logs` コマンドで確認できます。

    heroku logs -a linebotbeta
