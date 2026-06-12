import Foundation

// OpenWeatherへの通信とレスポンス検証を担当する。
struct WeatherService {
    private var apiKey: String {
        Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String ?? ""
    }
    private let weatherBaseURL = URL(string: "https://api.openweathermap.org/data/2.5")!
    private let geocodingURL = URL(string: "https://api.openweathermap.org/geo/1.0/direct")!

    func fetchWeather(at location: LocationSuggestion) async throws -> WeatherResponse {
        try await requestWeather(path: "weather", location: location)
    }

    func fetchForecast(at location: LocationSuggestion) async throws -> ForecastResponse {
        try await requestWeather(path: "forecast", location: location)
    }

    // 入力文字列から最大5件の都市候補を取得する。
    func fetchLocations(matching query: String) async throws -> [LocationSuggestion] {
        guard var components = URLComponents(url: geocodingURL, resolvingAgainstBaseURL: false) else {
            throw WeatherServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "q", value: normalizedCityName(query)),
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        return try await performRequest(components: components)
    }

    // 候補の緯度経度を使うことで、同名都市も正確に取得できる。
    private func requestWeather<Response: Decodable>(
        path: String,
        location: LocationSuggestion
    ) async throws -> Response {
        let endpoint = weatherBaseURL.appending(path: path)
        guard var components = URLComponents(url: endpoint, resolvingAgainstBaseURL: false) else {
            throw WeatherServiceError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(name: "lat", value: String(location.latitude)),
            URLQueryItem(name: "lon", value: String(location.longitude)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ja")
        ]

        return try await performRequest(components: components)
    }

    private func performRequest<Response: Decodable>(components: URLComponents) async throws -> Response {
        guard !apiKey.isEmpty else {
            throw WeatherServiceError.missingAPIKey
        }

        guard let url = components.url else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200..<300:
            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw WeatherServiceError.invalidData
            }
        case 404:
            throw WeatherServiceError.cityNotFound
        case 401:
            throw WeatherServiceError.authenticationFailed
        default:
            throw WeatherServiceError.serverError(httpResponse.statusCode)
        }
    }

    // 日本語検索に対応していない代表的な都市名を補完する。
    private func normalizedCityName(_ city: String) -> String {
        let aliases = [
            "東京": "Tokyo", "大阪": "Osaka", "京都": "Kyoto",
            "横浜": "Yokohama", "札幌": "Sapporo", "仙台": "Sendai",
            "名古屋": "Nagoya", "神戸": "Kobe", "広島": "Hiroshima",
            "福岡": "Fukuoka", "那覇": "Naha"
        ]

        return aliases[city] ?? city
    }
}

enum WeatherServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case invalidData
    case cityNotFound
    case authenticationFailed
    case serverError(Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenWeather APIキーが設定されていません。"
        case .invalidURL:
            return "リクエストを作成できませんでした。"
        case .invalidResponse:
            return "サーバーから正しい応答がありませんでした。"
        case .invalidData:
            return "天気データを読み取れませんでした。"
        case .cityNotFound:
            return "都市が見つかりません。別の名前で検索してください。"
        case .authenticationFailed:
            return "APIキーを確認してください。"
        case .serverError(let statusCode):
            return "サーバーエラーが発生しました（\(statusCode)）。"
        }
    }
}
