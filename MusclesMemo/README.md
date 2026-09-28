# MusclesMemoApp（筋トレメモ）

SwiftUI と SwiftData で作成した、iOS 向けの筋トレ記録アプリです。

## Features

- カレンダーで記録のある日を確認し、日ごとに種目・セット（重量・回数）を記録
- 重量モード：通常 / 自重 / アシスト（軽減重量）
- 種目の重量を一括で登録
- 別の日の記録をまるごとコピー
- 部位別の種目管理と検索
- グラフ：部位別のトレーニング頻度、種目ごとの最大重量・総ボリューム・推定 1RM の推移

## Requirements

- Xcode 16 以降
- iOS 17 以降

## Getting Started

`MusclesMemoApp.xcodeproj` を Xcode で開いて実行してください。
プロジェクトは [XcodeGen](https://github.com/yonaskolb/XcodeGen) の `project.yml` から生成しています。

```bash
xcodegen generate
```

## Tests

Xcode で `⌘U`、またはコマンドラインで実行します。

```bash
xcodebuild test -project MusclesMemoApp.xcodeproj -scheme MusclesMemoApp -destination 'platform=iOS Simulator,name=iPhone 17'
```
