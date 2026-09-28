import SwiftUI
import SwiftData

/// 特定の日のトレーニング記録一覧。種目ごとにセットをまとめて表示する。
struct DayDetailScreen: View {
    let date: Date

    @Environment(\.modelContext) private var modelContext
    @Query private var setsOnDate: [WorkoutSet]

    @State private var isPickingExercise = false
    @State private var editingSet: WorkoutSet?
    @State private var bulkEditTarget: BulkEditTarget?

    init(date: Date) {
        self.date = date
        let normalized = date.startOfDay
        _setsOnDate = Query(
            filter: #Predicate<WorkoutSet> { $0.date == normalized },
            sort: [SortDescriptor(\WorkoutSet.setNumber)]
        )
    }

    /// 種目ごとにグルーピングし、その日に最初に登録された順で並べる。
    private var exerciseGroups: [(exercise: Exercise, sets: [WorkoutSet])] {
        var order: [ObjectIdentifier] = []
        var grouped: [ObjectIdentifier: (Exercise, [WorkoutSet])] = [:]

        for set in setsOnDate {
            guard let exercise = set.exercise else { continue }
            let key = ObjectIdentifier(exercise)
            if grouped[key] == nil {
                order.append(key)
                grouped[key] = (exercise, [])
            }
            grouped[key]?.1.append(set)
        }

        return order.compactMap { grouped[$0] }
    }

    var body: some View {
        Group {
            if exerciseGroups.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(exerciseGroups, id: \.exercise.persistentModelID) { group in
                        Section {
                            ForEach(group.sets) { set in
                                SetRowView(set: set)
                                    .contentShape(Rectangle())
                                    .onTapGesture { editingSet = set }
                                    .listRowBackground(AppTheme.glassBackground())
                            }
                            .onDelete { offsets in
                                deleteSets(offsets, from: group.sets)
                            }

                            Button {
                                addQuickSet(after: group)
                            } label: {
                                Label("セットを追加", systemImage: "plus")
                            }
                            .listRowBackground(AppTheme.glassBackground())
                        } header: {
                            HStack {
                                Text(group.exercise.name)
                                Spacer()
                                Button {
                                    bulkEditTarget = BulkEditTarget(exercise: group.exercise, sets: group.sets)
                                } label: {
                                    Label("重量を一括登録", systemImage: "scalemass.fill")
                                        .labelStyle(.iconOnly)
                                }
                                .font(.footnote)
                                .foregroundStyle(AppTheme.accent)
                            }
                        }
                    }
                }
                .listSectionSpacing(12)
                .glassScreenBackground()
            }
        }
        .background(AppTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPickingExercise = true
                } label: {
                    Label("種目を追加", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isPickingExercise) {
            ExercisePickerScreen(date: date)
        }
        .sheet(item: $editingSet) { set in
            SetEditSheet(set: set)
        }
        .sheet(item: $bulkEditTarget) { target in
            BulkWeightSheet(exerciseName: target.exercise.name, sets: target.sets) { mode, weight in
                WorkoutRepository.applyWeight(mode: mode, weight: weight, to: target.sets)
            }
        }
    }

    private var title: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日(E)"
        return formatter.string(from: date)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.textSecondary)
            Text("この日の記録はまだありません")
                .foregroundStyle(AppTheme.textSecondary)
            Button {
                isPickingExercise = true
            } label: {
                Label("種目を追加", systemImage: "plus.circle.fill")
                    .foregroundStyle(.black)
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteSets(_ offsets: IndexSet, from sets: [WorkoutSet]) {
        for index in offsets {
            modelContext.delete(sets[index])
        }
    }

    private func addQuickSet(after group: (exercise: Exercise, sets: [WorkoutSet])) {
        let lastSet = group.sets.last
        let newSet = WorkoutSet(
            date: date.startOfDay,
            exercise: group.exercise,
            weightMode: lastSet?.weightMode ?? .normal,
            weight: nil,
            reps: nil,
            setNumber: (lastSet?.setNumber ?? 0) + 1
        )
        modelContext.insert(newSet)
    }
}

/// 重量一括登録シートに渡す対象（種目とその日の表示中セット一覧）。
private struct BulkEditTarget: Identifiable {
    let exercise: Exercise
    let sets: [WorkoutSet]

    var id: PersistentIdentifier { exercise.persistentModelID }
}

private struct SetRowView: View {
    let set: WorkoutSet

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(0.18))
                Text("\(set.setNumber)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.accent)
            }
            .frame(width: 30, height: 30)

            VStack(alignment: .leading, spacing: 2) {
                Text(weightText)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(AppTheme.textPrimary)
                if set.weightMode == .assisted {
                    Text("アシスト")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.accentSecondary)
                }
            }

            Spacer()

            Text(repsText)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary.opacity(0.6))
        }
        .padding(.vertical, 4)
    }

    private var weightText: String {
        switch set.weightMode {
        case .bodyweight:
            return "自重"
        case .normal, .assisted:
            guard let weight = set.weight else { return "-kg" }
            return String(format: "%.1f kg", weight)
        }
    }

    private var repsText: String {
        guard let reps = set.reps else { return "-回" }
        return "\(reps) 回"
    }
}

#Preview {
    NavigationStack {
        DayDetailScreen(date: Date())
    }
    .modelContainer(for: [Exercise.self, WorkoutSet.self], inMemory: true)
}
