import Foundation
import SwiftData

/// 1セット分の記録（重量・回数）。特定の日付・種目に紐づく。
/// weight・reps は未入力の場合 nil（一覧では "-kg" "-回" と表示する）。
/// weight は weightMode によって意味が変わる：
///   - normal: 挙げた重量そのもの
///   - bodyweight: 使わない（常に nil）
///   - assisted: 補助（軽減）された重量
@Model
final class WorkoutSet {
    /// その日の 0時0分に正規化した日付。カレンダー上の日付との突合に使う。
    var date: Date
    var exercise: Exercise?
    var weightMode: WeightMode = WeightMode.normal
    var weight: Double?
    var reps: Int?
    var setNumber: Int
    var createdAt: Date

    init(
        date: Date,
        exercise: Exercise?,
        weightMode: WeightMode = .normal,
        weight: Double?,
        reps: Int?,
        setNumber: Int,
        createdAt: Date = .now
    ) {
        self.date = date
        self.exercise = exercise
        self.weightMode = weightMode
        self.weight = weightMode == .bodyweight ? nil : weight
        self.reps = reps
        self.setNumber = setNumber
        self.createdAt = createdAt
    }
}
