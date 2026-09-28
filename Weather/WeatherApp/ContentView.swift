import SwiftUI

struct ContentView: View {
    // 表示中の天気データ。
    @State private var weather: WeatherResponse?
    @State private var forecast: ForecastResponse?

    // 検索候補と選択中の都市。
    @State private var searchText = "東京"
    @State private var suggestions: [LocationSuggestion] = []
    @State private var selectedLocation = LocationSuggestion(
        name: "Tokyo",
        localNames: ["ja": "東京"],
        latitude: 35.6762,
        longitude: 139.6503,
        country: "JP",
        state: "東京都"
    )
    @State private var searchTask: Task<Void, Never>?
    @State private var hasSearchedLocations = false

    // 通信状態と画面上のエラー。
    @State private var isLoadingWeather = false
    @State private var isSearchingLocations = false
    @State private var errorMessage: String?
    @State private var searchErrorMessage: String?
    @FocusState private var isSearchFocused: Bool

    private let service = WeatherService()

    var body: some View {
        ZStack {
            background

            ScrollView {
                VStack(spacing: 24) {
                    searchSection
                    weatherContent
                }
                .padding()
            }
            .refreshable {
                await loadWeather(at: selectedLocation)
            }
        }
        .task {
            await loadWeather(at: selectedLocation)
        }
        .onDisappear {
            searchTask?.cancel()
        }
    }

    // 天気画面全体の背景。
    private var background: some View {
        LinearGradient(
            colors: [Color.indigo.opacity(0.9), Color.cyan.opacity(0.72)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // 検索欄と候補一覧を一つのまとまりとして表示する。
    private var searchSection: some View {
        VStack(spacing: 8) {
            searchBar

            if isSearchFocused || isSearchingLocations || !suggestions.isEmpty {
                suggestionList
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("都市名（例: 東京 / London）", text: $searchText)
                .focused($isSearchFocused)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.search)
                .onSubmit {
                    requestSuggestionsImmediately()
                }
                .onChange(of: searchText) { _, newValue in
                    scheduleSuggestionSearch(for: newValue)
                }

            if isSearchingLocations {
                ProgressView()
                    .controlSize(.small)
            } else if !searchText.isEmpty {
                Button {
                    searchText = ""
                    suggestions = []
                    hasSearchedLocations = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("検索文字を消去")
            }

            Button(action: requestSuggestionsImmediately) {
                Image(systemName: "arrow.right.circle.fill")
                    .font(.title2)
            }
            .disabled(trimmedSearchText.isEmpty || isSearchingLocations)
            .accessibilityLabel("候補を検索")
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // APIから取得した候補を選択可能な行で表示する。
    @ViewBuilder
    private var suggestionList: some View {
        if !suggestions.isEmpty {
            VStack(spacing: 0) {
                ForEach(suggestions) { suggestion in
                    Button {
                        selectSuggestion(suggestion)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(.blue)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(suggestion.displayName)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)

                                if !suggestion.detailText.isEmpty {
                                    Text(suggestion.detailText)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    if suggestion.id != suggestions.last?.id {
                        Divider().padding(.leading, 48)
                    }
                }
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
        } else if let searchErrorMessage {
            searchStatusLabel(searchErrorMessage, symbol: "exclamationmark.triangle")
        } else if hasSearchedLocations && !isSearchingLocations {
            searchStatusLabel("候補が見つかりませんでした", symbol: "magnifyingglass")
        }
    }

    private func searchStatusLabel(_ text: String, symbol: String) -> some View {
        Label(text, systemImage: symbol)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // 読み込み、エラー、取得済みの各状態を切り替える。
    @ViewBuilder
    private var weatherContent: some View {
        if isLoadingWeather && weather == nil {
            ProgressView("天気を取得中...")
                .tint(.white)
                .foregroundStyle(.white)
                .padding(.top, 100)
        } else if let errorMessage, weather == nil {
            errorView(message: errorMessage)
        } else if let weather {
            currentWeatherView(weather)
            detailGrid(weather)

            if let forecast {
                forecastView(forecast)
            }

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.white)
                    .padding(12)
                    .frame(maxWidth: .infinity)
                    .background(.red.opacity(0.7), in: RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    // 現在の天気を大きく表示する。
    private func currentWeatherView(_ weather: WeatherResponse) -> some View {
        VStack(spacing: 8) {
            Text(selectedLocation.displayName)
                .font(.largeTitle.bold())

            Image(systemName: weatherSymbol(weather.weather.first?.main ?? ""))
                .symbolRenderingMode(.multicolor)
                .font(.system(size: 78))
                .padding(.vertical, 4)

            Text(temperature(weather.main.temp))
                .font(.system(size: 72, weight: .thin, design: .rounded))

            Text(weather.weather.first?.description ?? "")
                .font(.title3)

            Text("最高 \(temperature(weather.main.tempMax))  最低 \(temperature(weather.main.tempMin))")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
    }

    // 体感温度などの補足情報。
    private func detailGrid(_ weather: WeatherResponse) -> some View {
        HStack(spacing: 12) {
            detailCard(title: "体感温度", value: temperature(weather.main.feelsLike), symbol: "thermometer.medium")
            detailCard(title: "湿度", value: "\(weather.main.humidity)%", symbol: "humidity.fill")
            detailCard(title: "風速", value: String(format: "%.1f m/s", weather.wind.speed), symbol: "wind")
        }
    }

    private func detailCard(title: String, value: String, symbol: String) -> some View {
        VStack(spacing: 8) {
            Label(title, systemImage: symbol)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(value)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
    }

    // 直近8件の3時間予報。
    private func forecastView(_ forecast: ForecastResponse) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("3時間ごとの予報")
                .font(.headline)
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(forecast.list.prefix(8)) { item in
                        VStack(spacing: 10) {
                            Text(formatTime(item.dt, timezoneOffset: forecast.city.timezone))
                                .font(.subheadline.weight(.semibold))

                            Image(systemName: weatherSymbol(item.weather.first?.main ?? ""))
                                .symbolRenderingMode(.multicolor)
                                .font(.title)

                            Text(temperature(item.main.temp))
                                .font(.headline)

                            Label(
                                "\(Int((item.probabilityOfPrecipitation * 100).rounded()))%",
                                systemImage: "drop.fill"
                            )
                            .font(.caption)
                            .foregroundStyle(.blue)
                        }
                        .frame(width: 82)
                        .padding(.vertical, 14)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 18))
                    }
                }
            }
        }
    }

    private func errorView(message: String) -> some View {
        ContentUnavailableView {
            Label("取得できませんでした", systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button("もう一度試す") {
                Task { await loadWeather(at: selectedLocation) }
            }
            .buttonStyle(.borderedProminent)
        }
        .foregroundStyle(.white)
    }

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 入力停止から350ミリ秒後に候補を更新する。
    private func scheduleSuggestionSearch(for text: String) {
        searchTask?.cancel()
        searchErrorMessage = nil

        let query = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty, query != selectedLocation.displayName else {
            suggestions = []
            hasSearchedLocations = false
            isSearchingLocations = false
            return
        }

        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            await searchLocations(for: query)
        }
    }

    // 検索ボタンやReturnでは待ち時間なしで検索する。
    private func requestSuggestionsImmediately() {
        guard !trimmedSearchText.isEmpty else { return }
        searchTask?.cancel()
        searchTask = Task {
            await searchLocations(for: trimmedSearchText)
        }
    }

    @MainActor
    private func searchLocations(for query: String) async {
        isSearchingLocations = true
        searchErrorMessage = nil

        do {
            let results = try await service.fetchLocations(matching: query)
            guard !Task.isCancelled, query == trimmedSearchText else { return }
            suggestions = results
            hasSearchedLocations = true
        } catch is CancellationError {
            return
        } catch {
            guard query == trimmedSearchText else { return }
            suggestions = []
            hasSearchedLocations = true
            searchErrorMessage = errorMessage(for: error)
        }

        isSearchingLocations = false
    }

    // 候補選択後にキーボードを閉じ、座標から天気を取得する。
    private func selectSuggestion(_ suggestion: LocationSuggestion) {
        searchTask?.cancel()
        selectedLocation = suggestion
        searchText = suggestion.displayName
        suggestions = []
        hasSearchedLocations = false
        searchErrorMessage = nil
        isSearchingLocations = false
        isSearchFocused = false

        Task { await loadWeather(at: suggestion) }
    }

    @MainActor
    private func loadWeather(at location: LocationSuggestion) async {
        isLoadingWeather = true
        errorMessage = nil

        do {
            // 現在天気と予報は独立しているため並列取得する。
            async let currentWeather = service.fetchWeather(at: location)
            async let cityForecast = service.fetchForecast(at: location)
            let (newWeather, newForecast) = try await (currentWeather, cityForecast)
            // 取得中に別の都市が選ばれた場合、古い結果は捨てる。
            guard location == selectedLocation else { return }
            weather = newWeather
            forecast = newForecast
        } catch {
            guard location == selectedLocation else { return }
            errorMessage = errorMessage(for: error)
        }

        isLoadingWeather = false
    }

    private func errorMessage(for error: Error) -> String {
        error.localizedDescription
    }
}

// 表示用の値へ整形する小さなヘルパー。
private func temperature(_ value: Double) -> String {
    "\(Int(value.rounded()))°"
}

private func formatTime(_ timestamp: Double, timezoneOffset: Int) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
    formatter.dateFormat = "M/d H:mm"
    return formatter.string(from: Date(timeIntervalSince1970: timestamp))
}

private func weatherSymbol(_ condition: String) -> String {
    switch condition {
    case "Clear": "sun.max.fill"
    case "Clouds": "cloud.fill"
    case "Rain": "cloud.rain.fill"
    case "Drizzle": "cloud.drizzle.fill"
    case "Thunderstorm": "cloud.bolt.rain.fill"
    case "Snow": "cloud.snow.fill"
    case "Mist", "Fog", "Haze", "Smoke": "cloud.fog.fill"
    default: "cloud.sun.fill"
    }
}

#Preview {
    ContentView()
}
