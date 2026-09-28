import SwiftUI
import MapKit
import Combine

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var highwayService = HighwayService()

    @State private var position = MapCameraPosition.region(.tokyoStation)
    @State private var visibleRegion = MKCoordinateRegion.tokyoStation
    @State private var searchText = ""
    @State private var searchResults: [Place] = []
    @State private var selectedPlaceID: UUID?
    @State private var mapStyle: MapStyleOption = .standard
    @State private var highlightsHighways = true
    @State private var isSearching = false
    @State private var searchError: String?
    @State private var hasCenteredOnUser = false

    private var selectedPlace: Place? {
        searchResults.first { $0.id == selectedPlaceID }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Map(position: $position, selection: $selectedPlaceID) {
                    UserAnnotation()

                    if highlightsHighways {
                        // 黒い縁取りの上へ本線を重ね、地図の種類を問わず見やすくする。
                        ForEach(highwayService.routes) { highway in
                            MapPolyline(coordinates: highway.coordinates)
                                .stroke(
                                    .black.opacity(0.48),
                                    lineWidth: highway.isLink ? 7 : 11
                                )

                            MapPolyline(coordinates: highway.coordinates)
                                .stroke(
                                    highway.isLink ? .yellow : .orange,
                                    lineWidth: highway.isLink ? 4 : 7
                                )
                        }
                    }

                    ForEach(searchResults) { place in
                        Marker(place.name, coordinate: place.coordinate)
                            .tint(.red)
                            .tag(place.id)
                    }
                }
                .mapStyle(mapStyle.style)
                .mapControls {
                    MapCompass()
                    MapScaleView()
                }
                .onMapCameraChange(frequency: .onEnd) { context in
                    visibleRegion = context.region
                    guard highlightsHighways else { return }
                    // 操作中の連続通信を避け、カメラ停止後だけ道路を更新する。
                    highwayService.load(in: context.region)
                }
                .ignoresSafeArea(edges: .bottom)
                .overlay(alignment: .topLeading) {
                    if highlightsHighways {
                        HighwayLegend(
                            isLoading: highwayService.isLoading,
                            errorMessage: highwayService.errorMessage,
                            retry: {
                                highwayService.retry(in: visibleRegion)
                            }
                        )
                            .padding(12)
                    }
                }

                if let place = selectedPlace {
                    PlaceCard(place: place) {
                        openInMaps(place)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationTitle("マップ")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "場所や施設を検索")
            .onSubmit(of: .search, search)
            .searchSuggestions {
                if isSearching {
                    Label("検索中…", systemImage: "magnifyingglass")
                } else if searchResults.isEmpty && !searchText.isEmpty {
                    Text("入力後に検索キーを押してください")
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Picker("地図の種類", selection: $mapStyle) {
                            ForEach(MapStyleOption.allCases) { option in
                                Label(option.title, systemImage: option.systemImage)
                                    .tag(option)
                            }
                        }

                        Divider()

                        Toggle(isOn: $highlightsHighways) {
                            Label("高速道路を強調", systemImage: "road.lanes")
                        }
                    } label: {
                        Label("地図の種類", systemImage: "map")
                    }

                    Button(action: centerOnUser) {
                        Label("現在地", systemImage: "location.fill")
                    }
                }
            }
            .overlay {
                if isSearching {
                    ProgressView("検索中…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                }
            }
            .animation(.snappy, value: selectedPlaceID)
            .task {
                highwayService.load(in: visibleRegion)
            }
            .onChange(of: highlightsHighways) { _, isEnabled in
                if isEnabled {
                    highwayService.load(in: visibleRegion)
                }
            }
            .onReceive(locationManager.$location.compactMap { $0 }) { location in
                guard !hasCenteredOnUser else { return }
                hasCenteredOnUser = true
                moveCamera(to: location)
            }
            .alert("位置情報を利用できません", isPresented: locationAlertBinding) {
                if locationManager.authorizationStatus == .denied {
                    Button("設定を開く") {
                        locationManager.openSettings()
                    }
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text(locationManager.errorMessage ?? "位置情報の設定を確認してください。")
            }
            .alert("検索できませんでした", isPresented: searchAlertBinding) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(searchError ?? "時間をおいてもう一度お試しください。")
            }
        }
    }

    private var locationAlertBinding: Binding<Bool> {
        Binding(
            get: { locationManager.errorMessage != nil },
            set: { if !$0 { locationManager.errorMessage = nil } }
        )
    }

    private var searchAlertBinding: Binding<Bool> {
        Binding(
            get: { searchError != nil },
            set: { if !$0 { searchError = nil } }
        )
    }

    private func centerOnUser() {
        if let location = locationManager.location {
            moveCamera(to: location)
        } else {
            locationManager.requestLocation()
        }
    }

    private func moveCamera(to coordinate: CLLocationCoordinate2D, span: Double = 0.012) {
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: span, longitudeDelta: span)
                )
            )
        }
    }

    private func search() {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return }

        isSearching = true
        searchError = nil

        Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            if let region = position.region {
                request.region = region
            }

            do {
                let response = try await MKLocalSearch(request: request).start()
                let places = response.mapItems.prefix(20).map(Place.init)
                searchResults = places
                selectedPlaceID = places.first?.id
                position = .region(response.boundingRegion)
            } catch {
                searchError = error.localizedDescription
            }
            isSearching = false
        }
    }

    private func openInMaps(_ place: Place) {
        let location = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let mapItem = MKMapItem(location: location, address: nil)
        mapItem.name = place.name
        mapItem.openInMaps()
    }
}

private struct HighwayLegend: View {
    let isLoading: Bool
    let errorMessage: String?
    let retry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack(spacing: 8) {
                Capsule()
                    .fill(.orange)
                    .frame(width: 28, height: 5)
                    .overlay {
                        Capsule().stroke(.black.opacity(0.4), lineWidth: 1)
                    }

                Text(isLoading ? "道路を取得中…" : "高速・自動車専用道路")
                    .font(.caption.weight(.semibold))

                if isLoading {
                    ProgressView()
                        .controlSize(.mini)
                }
            }

            if let errorMessage {
                HStack(spacing: 6) {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundStyle(.red)

                    Button("再試行", action: retry)
                        .font(.caption2.weight(.semibold))
                        .disabled(isLoading)
                }
            } else {
                Link(
                    "© OpenStreetMap contributors",
                    destination: URL(string: "https://www.openstreetmap.org/copyright")!
                )
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 11)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.12), radius: 5, y: 2)
        .accessibilityElement(children: .combine)
    }
}

private struct Place: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(mapItem: MKMapItem) {
        name = mapItem.name ?? "名称不明"
        address = mapItem.addressRepresentations?
            .fullAddress(includingRegion: true, singleLine: true) ?? "住所情報なし"
        latitude = mapItem.location.coordinate.latitude
        longitude = mapItem.location.coordinate.longitude
    }
}

private struct PlaceCard: View {
    let place: Place
    let openInMaps: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "mappin.and.ellipse")
                .font(.title2)
                .foregroundStyle(.red)
                .frame(width: 42, height: 42)
                .background(.red.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(place.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 8)

            Button(action: openInMaps) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                    .font(.title3)
                    .frame(width: 42, height: 42)
            }
            .buttonStyle(.borderedProminent)
            .clipShape(Circle())
            .accessibilityLabel("マップで開く")
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.12), radius: 12, y: 5)
    }
}

private enum MapStyleOption: String, CaseIterable, Identifiable {
    case standard
    case imagery
    case hybrid

    var id: Self { self }

    var title: String {
        switch self {
        case .standard: "標準"
        case .imagery: "航空写真"
        case .hybrid: "ハイブリッド"
        }
    }

    var systemImage: String {
        switch self {
        case .standard: "map"
        case .imagery: "photo"
        case .hybrid: "square.3.layers.3d"
        }
    }

    var style: MapStyle {
        switch self {
        case .standard: .standard
        case .imagery: .imagery
        case .hybrid: .hybrid
        }
    }
}

private extension MKCoordinateRegion {
    static let tokyoStation = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 35.681236, longitude: 139.767125),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
}

#Preview {
    ContentView()
}
