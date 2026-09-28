import XCTest
import SwiftData
@testable import MusclesMemoApp

final class WorkoutSetTests: XCTestCase {
    func testBodyweightModeForcesWeightToNil() {
        let set = WorkoutSet(date: TestSupport.date(2026, 9, 7), exercise: nil, weightMode: .bodyweight, weight: 80, reps: 10, setNumber: 1)
        XCTAssertNil(set.weight, "自重は重量値を持たない")
    }

    func testNormalModeKeepsWeight() {
        let set = WorkoutSet(date: TestSupport.date(2026, 9, 7), exercise: nil, weightMode: .normal, weight: 60, reps: 10, setNumber: 1)
        XCTAssertEqual(set.weight, 60)
    }

    func testAssistedModeKeepsWeightAsReduction() {
        let set = WorkoutSet(date: TestSupport.date(2026, 9, 7), exercise: nil, weightMode: .assisted, weight: 30, reps: 10, setNumber: 1)
        XCTAssertEqual(set.weight, 30)
    }

    func testDefaultWeightModeIsNormal() {
        let set = WorkoutSet(date: TestSupport.date(2026, 9, 7), exercise: nil, weight: 60, reps: 10, setNumber: 1)
        XCTAssertEqual(set.weightMode, .normal)
    }
}

final class WeightModeTests: XCTestCase {
    func testOnlyBodyweightSkipsWeightValue() {
        XCTAssertFalse(WeightMode.bodyweight.requiresWeightValue)
        XCTAssertTrue(WeightMode.normal.requiresWeightValue)
        XCTAssertTrue(WeightMode.assisted.requiresWeightValue)
    }
}

final class CopyPreservesWeightModeTests: XCTestCase {
    func testCopyWorkoutCarriesOverWeightMode() throws {
        let context = TestSupport.makeContext()
        let pullUp = Exercise(name: "懸垂", bodyPart: .back)
        context.insert(pullUp)

        let source = TestSupport.date(2026, 9, 1)
        let target = TestSupport.date(2026, 9, 7)
        context.insert(WorkoutSet(date: source, exercise: pullUp, weightMode: .assisted, weight: 30, reps: 8, setNumber: 1))

        WorkoutRepository.copyWorkout(from: source, to: target, context: context)

        let copied = try context.fetch(FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> { $0.date == target }
        ))
        XCTAssertEqual(copied.first?.weightMode, .assisted)
        XCTAssertEqual(copied.first?.weight, 30)
    }
}
