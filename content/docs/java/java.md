---
title: "Java"
date: 2020-07-23T17:19:26Z
draft: false
---

# Mavenで差分コンパイルできない

常に

> \[INFO\] Changes detected - recompiling the module!

というメッセージが出て全コンパイルが行われる事象。

- <http://stackoverflow.com/a/19653164/4506703>

- <http://stackoverflow.com/a/17948010/4506703>

`false` を設定することで、本来この機能に期待されている **賢い** インクリメンタルコンパイルが行われなくなる。 (この賢いインクリメンタルコンパイル機能がバグっているため、全ファイル変更されたと見なされているのが現状。)

上記設定をfalseにすると、代わりに 通常の インクリメンタルコンパイルが行われる。 この結果、大半の場合にはfalseにした方がコンパイル時間は短縮される。

ただし、後者の 通常の インクリメンタルコンパイルは、ファイル間の依存関係などを考慮しない(、のだと思われる)。 そのため、おそらく、変更したファイルのみが再コンパイル対象となり、例えば他ファイルが使用しているインタフェースが変わった場合、使用側は再コンパイルされないため実行時エラーになる(と思われる)。

- 常に再コンパイルが走るよりはまし。上記のような場合には手動でcleanすればよい。

- CI環境ではcleanからビルドを始めるので影響はない。

# lombok install

- <http://qiita.com/satty3104/items/42fc67a7e9fca0f807a9>

\`java -jar lombok.jar\`だとMacのEclipse Neonにインストールできなかった。手動インストールが必要。

lombok.jarを所定の場所に配置:

    mv lombok.jar Eclipse.app/Contents/MacOS/

`` Eclipse.app/Contents/Eclipse/eclipse.ini`に ``-vmargs\`セクションがあるので、そこにの行を追記:

    -Xbootclasspath/a:lombok.jar
    -javaagent:lombok.jar

# Maven POM

## Javaバージョン指定

    <maven.compiler.target>11</maven.compiler.target>
    <maven.compiler.source>11</maven.compiler.source>

## formatter

[formatter-maven-plugin](https://github.com/revelc/formatter-maven-plugin)を利用する。

        <build>
            <plugins>
                <plugin>
                    <groupId>net.revelc.code.formatter</groupId>
                    <artifactId>formatter-maven-plugin</artifactId>
                    <version>2.8.1</version>
                    <configuration>
                        <compilerCompliance>${java.version}</compilerCompliance>
                        <compilerSource>${java.version}</compilerSource>
                        <compilerTargetPlatform>${java.version}</compilerTargetPlatform>
                        <configFile>https://raw.githubusercontent.com/yukihane/prefs/master/eclipse/java-format-setting.xml</configFile>
                        <lineEnding>LF</lineEnding>
                        <skipCssFormatting>true</skipCssFormatting>
                        <skipHtmlFormatting>true</skipHtmlFormatting>
                        <skipJavaFormatting>false</skipJavaFormatting>
                        <skipJsFormatting>true</skipJsFormatting>
                        <skipJsonFormatting>true</skipJsonFormatting>
                        <skipXmlFormatting>false</skipXmlFormatting>
                    </configuration>
                    <executions>
                        <execution>
                            <goals>
                                <goal>format</goal>
                            </goals>
                        </execution>
                    </executions>
                </plugin>

## Apache POI

- <http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.apache.poi%22>

- <https://poi.apache.org/overview.html>

xlsxファイルを操作したい場合は\`poi-ooxml\`を追加すれば残りの必要なものは依存関係で自動で入る。

    <dependency>
        <groupId>org.apache.poi</groupId>
        <artifactId>poi-ooxml</artifactId>
        <version>3.16-beta2</version>
    </dependency>

## slf4j

- <http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.slf4j%22>

- <https://www.slf4j.org/manual.html#projectDep>

- <https://www.slf4j.org/faq.html#maven2>

<!-- -->

    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-api</artifactId>
      <version>1.7.23</version>
    </dependency>
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-simple</artifactId>
      <version>1.7.23</version>
    </dependency>

## lombok

- <http://search.maven.org/#search%7Cga%7C1%7Cg%3A%22org.projectlombok%22>

- <https://projectlombok.org/mavenrepo/>

<!-- -->

    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.16.14</version>
    </dependency>
