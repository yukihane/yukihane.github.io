---
title: "Mapstruct Spring Extensions を試してみる"
date: 2021-10-18T02:44:46+09:00
draft: false
tags:
  - mapstruct
  - spring-boot
---

# はじめに

[MapStruct の公式サイト](https://mapstruct.org/)を見ていると、 [Mapstruct Spring Extensions](https://mapstruct.org/documentation/spring-extensions/reference/html/) なるサブプロジェクトが発足していたので、何者か調べようと試してみました。

結果、これは Spring の [`ConversionService`](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#core-convert-ConversionService-API) の [`Converter`](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#core-convert-Converter-API) と MapStruct の `Mapper` を統合して、実装を少し楽にしよう、というもののようでした。

今回は、 MapStruct の基本的な使い方から始めて、順に Spring Boot に統合していってみます。

ちなみに公式サンプルは [こちら](https://github.com/mapstruct/mapstruct-spring-extensions/tree/main/examples) になります。 (いろいろ機能を紹介するサンプルになっていて本質が分かりづらいので、今回シンプルな実装で試してみています。)

今回のコードはこちらです。

- <https://github.com/yukihane/hello-java/tree/master/spring/mapstruct-spring-extensions-example>

# 実装

## 前提

- Java17

- Spring Boot 2.6.0-M3

- MapStruct 1.4.2.Final

- MapStruct Spring Extensions 0.1.0

[README](https://github.com/yukihane/hello-java/tree/master/spring/mapstruct-spring-extensions-example#readme) にも書いていますが、どのタイミングでもリクエストは次のコマンドで行います。

``` sh
curl --location --request POST 'http://localhost:8080/' \
--header 'Content-Type: application/json' \
--data-raw '{
    "name": "my car",
    "wheel": {
        "size": 100
    },
    "pedal": {
        "size": 20
    }
}'
```

## 1. 普通の使い方で MapStruct を組み込む

- コード: [`c4deee3`](https://github.com/yukihane/hello-java/tree/c4deee39b1856b76ffde0e2841a368812310b316/spring/mapstruct-spring-extensions-example)

``` java
@Data
public class Car {
    private String name;
    private Wheel wheel;
    private Pedal pedal;
}

@Data
public class Wheel {
    private int size;
}

@Data
public class Pedal {
    private int size;
}
```

のようなコードを、

``` java
@Data
public class CarDto {
    private String name;
    private WheelDto steeringWheel;
    private PedalDto footPedal;
}

@Data
public class WheelDto {
    private int wheelSize;
}

@Data
public class PedalDto {
    private int pedalSize;
}
```

にマッピングすることを考えます。 このとき、マッパーは次のような実装になります。

``` java
@Mapper(uses = { WheelMapper.class, PedalMapper.class })
public interface CarMapper {
    @Mappings({
        @Mapping(source = "wheel", target = "steeringWheel"),
        @Mapping(source = "pedal", target = "footPedal"),
    })
    CarDto convert(Car car);
}

@Mapper
public interface WheelMapper {
    @Mapping(source = "size", target = "wheelSize")
    WheelDto convert(Wheel wheel);
}

@Mapper
public interface PedalMapper {
    @Mapping(source = "size", target = "pedalSize")
    PedalDto convert(Pedal pedal);
}
```

マッピング処理を行いたい箇所でマッパーをインジェクションして利用します。

``` java
@RestController
@RequiredArgsConstructor
@Slf4j
public class MyController {

    private final CarMapper carMapper;

    @PostMapping("/")
    public CarDto index(@RequestBody final Car car) {
        log.info("car: {}", car);

        final CarDto dto = carMapper.convert(car);
        log.info("dto: {}", dto);

        return dto;
    }

}
```

## 2. `Converter` として実装する

- コード: [`eb23410`](https://github.com/yukihane/hello-java/tree/eb23410a8327d43d42111a5c384a51c64f3194d0/spring/mapstruct-spring-extensions-example)

マッパーが `org.springframework.core.convert.converter.Converter` を実装したコンポーネントであれば `ConversionService` の仕組みで変換できるよね、というのが次の発想になります。 `extends Converter<_,_>` を加えるだけです(正確には、 MapStruct 変換メソッド名は何でもよかったのですが、 `Converter` を実装するなら `convert` という名前でないといけないので一般的にはメソッド名変更も伴います)。

``` java
@Mapper(uses = { WheelMapper.class, PedalMapper.class })
public interface CarMapper extends Converter<Car, CarDto> {
    @Override
    @Mappings({
        @Mapping(source = "wheel", target = "steeringWheel"),
        @Mapping(source = "pedal", target = "footPedal"),
    })
    CarDto convert(Car car);
}

// (他の2つのマッパーも同様に extends Converter する)
```

そうすると、利用個所ではマッパーの代わりに `ConversionService` をインジェクションして変換できるようになります。

``` java
@RestController
@RequiredArgsConstructor
@Slf4j
public class MyController {

    private final ConversionService conversionService;

    @PostMapping("/")
    public CarDto index(@RequestBody final Car car) {
        log.info("car: {}", car);

        final CarDto dto = conversionService.convert(car, CarDto.class);
        log.info("dto: {}", dto);

        return dto;
    }

}
```

現在、 `CarMapper` で `uses = { WheelMapper.class, PedalMapper.class }` というように、内包するエンティティのマッパーも明示的に指定していますが、 `ConversionService` にどの `Converter` を使って変換するかは任せてしまえるんじゃないか、というのがこのライブラリのモチベーションのようです([参考](https://stackoverflow.com/q/58081224))。

## 3. Mapstruct Spring Extensions を利用する

- コード: [`105b509`](https://github.com/yukihane/hello-java/tree/105b5098d6ccf366c9e501174d279ec8e636ddca/spring/mapstruct-spring-extensions-example)

  1.  アノテーションとアノテーションプロセッサを追加(参考: [2. Set up](https://mapstruct.org/documentation/spring-extensions/reference/html/#setup))します([link](https://github.com/yukihane/hello-java/commit/105b5098d6ccf366c9e501174d279ec8e636ddca#diff-32c322b0f4bd4686efaf6e9e3d6c38524e924a61b10e937f72b1edd4ad97034e))。

  2.  Application クラスに `@SpringMapperConfig` アノテーションを付与します([link](https://github.com/yukihane/hello-java/commit/105b5098d6ccf366c9e501174d279ec8e636ddca#diff-59a1cd626633f05243312e7d5b654d47f437d80b7b9ada8c826800eda16c3b92))。

  3.  マッパーの `uses` 値を `ConversionServiceAdapter.class` に置き換えます([link](https://github.com/yukihane/hello-java/commit/105b5098d6ccf366c9e501174d279ec8e636ddca#diff-fe114dfe3394d15990446499f086103b2e528c78da0939c11cad7e092d02f089))。

この手順の最後で行っている `uses` 値が固定値で良くなる、というのが本ライブラリを使うメリット、ということのようです。
