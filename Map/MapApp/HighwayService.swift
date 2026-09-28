import Foundation
import MapKit
import Combine

struct HighwayRoute: Identifiable {
    let id: Int64
    let name: String
    let isLink: Bool
    let coordinates: [CLLocationCoordinate2D]
}

@MainActor
final class HighwayService: ObservableObject {
    @Published private(set) var routes: [HighwayRoute] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let endpoints = [
        URL(string: "https://maps.mail.ru/osm/tools/overpass/api/interpreter")!,
        URL(string: "https://overpass-api.de/api/interpreter")!,
        URL(string: "https://overpass.private.coffee/api/interpreter")!
    ]
    private var cache: [RegionKey: [HighwayRoute]] = [:]
    private var routeStore: [Int64: HighwayRoute] = [:]
    private var currentKey: RegionKey?
    private var requestTask: Task<Void, Never>?

    // 表示範囲より少し広い領域を取得し、地図移動時の線切れを防ぐ。
    func load(in region: MKCoordinateRegion) {
        guard region.span.latitudeDelta <= 4, region.span.longitudeDelta <= 4 else {
            requestTask?.cancel()
            currentKey = nil
            routes = []
            isLoading = false
            errorMessage = "地図を拡大すると高速道路を表示します。"
            return
        }

        let key = RegionKey(region: region)
        guard key != currentKey else { return }

        currentKey = key
        errorMessage = nil

        if let cached = cache[key] {
            merge(cached)
            return
        }

        requestTask?.cancel()
        requestTask = Task { [weak self] in
            guard let self else { return }
            isLoading = true
            defer { isLoading = false }

            do {
                let loadedRoutes = try await fetchRoutes(for: key)
                try Task.checkCancellation()
                cache[key] = loadedRoutes
                merge(loadedRoutes)
            } catch is CancellationError {
                return
            } catch {
                guard currentKey == key else { return }
                currentKey = nil
                errorMessage = error.localizedDescription
            }
        }
    }

    func retry(in region: MKCoordinateRegion) {
        currentKey = nil
        load(in: region)
    }

    // 新しい取得範囲だけで置き換えず、隣接範囲の道路と結合して表示する。
    private func merge(_ loadedRoutes: [HighwayRoute]) {
        for route in loadedRoutes {
            routeStore[route.id] = route
        }
        routes = Array(routeStore.values)
    }

    private func fetchRoutes(for key: RegionKey) async throws -> [HighwayRoute] {
        let bbox = "(\(key.south),\(key.west),\(key.north),\(key.east))"
        let query = """
        [out:json][timeout:20];
        (
          way["highway"~"^(motorway|motorway_link)$"]\(bbox);
          way["expressway"="yes"]\(bbox);
          way["motorroad"="yes"]["highway"~"^(trunk|trunk_link)$"]\(bbox);
        );
        out tags geom;
        """

        var lastError: Error = HighwayError.allServersUnavailable

        // 公共サーバーの混雑に備え、同じ問い合わせを順番に試す。
        for endpoint in endpoints {
            try Task.checkCancellation()

            do {
                let data = try await fetch(query: query, from: endpoint)
                return try decodeRoutes(from: data)
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                lastError = error
            }
        }

        throw lastError
    }

    private func fetch(query: String, from endpoint: URL) async throws -> Data {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "data", value: query)]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.httpBody = components.percentEncodedQuery?.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("MapApp/1.0 iOS", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 20

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HighwayError.invalidResponse
        }
        guard 200..<300 ~= httpResponse.statusCode else {
            throw HighwayError.httpStatus(httpResponse.statusCode)
        }
        return data
    }

    private func decodeRoutes(from data: Data) throws -> [HighwayRoute] {
        let result = try JSONDecoder().decode(OverpassResponse.self, from: data)
        return result.elements.compactMap { element in
            guard let geometry = element.geometry, geometry.count > 1 else { return nil }

            return HighwayRoute(
                id: element.id,
                name: element.tags?.name ?? element.tags?.ref ?? "高速道路",
                isLink: element.tags?.highway?.hasSuffix("_link") == true,
                coordinates: geometry.map {
                    CLLocationCoordinate2D(latitude: $0.lat, longitude: $0.lon)
                }
            )
        }
    }
}

private struct RegionKey: Hashable {
    let south: Double
    let west: Double
    let north: Double
    let east: Double

    init(region: MKCoordinateRegion) {
        // 画面外まで取得することで、端に接する道路も途中で切れにくくする。
        let latitudePadding = max(region.span.latitudeDelta * 0.6, 0.03)
        let longitudePadding = max(region.span.longitudeDelta * 0.6, 0.03)
        let grid = 0.02

        south = floor(
            (region.center.latitude - region.span.latitudeDelta / 2 - latitudePadding) / grid
        ) * grid
        west = floor(
            (region.center.longitude - region.span.longitudeDelta / 2 - longitudePadding) / grid
        ) * grid
        north = ceil(
            (region.center.latitude + region.span.latitudeDelta / 2 + latitudePadding) / grid
        ) * grid
        east = ceil(
            (region.center.longitude + region.span.longitudeDelta / 2 + longitudePadding) / grid
        ) * grid
    }
}

private struct OverpassResponse: Decodable {
    let elements: [OverpassElement]
}

private struct OverpassElement: Decodable {
    let id: Int64
    let tags: Tags?
    let geometry: [Point]?

    struct Tags: Decodable {
        let highway: String?
        let name: String?
        let ref: String?
    }

    struct Point: Decodable {
        let lat: Double
        let lon: Double
    }
}

private enum HighwayError: LocalizedError {
    case allServersUnavailable
    case invalidResponse
    case httpStatus(Int)

    var errorDescription: String? {
        switch self {
        case .allServersUnavailable:
            "無料データサーバーが混雑しています。"
        case .invalidResponse:
            "サーバーから正しい応答がありませんでした。"
        case .httpStatus(let status):
            "サーバーエラー（\(status)）"
        }
    }
}
