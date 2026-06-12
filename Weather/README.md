# WeatherApp

SwiftUIで作成したiOS向け天気予報アプリです。OpenWeather APIから現在の天気と3時間ごとの予報を取得します。

## Features

- 都市名による検索候補
- 現在の気温・体感温度・湿度・風速の表示
- 3時間ごとの天気予報
- Pull to Refreshによる更新

## Requirements

- Xcode 17以降
- iOS 26以降
- [OpenWeather API key](https://openweathermap.org/api)

## API Key Setup

1. Xcodeで `WeatherApp.xcodeproj` を開きます。
2. WeatherAppターゲットのInfo設定に `OpenWeatherAPIKey` というString項目を追加します。
3. 値に自分のOpenWeather APIキーを設定します。

APIキーはリポジトリへコミットしないでください。
