import Foundation

// 3時間ごとの予報レスポンス。
struct ForecastResponse: Decodable {
    let list: [ForecastItem]
    let city: ForecastCity
}

struct ForecastItem: Decodable, Identifiable {
    let dt: Double
    let main: ForecastMain
    let weather: [ForecastWeather]
    let probabilityOfPrecipitation: Double

    // UNIX時刻は各予報で一意になる。
    var id: Double { dt }

    enum CodingKeys: String, CodingKey {
        case dt, main, weather
        case probabilityOfPrecipitation = "pop"
    }
}

struct ForecastMain: Decodable {
    let temp: Double
}

struct ForecastWeather: Decodable {
    let main: String
}

struct ForecastCity: Decodable {
    let timezone: Int
}
