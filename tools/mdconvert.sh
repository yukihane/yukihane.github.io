#!/bin/bash

# 入力と出力のディレクトリパスを指定
INPUT_DIR="content"
OUTPUT_DIR="content_new"

# 出力ディレクトリが存在しない場合は作成
mkdir -p "$OUTPUT_DIR"

# ディレクトリ内のすべての.adocファイルを検索して変換
find "$INPUT_DIR" -name "*.adoc" -type f | while read -r file; do
    # 相対パスを取得
    rel_path="${file#$INPUT_DIR/}"
    dir_name=$(dirname "$rel_path")

    # 出力ディレクトリの対応するパスを作成
    output_dir="$OUTPUT_DIR/$dir_name"
    mkdir -p "$output_dir"

    # ファイル名の取得（拡張子なし）
    base_name=$(basename "$file" .adoc)

    # 中間ファイルと出力ファイルのパスを設定
    xml_file="/tmp/${base_name}_$(date +%s).xml"
    md_file="$output_dir/${base_name}.md"

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
