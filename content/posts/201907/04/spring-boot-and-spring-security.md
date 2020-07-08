---
title: spring-boot-starter-security を入れたら認証画面が！
date: 2019-07-04T20:32:21Z
# description: ""
# keywords: []
# authors: []
# categories: []
# series: []
tags: [spring-boot, spring-security]
# images: []
# videos: []
# audio: []
draft: false
---

`WebSecurityConfigurerAdapter#configure(HttpSecurity)` で form 認証を有効化しているのでこれをディスる。
`WebSecurityConfigurerAdapter`を継承した Spring コンポーネントをスキャン対象に含めれば良い。

```
@Configuration
public class MyWebSecConfig extends WebSecurityConfigurerAdapter {

    @Override
    protected void configure(final HttpSecurity http) throws Exception {
        // 空実装でオーバライド
    }
}
```

# 別解

`SecurityAutoConfiguration`をディスる。(form 認証だけでなく他のセキュリティ自動設定も無効化される)

```
@SpringBootApplication(exclude = { SecurityAutoConfiguration.class })
public class MyApplication {
    public static void main(final String[] args) {
        SpringApplication.run(MyApplication.class, args);
    }
}
```
