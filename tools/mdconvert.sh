#!/bin/bash

# 変換したいディレクトリのパスを指定
DIR_PATH="content"

# ディレクトリ内のすべての.adocファイルを検索して変換
find "$DIR_PATH" -name "*.adoc" -type f | while read -r file; do
    # 出力ファイルパスを設定
    xml_file="${file%.adoc}.xml"
    md_file="${file%.adoc}.md"
    
    echo "変換中: $file"
    
    # DocBookに変換
    asciidoc -b docbook "$file"
    
    # DocBookからMarkdownに変換
    pandoc -f docbook -t markdown "$xml_file" -o "$md_file"
    
    # 中間XMLファイルを削除
    rm "$xml_file"
    
    echo "完了: $md_file"
done

echo "すべてのファイルの変換が完了しました。"
