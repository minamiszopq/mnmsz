# App Portfolio

個人開発したモバイルアプリのポートフォリオです。

## Projects

| Project | Tech | Description |
| --- | --- | --- |
| [ShukatsuManager](./ShukatsuManager)（選考ノート） | Flutter / Riverpod / drift | 就活の応募企業・選考状況・予定を管理。ローカル通知、CSV 入出力に対応。企画書から設計・テストまで作成 |
| [MusclesMemo](./MusclesMemo)（筋トレメモ） | SwiftUI / SwiftData / Swift Charts | 筋トレの記録をカレンダーで管理し、重量・ボリューム・推定 1RM の推移をグラフで表示 |
| [Map](./Map) | SwiftUI / MapKit / Overpass API | 場所検索と現在地表示に加え、OpenStreetMap のデータで高速道路を強調表示 |
| [Weather](./Weather) | SwiftUI / OpenWeather API | 都市名の候補検索、現在の天気と 3 時間ごとの予報を表示 |
| [Memo](./Memo) | SwiftUI | フォルダ階層とドラッグ＆ドロップに対応したメモアプリ |

## 取り組んだこと

- **設計**: 画面とデータ処理を分け、ロジックはユニットテストで検証（ShukatsuManager、MusclesMemo）
- **ドキュメント**: 企画書と仕様の判断メモを残し、判断の経緯をたどれるようにした（[ShukatsuManager/docs](./ShukatsuManager/docs)）
- **非同期処理**: 検索の入力待ち（デバウンス）とキャンセル、古いレスポンスの破棄、複数 API サーバーへのフォールバック（Weather、Map）
- **データ保全**: スキーマ変更への対応、削除の取り消し（Undo）、CSV によるデータ移行

各フォルダの README に、機能と実行方法を記載しています。
