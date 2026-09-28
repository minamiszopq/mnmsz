import Foundation
import SwiftData

/// WorkoutSet に対するクエリ・更新ロジックをまとめたもの。
/// View から独立させることで、ユニットテストから直接検証できるようにする。
enum WorkoutRepository {
    /// 指定の日付・種目について、次に振るべきセット番号（既存セット数+1）を返す。
    ///
    /// 実機（オンディスクストア）では #Predicate 内でリレーション先の persistentModelID を
    /// 比較する複合条件がクラッシュを起こすことがあるため、日付のみで絞り込んでから
    /// メモリ上で種目を照合する（この形は copyWorkout でも使っている安全なパターン）。
    static func nextSetNumber(for exercise: Exercise, on date: Date, context: ModelContext) -> Int {
        let day = date.startOfDay
        let exerciseID = exercise.persistentModelID
        let descriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> { $0.date == day }
        )
        let setsOnDay = (try? context.fetch(descriptor)) ?? []
        let existingCount = setsOnDay.filter { $0.exercise?.persistentModelID == exerciseID }.count
        return existingCount + 1
    }

    /// sourceDate の全セットを targetDate に複製する。
    /// 種目ごとのセット番号は targetDate に既にあるセットの続きから振り直す。
    /// 戻り値は複製したセット数。
    @discardableResult
    static func copyWorkout(from sourceDate: Date, to targetDate: Date, context: ModelContext) -> Int {
        let source = sourceDate.startOfDay
        let target = targetDate.startOfDay

        let sourceDescriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> { $0.date == source },
            sortBy: [SortDescriptor(\.setNumber)]
        )
        guard let sourceSets = try? context.fetch(sourceDescriptor), !sourceSets.isEmpty else { return 0 }

        let targetDescriptor = FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> { $0.date == target }
        )
        let existingTargetSets = (try? context.fetch(targetDescriptor)) ?? []

        var nextSetNumber: [PersistentIdentifier: Int] = [:]
        for set in existingTargetSets {
            guard let id = set.exercise?.persistentModelID else { continue }
            nextSetNumber[id] = max(nextSetNumber[id] ?? 0, set.setNumber)
        }

        var copiedCount = 0
        for sourceSet in sourceSets {
            guard let exercise = sourceSet.exercise else { continue }
            let id = exercise.persistentModelID
            let newNumber = (nextSetNumber[id] ?? 0) + 1
            nextSetNumber[id] = newNumber

            let copy = WorkoutSet(
                date: target,
                exercise: exercise,
                weightMode: sourceSet.weightMode,
                weight: sourceSet.weight,
                reps: sourceSet.reps,
                setNumber: newNumber
            )
            context.insert(copy)
            copiedCount += 1
        }
        return copiedCount
    }

    /// 渡されたセットすべてに、同じ重量モード・重量をまとめて適用する。
    /// 自重モードの場合は重量値を持たないため nil にそろえる。
    static func applyWeight(mode: WeightMode, weight: Double?, to sets: [WorkoutSet]) {
        let normalizedWeight = mode.requiresWeightValue ? weight : nil
        for set in sets {
            set.weightMode = mode
            set.weight = normalizedWeight
        }
    }

    /// 初回起動時のみ、代表的な種目をあらかじめ登録する。挿入した件数を返す。
    @discardableResult
    static func seedDefaultExercisesIfNeeded(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<Exercise>()
        guard let count = try? context.fetchCount(descriptor), count == 0 else { return 0 }

        for (index, item) in Exercise.defaults.enumerated() {
            context.insert(Exercise(name: item.name, bodyPart: item.bodyPart, sortOrder: index))
        }
        return Exercise.defaults.count
    }
}
