import SwiftUI
import SwiftData
import Charts

/// 種目ごとの記録推移と、部位別トレーニング頻度をグラフで確認する画面。
struct StatsScreen: View {
    @Query(sort: \WorkoutSet.date) private var allSets: [WorkoutSet]

    @State private var selectedExercise: Exercise?
    @State private var selectedMetric: StatMetric = .maxWeight
    @State private var isPickingExercise = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    bodyPartFrequencySection
                    exercisePickerCard

                    if selectedExercise != nil {
                        metricPicker
                        chartCard
                        recentRecordsCard
                    } else {
                        emptySelectionHint
                    }
                }
                .padding()
            }
            .glassScreenBackground()
            .navigationTitle("グラフ")
            .sheet(isPresented: $isPickingExercise) {
                ExerciseSelectionSheet(selected: selectedExercise) { exercise in
                    selectedExercise = exercise
                }
            }
        }
    }

    // MARK: - 部位別トレーニング頻度

    private var bodyPartFrequency: [(bodyPart: BodyPart, days: Int)] {
        var daysByPart: [BodyPart: Set<Date>] = [:]
        for set in allSets {
            guard let part = set.exercise?.bodyPart else { continue }
            daysByPart[part, default: []].insert(set.date)
        }
        return BodyPart.allCases.compactMap { part in
            guard let count = daysByPart[part]?.count, count > 0 else { return nil }
            return (part, count)
        }
        .sorted { $0.days > $1.days }
    }

    private var bodyPartFrequencySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("部位別トレーニング頻度")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            if bodyPartFrequency.isEmpty {
                Text("まだ記録がありません")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                Chart(bodyPartFrequency, id: \.bodyPart) { item in
                    BarMark(
                        x: .value("日数", item.days),
                        y: .value("部位", item.bodyPart.rawValue)
                    )
                    .foregroundStyle(AppTheme.accentSecondary.gradient)
                    .cornerRadius(4)
                }
                .frame(height: CGFloat(bodyPartFrequency.count) * 32 + 24)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(AppTheme.textSecondary.opacity(0.2))
                        AxisValueLabel().foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel().foregroundStyle(AppTheme.textPrimary)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.glassBackground())
    }

    // MARK: - 種目選択

    private var exercisePickerCard: some View {
        Button {
            isPickingExercise = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("種目")
                        .font(.caption)
                        .foregroundStyle(AppTheme.textSecondary)
                    Text(selectedExercise?.name ?? "種目を選択")
                        .font(.headline)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(AppTheme.textSecondary)
            }
            .padding()
            .background(AppTheme.glassBackground())
        }
    }

    private var emptySelectionHint: some View {
        Text("種目を選ぶと重量やボリュームの推移を確認できます")
            .font(.subheadline)
            .foregroundStyle(AppTheme.textSecondary)
            .padding()
    }

    // MARK: - 指標切り替え

    private var metricPicker: some View {
        Picker("指標", selection: $selectedMetric) {
            ForEach(StatMetric.allCases) { metric in
                Text(metric.rawValue).tag(metric)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - グラフ本体

    private var exerciseSets: [WorkoutSet] {
        guard let exercise = selectedExercise else { return [] }
        let id = exercise.persistentModelID
        return allSets.filter { $0.exercise?.persistentModelID == id }
    }

    private var dailyPoints: [(date: Date, value: Double)] {
        let grouped = Dictionary(grouping: exerciseSets, by: { $0.date })
        return grouped.compactMap { date, sets -> (date: Date, value: Double)? in
            // 自重・アシストのセットは通常の重量と単純比較できないため、重量グラフには含めない。
            let validSets = sets.compactMap { set -> (weight: Double, reps: Int)? in
                guard set.weightMode == .normal, let weight = set.weight, let reps = set.reps else { return nil }
                return (weight, reps)
            }
            guard !validSets.isEmpty else { return nil }
            return (date, selectedMetric.value(for: validSets))
        }
        .sorted { $0.date < $1.date }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            if dailyPoints.isEmpty {
                Text("この種目にはまだ重量・回数の記録がありません")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                Chart(dailyPoints, id: \.date) { point in
                    LineMark(
                        x: .value("日付", point.date, unit: .day),
                        y: .value(selectedMetric.rawValue, point.value)
                    )
                    .foregroundStyle(AppTheme.accent)
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("日付", point.date, unit: .day),
                        y: .value(selectedMetric.rawValue, point.value)
                    )
                    .foregroundStyle(AppTheme.accent)
                }
                .frame(height: 220)
                .chartXAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(AppTheme.textSecondary.opacity(0.2))
                        AxisValueLabel(format: .dateTime.month().day())
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks { _ in
                        AxisGridLine().foregroundStyle(AppTheme.textSecondary.opacity(0.2))
                        AxisValueLabel().foregroundStyle(AppTheme.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(AppTheme.glassBackground())
    }

    private var recentRecordsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("直近の記録")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            ForEach(dailyPoints.suffix(5).reversed(), id: \.date) { point in
                HStack {
                    Text(point.date, format: .dateTime.month().day().locale(Locale(identifier: "ja_JP")))
                        .foregroundStyle(AppTheme.textSecondary)
                    Spacer()
                    Text(selectedMetric.formattedValue(point.value))
                        .foregroundStyle(AppTheme.textPrimary)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .background(AppTheme.glassBackground())
    }
}

/// グラフに表示する指標の種類。
enum StatMetric: String, CaseIterable, Identifiable {
    case maxWeight = "最大重量"
    case volume = "総ボリューム"
    case estimated1RM = "推定1RM"

    var id: String { rawValue }

    func value(for sets: [(weight: Double, reps: Int)]) -> Double {
        switch self {
        case .maxWeight:
            return sets.map(\.weight).max() ?? 0
        case .volume:
            return sets.reduce(0) { $0 + $1.weight * Double($1.reps) }
        case .estimated1RM:
            // Epley 式: 1RM ≈ weight × (1 + reps / 30)
            return sets.map { $0.weight * (1 + Double($0.reps) / 30) }.max() ?? 0
        }
    }

    func formattedValue(_ value: Double) -> String {
        switch self {
        case .maxWeight, .estimated1RM:
            return String(format: "%.1f kg", value)
        case .volume:
            return String(format: "%.0f kg", value)
        }
    }
}

#Preview {
    StatsScreen()
        .modelContainer(for: [Exercise.self, WorkoutSet.self], inMemory: true)
        .preferredColorScheme(.dark)
}
