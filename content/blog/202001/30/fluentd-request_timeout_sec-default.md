---
title: "`fluent-plugin-bigquery` のパラメータ `request_timeout_sec` 、未設定の場合はどうなるの？"
date: 2020-01-30T02:17:02Z
draft: false
tags:
  - fluentd
---

# 要旨

`fluent-plugin-bigquery` の [README](https://github.com/fluent-plugins-nursery/fluent-plugin-bigquery/blob/v2.2.0/README.md) を読んでいると、 `request_timeout_sec` のデフォルト値が `nil` になっている(その下の `request_open_timeout_sec` には `60` が設定されているのに)のが気になりました。

結論としては、 `request_timeout_sec` は最終的に `httpclient` の `send_timeout` 及び `receive_timeout` パラメータとして利用され、未設定の場合は [そこで指定されているデフォルト値](https://github.com/nahi/httpclient/blob/v3.2.8/lib/httpclient/session.rb#L134-L135)である `send_timeout = 120`, `receive_timeout = 60` が採用されるようです。

# 調査作業ログ

`request_timeout_sec` のデフォルト値が `nil` なので未設定だと無期限に待ち続けるのかと危惧し、実装を見てみることにしました。(ちなみに私はRuby経験は0ですので、これが妥当な調査手順かはわかりません。)

とりあえずGitHub上で検索してみると [`out_bigquery_base.rb`](https://github.com/fluent-plugins-nursery/fluent-plugin-bigquery/blob/v2.2.0/lib/fluent/plugin/out_bigquery_base.rb#L152)で `Fluent::BigQuery::Writer.new` の引数として渡されていることがわかりました。

`Fluent::BigQuery::Writer` というのはおそらく [`bigquery/writer.rb`](https://github.com/fluent-plugins-nursery/fluent-plugin-bigquery/blob/v2.2.0/lib/fluent/plugin/bigquery/writer.rb)で定義されている `Writer` クラスのことだと当たりをつけました。また、Rubyの `new` は `initialize` メソッドを呼び出すように入門ページに書かれていたので `initialize` の処理を見てみると [`Google::Apis::BigqueryV2::BigqueryService` を利用しているようなコード](https://github.com/fluent-plugins-nursery/fluent-plugin-bigquery/blob/v2.2.0/lib/fluent/plugin/bigquery/writer.rb#L13)がありました。 `read_timeout_sec` 及び `send_timeout_sec` フィールドに設定されているようです。

この文字列でGoogle検索してみると [`google-api-ruby-client`](https://github.com/googleapis/google-api-ruby-client/blob/0.36.4/lib/google/apis/core/base_service.rb#L413-L419)がヒットしました。 `client_options` の "client" とは、どうも [`HTTPClient`](https://github.com/googleapis/google-api-ruby-client/blob/0.36.4/lib/google/apis/core/base_service.rb#L401)のことっぽい、 `require` で [階層なし](https://github.com/googleapis/google-api-ruby-client/blob/0.36.4/lib/google/apis/core/base_service.rb#L24) になっているということはRubyの標準モジュールなのか？と検索してみると [StackOverflowの回答](https://stackoverflow.com/questions/20399534/whats-the-default-time-out-limitation-of-ruby-httpclient/20403808#20403808)から [ここ](https://github.com/nahi/httpclient/blob/v3.2.8/lib/httpclient/session.rb#L134-L135)に行き当たりました。
