import Foundation
import SwiftData
@testable import MusclesMemoApp

enum TestSupport {
    /// テスト用のインメモリ ModelContext を作成する。
    static func makeContext() -> ModelContext {
        let container = try! ModelContainer(
            for: Exercise.self, WorkoutSet.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return ModelContext(container)
    }

    static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
}
