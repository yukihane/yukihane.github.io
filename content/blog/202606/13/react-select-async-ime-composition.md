---
title: "react-select の AsyncSelect が IME 確定後に検索を再実行しない"
date: 2026-06-13T00:00:00+09:00
tags: ["react", "react-select", "IME", "日本語入力"]
draft: false
---

## TL;DR

- react-select の `AsyncSelect` は、IME（日本語入力）で文字を確定した後に `loadOptions` を再呼び出ししないケースがあります。
- 原因は `compositionEnd` 後に `inputValue` が内部的に「変化なし」と判定され、検索が再トリガーされないことです。
- `AsyncSelect` の `loadOptions` パターンをやめ、通常の `Select` + controlled `inputValue` + `useEffect` による自前検索に切り替えることで解決しました。

---

## 症状

非同期検索付きのセレクトボックスを `react-select` の `AsyncSelect` で実装していました。ユーザーがキーワードを入力すると API を呼んで候補を表示する、よくあるパターンです。

英字入力では問題なく動作するのですが、日本語入力で以下の現象が起きます:

- 「高」と入力 → 「高木」「高橋」などの候補が表示される ✅
- 「高木」と入力 → **候補が何も表示されない** ❌

1文字なら動きます。2文字以上の日本語キーワードで候補が出ません。

---

## 前提: AsyncSelect の検索メカニズム

`AsyncSelect` は `loadOptions` という callback を受け取り、ユーザーの入力が変わるたびにこれを呼び出します。

```tsx
<AsyncSelect
  loadOptions={(inputValue, callback) => {
    // inputValue が変わるたびに呼ばれる
    fetch(`/api/search?q=${inputValue}`)
      .then(res => res.json())
      .then(data => callback(data))
  }}
/>
```

内部的には `inputValue` の state が変わったタイミングで `loadOptions` が発火します。

---

## 衝突: IME の composition イベントと react-select の内部状態

日本語入力では、ブラウザが以下の順序でイベントを発火します:

1. `compositionStart` — IME 変換開始（「た」「たか」「たかぎ」...）
2. `input` / `change` — 変換中の中間文字列がフィールドに反映
3. `compositionEnd` — 確定（「高木」）
4. 最終的な `change` イベント

問題は **ステップ 2 の時点で react-select の内部 `inputValue` が中間文字列で更新されてしまう** ことです。

IME 変換中の不要な検索を防ぐため、`compositionStart`/`compositionEnd` をフックして `isComposing` フラグを管理し、変換中は `loadOptions` 内で `callback([])` して即 return する実装にしていました:

```tsx
const isComposingRef = useRef(false)

const selectComponents = useMemo(() => ({
  Input: (props) => (
    <components.Input
      {...props}
      onCompositionStart={() => { isComposingRef.current = true }}
      onCompositionEnd={() => { isComposingRef.current = false }}
    />
  ),
}), [])

const loadOptions = useCallback((inputValue, callback) => {
  if (isComposingRef.current) {
    callback([])  // ← 変換中は検索しない
    return
  }
  // ... API 呼び出し
}, [])
```

一見合理的ですが、ここに落とし穴があります。

---

## `compositionEnd` 後に `loadOptions` が呼ばれない

`compositionEnd` で `isComposingRef.current = false` にしても、**`AsyncSelect` が `loadOptions` を再呼び出ししません**。

なぜか。`AsyncSelect` は `inputValue` の**変更**をトリガーに `loadOptions` を呼びます。IME 変換中のステップ 2 で既に `inputValue` が「高木」相当の値に更新されているため、`compositionEnd` 後に改めて `inputValue` が変わりません。変わらないから `loadOptions` も呼ばれません。

結果として:
- `isComposing = true` の間に `loadOptions` が呼ばれた → `callback([])` で空を返した
- `isComposing = false` になった → でも `loadOptions` はもう呼ばれない
- **候補が空のまま**

これは react-select の既知課題です:
- [#3561: Need to support IME composition in Select](https://github.com/JedWatson/react-select/issues/3561)
- [#1578: onInputChange event fires too many times when inputting Chinese characters](https://github.com/JedWatson/react-select/issues/1578)

---

## 試して失敗したアプローチ

### 1. `isComposing` チェックを debounce の内側に移動

`loadOptions` の先頭で即 return する代わりに、300ms の debounce 後にチェックすれば `compositionEnd` が間に合うのでは、と考えました。

```tsx
debounceTimerRef.current = setTimeout(async () => {
  if (isComposingRef.current) { // ← debounce 後にチェック
    callback([])
    return
  }
  // ... API 呼び出し
}, 300)
```

**結果: 効果なし。** そもそも `loadOptions` 自体が再呼び出しされないため、debounce の内外は関係ありませんでした。

### 2. `compositionEnd` で `key` をインクリメントして再マウント

```tsx
const [selectKey, setSelectKey] = useState(0)

// compositionEnd で key を変える → コンポーネント再マウント
onCompositionEnd={() => {
  isComposingRef.current = false
  setSelectKey(k => k + 1)  // ← 再マウントを強制
}}

<AsyncSelect key={selectKey} ... />
```

**結果: 症状悪化。** 再マウントで入力中のテキストが消え、ユーザー体験が壊れました。

---

## 修正: `AsyncSelect` をやめて `Select` + controlled `inputValue` + `useEffect`

`AsyncSelect` の `loadOptions` callback パターンに頼ること自体が問題でした。`inputValue` の変更検知を react-select の内部に任せるのではなく、自分で制御します。

```tsx
import Select from 'react-select'  // ← AsyncSelect ではない

const [inputValue, setInputValue] = useState('')
const [isComposing, setIsComposing] = useState(false)
const [options, setOptions] = useState([])
const [isLoading, setIsLoading] = useState(false)

// compositionEnd で inputValue を明示的に更新
const selectComponents = useMemo(() => ({
  Input: (props) => (
    <components.Input
      {...props}
      onCompositionStart={() => setIsComposing(true)}
      onCompositionEnd={(e) => {
        setIsComposing(false)
        setInputValue(e.currentTarget.value)  // ← ここがポイント
      }}
    />
  ),
}), [])

// inputValue の変更を useEffect で検知して検索
useEffect(() => {
  if (isComposing || !inputValue.trim()) {
    setOptions([])
    return
  }
  const timer = setTimeout(async () => {
    setIsLoading(true)
    const result = await searchApi(inputValue)
    setOptions(result)
    setIsLoading(false)
  }, 300)
  return () => clearTimeout(timer)
}, [inputValue, isComposing])

return (
  <Select
    options={options}
    isLoading={isLoading}
    inputValue={inputValue}
    onInputChange={(newValue, { action }) => {
      if (action === 'input-change') {
        setInputValue(newValue)
      }
    }}
    filterOption={null}  // ← サーバーサイド検索なのでクライアントフィルタ無効
    ...
  />
)
```

ポイントは3つです。

1. **`inputValue` を controlled state で管理** — react-select の内部状態に依存しません
2. **`compositionEnd` で `setInputValue(e.currentTarget.value)` を明示呼び出し** — IME 確定後に state が変わることが保証されます
3. **`useEffect` が `inputValue` の変更を検知して検索を発火** — `loadOptions` の再トリガー問題から完全に解放されます

`filterOption={null}` は、通常の `Select` がデフォルトでクライアントサイドフィルタリングを行うため、それを無効化してサーバーサイド検索の結果をそのまま表示させるために必要です。

---

## 落とし穴: `onInputChange` の action を正しく処理する

上記の修正だけだと、**候補を選択した後に選択された人名が表示されない**という問題が起きました。

react-select は `onInputChange` を複数の `action` で呼び出します:

- `'input-change'` — ユーザーがキーボードで入力した
- `'set-value'` — 候補を選択した（このとき `inputValue` を空にリセットしたい）
- `'input-blur'` — フォーカスが外れた
- `'menu-close'` — メニューが閉じた

`action === 'input-change'` のみで `setInputValue` していると、`set-value` 時のリセット（空文字への変更）が反映されず、古い検索キーワードが `inputValue` に残り続けます。結果として `value`（選択済みの値）のラベルが表示されず、検索テキストが表示されます。

```tsx
onInputChange={(newValue, { action }) => {
  if (action === 'input-change') {
    setInputValue(newValue)
  } else if (action === 'set-value' || action === 'menu-close') {
    setInputValue('')  // ← これが必要
  }
}}
```

---

## さらなる改善: React Query への移行

`useEffect` + 直接 API 呼び出しパターンには別の問題もあります:

- **stale response 競合**: ユーザーが素早く入力を変更すると、先行リクエストの古いレスポンスが後発の結果を上書きする
- **状態管理の肥大化**: `options`, `isLoading`, `isError` をコンポーネント内で個別に `useState` 管理

React Query (`useQuery`) に移行するとこれらが自動的に解決されます:

```tsx
// カスタムフック
export const useSearchTargetCandidates = (
  projectId: string,
  keyword: string,
  enabled: boolean,
) => useQuery({
  queryKey: ['target-candidates', projectId, keyword],
  queryFn: () => searchApi(projectId, keyword),
  enabled: enabled && !!keyword.trim(),
  staleTime: 30_000,
})

// コンポーネント
const [debouncedKeyword, setDebouncedKeyword] = useState('')
useEffect(() => {
  const timer = setTimeout(() => setDebouncedKeyword(inputValue), 300)
  return () => clearTimeout(timer)
}, [inputValue])

const { data, isLoading, isError } = useSearchTargetCandidates(
  projectId, debouncedKeyword, !isComposing
)
```

`queryKey` が変わると React Query が古いリクエストの結果を自動破棄するため、stale response 競合は構造的に起きません。`enabled` フラグで IME 変換中の検索抑止も統一的に制御できます。

---

## まとめ

| アプローチ | 結果 |
|---|---|
| `isComposing` チェックを debounce 内に移動 | ❌ `loadOptions` 自体が呼ばれない |
| `key` 変更で再マウント | ❌ 入力テキストが消える |
| `Select` + controlled `inputValue` + `useEffect` | ✅ IME 確定後に確実に検索 |
| + `onInputChange` の `set-value` 対応 | ✅ 候補選択後の値表示を修正 |
| + React Query (`useQuery`) への移行 | ✅ stale response 解消 + 状態管理簡素化 |

`AsyncSelect` の `loadOptions` は便利ですが、IME 入力との相性が悪いです。日本語・中国語・韓国語など CJK 入力を扱うプロジェクトでは、`Select` + 自前の非同期検索（できれば React Query）に切り替えることを推奨します。

---

> *補足: この問題は react-select v5 系で確認しています。react-select の GitHub Issues（[#3561](https://github.com/JedWatson/react-select/issues/3561), [#1578](https://github.com/JedWatson/react-select/issues/1578)）では 2018 年頃から報告されていますが、2026 年現在も根本修正はされていません。*
