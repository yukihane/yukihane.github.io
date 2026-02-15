---
title: "Spring BootのRestTemplateで text/plain;Windows-31J なRESTレスポンスを処理する"
date: 2020-01-26T14:48:47Z
draft: false
tags:
  - spring-boot
  - jackson
---

# 要旨

JSONを返してくるのだけれどMIME typeが `text/plain;charset=Windows-31J` なレスポンスを、RestTemplateで扱いたい。

    @GetMapping(produces = "text/plain;charset=Windows-31J")
    public String response() {
        return "{\"text\": \"こんにちは世界\" }";
    }

対応としては、 `JSonFactory#createParser(InputStream)` をオーバライドして `InputStreamReader` 用のパーサが利用されるようにすれば良い。

    @RequiredArgsConstructor
    public class NonUtf8JsonFactory extends JsonFactory {
        private static final long serialVersionUID = 6370213897913075391L;

        @NonNull
        private final Charset charset;

        @Override
        public JsonParser createParser(final InputStream in) throws IOException, JsonParseException {
            return createParser(new InputStreamReader(in, charset));
        }
    }

上記のオブジェクトを `ObjectMapper` のコンストラクタで渡す:

    final Charset win31j = Charset.forName("Windows-31J");
    final ObjectMapper mapper = new ObjectMapper(new NonUtf8JsonFactory(win31j));

    final MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter(mapper);
    converter
        .setSupportedMediaTypes(Arrays.asList(new MediaType(MediaType.TEXT_PLAIN, win31j)));

    final RestTemplate rt = restTemplateBuilder
        .additionalMessageConverters(Arrays.asList(converter))
        .build();

# 問題再現

[`JsonSjisExampleApplication.java` (hash: b0e5ae3)](https://github.com/yukihane/hello-java/blob/b0e5ae3/spring/json-sjis-example/src/main/java/com/example/jsonsjisexample/JsonSjisExampleApplication.java)

このコードを実行する

    mvn spring-boot:run

と、次のようなエラーになります:

    java.lang.IllegalStateException: Failed to execute ApplicationRunner
    ...
    Caused by: org.springframework.web.client.HttpClientErrorException$NotAcceptable: 406 : [{"timestamp":"2020-01-27T13:56:35.979+0000","status":406,"error":"Not Acceptable","message":"Could not find acceptable representation","trace":"org.springframework.web.HttpMediaTypeNotAcceptableExcept... (4837 bytes)]
        at org.springframework.web.client.HttpClientErrorException.create(HttpClientErrorException.java:121) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at org.springframework.web.client.DefaultResponseErrorHandler.handleError(DefaultResponseErrorHandler.java:170) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at org.springframework.web.client.DefaultResponseErrorHandler.handleError(DefaultResponseErrorHandler.java:112) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at org.springframework.web.client.ResponseErrorHandler.handleError(ResponseErrorHandler.java:63) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at org.springframework.web.client.RestTemplate.handleResponse(RestTemplate.java:785) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at org.springframework.web.client.RestTemplate.doExecute(RestTemplate.java:743) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at org.springframework.web.client.RestTemplate.execute(RestTemplate.java:677) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at org.springframework.web.client.RestTemplate.getForObject(RestTemplate.java:318) ~[spring-web-5.2.3.RELEASE.jar:5.2.3.RELEASE]
        at com.example.jsonsjisexample.JsonSjisExampleApplication.run(JsonSjisExampleApplication.java:44) ~[classes/:na]
        at org.springframework.boot.SpringApplication.callRunner(SpringApplication.java:775) ~[spring-boot-2.2.4.RELEASE.jar:2.2.4.RELEASE]
        ... 10 common frames omitted

この `406` エラーは、コンバータのメソッド `setSupportedMediaTypes` で `text/plain;Windows-31J` を設定することで対応できます。 [コード差分(hash: 31c21)](https://github.com/yukihane/hello-java/commit/31c210bcc92ae2e3ae6f40bc7969381e660baac4#diff-33eba75c3f44ef5100b33ccb428c6713):

    final MappingJackson2HttpMessageConverter converter = new MappingJackson2HttpMessageConverter();
    converter.setSupportedMediaTypes(Arrays.asList(new MediaType(MediaType.TEXT_PLAIN, Charset.forName("Windows-31J"))));

    final RestTemplate rt = restTemplateBuilder
        .additionalMessageConverters(Arrays.asList(converter))
        .build();

この対応を入れたコードを実行してみます。すると別のエラーが出るようになります。

    Caused by: com.fasterxml.jackson.core.JsonParseException: Invalid UTF-8 start byte 0x82
     at [Source: (PushbackInputStream); line: 1, column: 12]
        at com.fasterxml.jackson.core.JsonParser._constructError(JsonParser.java:1840) ~[jackson-core-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.core.base.ParserMinimalBase._reportError(ParserMinimalBase.java:712) ~[jackson-core-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.core.json.UTF8StreamJsonParser._reportInvalidInitial(UTF8StreamJsonParser.java:3569) ~[jackson-core-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.core.json.UTF8StreamJsonParser._reportInvalidChar(UTF8StreamJsonParser.java:3565) ~[jackson-core-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.core.json.UTF8StreamJsonParser._finishString2(UTF8StreamJsonParser.java:2511) ~[jackson-core-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.core.json.UTF8StreamJsonParser._finishAndReturnString(UTF8StreamJsonParser.java:2437) ~[jackson-core-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.core.json.UTF8StreamJsonParser.getText(UTF8StreamJsonParser.java:293) ~[jackson-core-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.databind.deser.std.StringDeserializer.deserialize(StringDeserializer.java:35) ~[jackson-databind-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.databind.deser.std.StringDeserializer.deserialize(StringDeserializer.java:10) ~[jackson-databind-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.databind.deser.impl.MethodProperty.deserializeAndSet(MethodProperty.java:129) ~[jackson-databind-2.10.2.jar:2.10.2]
        at com.fasterxml.jackson.databind.deser.BeanDeserializer.deserializeFromObject(BeanDeserializer.java:369) ~[jackson-databind-2.10.2.jar:2.10.2]
        ... 21 common frames omitted

これが今回の問題の核です。

# 問題解説

[RFC7159 - 8.1.Character Encoding](https://tools.ietf.org/html/rfc7159#section-8.1)では、JSONの文字エンコーディングは UTF-8, UTF-16, UTF-32 のいずれかであることが求められており、Jackson実装はこれに基づいて行われているようです [^1]。

- [Charset autodetection fail \#222](https://github.com/FasterXML/jackson-core/issues/222)

具体的には、 `InputStream` を上記3エンコーディングのうちいずれかであるとみなしてパースするため、それ以外のエンコーディングだった場合、期待通りパースできません。それが上記のエラーです。

この問題を回避するためには、 `InputStream` を引数に取るパーサを利用せず、代わりに `Reader` を引数に取るパーサを利用するようにします。これが冒頭の回避策です。

    public JsonParser createParser(final InputStream in) {
        return createParser(new InputStreamReader(in, charset));
    }

[問題に対応した最終的なコード(hash: ce596e)](https://github.com/yukihane/hello-java/blob/ce596eb7edc2c3c75f8eecab21ab5328795af1bb/spring/json-sjis-example/src/main/java/com/example/jsonsjisexample/JsonSjisExampleApplication.java)

[^1]: ちなみにより新しい [RFC8259](https://tools.ietf.org/html/rfc8259#section-8.1) では、UTF-8でなければならない、と更に制限されています。
