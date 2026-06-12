import Foundation

// ジオコーディングAPIから受け取る都市候補。
struct LocationSuggestion: Decodable, Identifiable, Equatable {
    let name: String
    let localNames: [String: String]?
    let latitude: Double
    let longitude: Double
    let country: String
    let state: String?

    var id: String { "\(latitude),\(longitude)" }

    // 日本語名があれば優先して表示する。
    var displayName: String {
        localNames?["ja"] ?? name
    }

    var detailText: String {
        [state, localizedCountryName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: "・")
    }

    private var localizedCountryName: String {
        Locale(identifier: "ja_JP").localizedString(forRegionCode: country) ?? country
    }

    enum CodingKeys: String, CodingKey {
        case name, country, state
        case localNames = "local_names"
        case latitude = "lat"
        case longitude = "lon"
    }
}
