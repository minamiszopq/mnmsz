import Foundation

// 現在の天気に必要なレスポンス項目。
struct WeatherResponse: Decodable {
    let weather: [Weather]
    let main: MainWeather
    let wind: Wind
    let name: String
    let timezone: Int
}

struct Weather: Decodable {
    let main: String
    let description: String
}

struct MainWeather: Decodable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int

    // APIのsnake_caseをSwiftの命名へ対応付ける。
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
    }
}

struct Wind: Decodable {
    let speed: Double
}
