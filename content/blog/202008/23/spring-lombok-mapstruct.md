---
title: "Spring BootプロジェクトにLombokとMapStructを追加する(Eclipse & Maven/Gradle)"
date: 2020-08-23T03:23:31Z
draft: false
tags:
  - eclipse
  - gradle
  - maven
  - lombok
  - mapstruct
---

(2021-10-16 更新)

Spring Boot プロジェクトにLombokとMapStructを追加し、かつ Eclipse で開発を行う場合の設定です。

同じようなことを何回か書いてきた気がするのですが、結局どうすれば良いの？というのをまとめて書いたものが無いっぽいので改めて記事に起こしました。

# 実コード

- <https://github.com/yukihane/hello-java/tree/master/spring/lombok-mapstruct-example>

# まとめ

- MapStruct 1.4.0 以降を利用する。

- Lombok 1.18.16 以降を利用する。

- lombok-mapstruct-binding も annoation processor として追加する([参考]({{< relref"/blog/202011/14/mapstruct-with-spring-boot-2.3.5" >}}))。

- (Maven) `maven-compiler-plugin` で anotation processing を行う。

- (Gradle) Buildshipは利用せず、 `eclipse`, `com.diffplug.eclipse.apt` プラグインを利用し Eclipse プロジェクトへ変換する。

# 設定ポイント

コードの全体は、冒頭のリンク先参照。

## Maven

<div class="formalpara-title">

**pom.xml**

</div>

``` xml
  <dependencies>
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <optional>true</optional>
    </dependency>
    <dependency>
      <groupId>org.mapstruct</groupId>
      <artifactId>mapstruct</artifactId>
      <version>${mapstruct.version}</version>
    </dependency>
  </dependencies>

  <build>
    <pluginManagement>
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-compiler-plugin</artifactId>
          <version>3.6.2</version>
          <configuration>
            <annotationProcessorPaths>
              <path>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct-processor</artifactId>
                <version>${mapstruct.version}</version>
              </path>
              <path>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok</artifactId>
                <version>${lombok.version}</version>
              </path>
              <!-- https://mapstruct.org/faq/#Can-I-use-MapStruct-together-with-Project-Lombok -->
              <path>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok-mapstruct-binding</artifactId>
                <version>${lombok-mapstruct-binding.version}</version>
              </path>
            </annotationProcessorPaths>
            <compilerArgs>
              <compilerArg>
                -Amapstruct.defaultComponentModel=spring
              </compilerArg>
            </compilerArgs>
          </configuration>
        </plugin>
      </plugins>
    </pluginManagement>
    ...
  <build>
```

## Gradle

<div class="formalpara-title">

**build.gradle**

</div>

    plugins {
        id 'eclipse'
        id 'com.diffplug.eclipse.apt' version '3.24.0'
    }

    dependencies {
        implementation "org.mapstruct:mapstruct:$mapstructVersion"
        compileOnly 'org.projectlombok:lombok'
        annotationProcessor "org.mapstruct:mapstruct-processor:$mapstructVersion"
        annotationProcessor 'org.projectlombok:lombok'
        // https://mapstruct.org/faq/#Can-I-use-MapStruct-together-with-Project-Lombok
        annotationProcessor "org.projectlombok:lombok-mapstruct-binding:$lombokMapstructBindingVersion"
    }

    compileJava {
        aptOptions {
            processorArgs = [
                'mapstruct.defaultComponentModel': 'spring',
            ]
        }
    }

なお、Eclipseにインポートする際には、 "Existing Gradle Project" メニュー [^1] からでなく、次のコマンドを実行した後、"**Existing Projects into Workspace**" でインポートします。

    gradle eclipse

[^1]: これがBuildshipでのインポートです。
