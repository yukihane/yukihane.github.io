---
title: "openapi generator を Spring Boot で利用してみる"
date: 2020-08-23T05:09:07Z
draft: false
tags:
  - spring-boot
  - openapi
---

# 今回の成果物

- <https://github.com/yukihane/hello-java/tree/master/spring/openapi-sample>

# 設定

## build.gradle

- [openapi-generator-gradle-plugin](https://github.com/OpenAPITools/openapi-generator/tree/master/modules/openapi-generator-gradle-plugin)

- [spring generator](https://github.com/OpenAPITools/openapi-generator/blob/master/docs/generators/spring.md)

辺りを参考にしています。

<div class="formalpara-title">

**build.gradle**

</div>

``` groovy
plugins {
    id 'eclipse'
    id 'org.openapi.generator' version '4.3.1'
}

ext {
    openApiOutputDir = "$rootDir/build/generated/openapi"
}

sourceSets.main.java.srcDirs += ["$openApiOutputDir/src/main/java"]

dependencies {
    // これらは自動生成クラスが import しているので必要
    implementation 'org.springframework.boot:spring-boot-starter-validation'
    implementation 'org.openapitools:jackson-databind-nullable:0.2.1'
    compileOnly 'io.swagger:swagger-annotations:1.6.2'
}

openApiGenerate {
    generatorName = 'spring'
    inputSpec = "$rootDir/specs/test.yml"
    outputDir = "$openApiOutputDir"
    apiPackage = 'org.openapi.example.api'
    modelPackage = 'org.openapi.example.model'
    configOptions = [
        dateLibrary: 'java8',
        interfaceOnly: 'true',
        skipDefaultInterface: 'true',
    ]
}

compileJava.dependsOn tasks.openApiGenerate
```

## specs/test.yml

上の `build.gradle` で指定している、今回の OpenAPI spec ファイルです。

- <https://swagger.io/specification/>

``` yml
openapi: "3.0.3"
info:
  title: OpenAPI Sample Project
  version: "1.0"
servers:
  - url: http://localhost:8080

paths:
  /books:
    get:
      description: books listing
      parameters:
        - name: max
          in: query
          schema:
            type: integer
      responses:
        "200":
          description: list of books
          content:
            application/json:
              schema:
                type: object
                $ref: "#/components/schemas/BookListModel"
    post:
      description: bookを登録する(description)
      summary: book登録(summary)
      requestBody:
        required: true
        content:
          "application/json":
            schema:
              $ref: "#/components/schemas/BookModel"
      responses:
        "200":
          description: "登録したbook"
          content:
            application/json:
              schema:
                type: object
                $ref: "#/components/schemas/BookModel"
  /books/{id}:
    get:
      description: books listing
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: integer
            format: int64
      responses:
        "200":
          description: book
          content:
            application/json:
              schema:
                type: object
                $ref: "#/components/schemas/BookModel"

components:
  schemas:
    BookListModel:
      properties:
        books:
          type: array
          items:
            $ref: "#/components/schemas/BookModel"
    BookModel:
      type: object
      properties:
        author:
          type: string
        title:
          type: string
        series:
          type: integer
```

# コード自動生成

    gradle openApiGenerate

で `build/generated/openapi` にソース一式が生成されます。また、 `compileJava.dependsOn tasks.openApiGenerate` と設定しているので、明示せずとも

    gradle build

でも自動生成されます。

# html 生成

- <https://openapi-generator.tech/docs/installation/#jar>

<!-- -->

    curl -L -o openapi-generator-cli.jar https://repo1.maven.org/maven2/org/openapitools/openapi-generator-cli/4.3.1/openapi-generator-cli-4.3.1.jar

でダウンロードして実行:

    java -jar openapi-generator-cli.jar -g html -i spec/test.yml -o html

# 未検証事項/要調査項目など

- controller のインタフェースは自動生成されたものが利用できそうだが、 model はこのまま使って良いのかまだ良くわからない。自動生成したものに手を入れて使う、という用法はありえないと思うので使えないのなら自前でいちから作成する必要が出る。

  - 取り敢えず自動生成されたものを使ってはじめてみる、ということにする。ダメそうならやめれば良いし。

- 上記に関連するが、カスタム制約を設定してそのvalidationアノテーションを付与したく鳴った場合が煩雑そう。

  - 参考: [Swagger Codegenにおけるカスタムバリデーションの追加 - GeekFactory](https://int128.hatenablog.com/entry/2017/08/14/014253)

    - 他にやってそうな人が全然いないのも気になる…
