import XCTest
import SwiftData
@testable import MusclesMemoApp

final class WorkoutRepositoryTests: XCTestCase {

    // MARK: - seedDefaultExercisesIfNeeded

    func testSeedDefaultExercisesInsertsOnlyOnce() throws {
        let context = TestSupport.makeContext()

        let firstRunCount = WorkoutRepository.seedDefaultExercisesIfNeeded(context: context)
        XCTAssertEqual(firstRunCount, Exercise.defaults.count)
        XCTAssertGreaterThan(firstRunCount, 0)

        let allExercises = try context.fetch(FetchDescriptor<Exercise>())
        XCTAssertEqual(allExercises.count, Exercise.defaults.count)

        // 2回目は既にデータがあるので何も追加しない
        let secondRunCount = WorkoutRepository.seedDefaultExercisesIfNeeded(context: context)
        XCTAssertEqual(secondRunCount, 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<Exercise>()), Exercise.defaults.count)
    }

    func testDefaultExercisesCoverMultipleBodyParts() {
        let bodyParts = Set(Exercise.defaults.map(\.bodyPart))
        XCTAssertGreaterThan(bodyParts.count, 1, "デフォルト種目は複数の部位に分散しているべき")
        for item in Exercise.defaults {
            XCTAssertFalse(item.name.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }

    // MARK: - nextSetNumber

    func testNextSetNumberStartsAtOne() {
        let context = TestSupport.makeContext()
        let exercise = Exercise(name: "ベンチプレス", bodyPart: .chest)
        context.insert(exercise)

        let number = WorkoutRepository.nextSetNumber(for: exercise, on: TestSupport.date(2026, 9, 7), context: context)
        XCTAssertEqual(number, 1)
    }

    func testNextSetNumberIncrementsPerExistingSet() {
        let context = TestSupport.makeContext()
        let exercise = Exercise(name: "ベンチプレス", bodyPart: .chest)
        context.insert(exercise)
        let day = TestSupport.date(2026, 9, 7)

        context.insert(WorkoutSet(date: day, exercise: exercise, weight: 60, reps: 10, setNumber: 1))
        context.insert(WorkoutSet(date: day, exercise: exercise, weight: 60, reps: 8, setNumber: 2))

        let number = WorkoutRepository.nextSetNumber(for: exercise, on: day, context: context)
        XCTAssertEqual(number, 3)
    }

    func testNextSetNumberIsIsolatedPerExerciseAndDate() {
        let context = TestSupport.makeContext()
        let benchPress = Exercise(name: "ベンチプレス", bodyPart: .chest)
        let squat = Exercise(name: "スクワット", bodyPart: .legs)
        context.insert(benchPress)
        context.insert(squat)

        let today = TestSupport.date(2026, 9, 7)
        let yesterday = TestSupport.date(2026, 9, 6)

        context.insert(WorkoutSet(date: today, exercise: benchPress, weight: 60, reps: 10, setNumber: 1))
        context.insert(WorkoutSet(date: yesterday, exercise: benchPress, weight: 55, reps: 10, setNumber: 1))

        // 別の種目・別の日は影響を受けない
        XCTAssertEqual(WorkoutRepository.nextSetNumber(for: squat, on: today, context: context), 1)
        XCTAssertEqual(WorkoutRepository.nextSetNumber(for: benchPress, on: today, context: context), 2)
        XCTAssertEqual(WorkoutRepository.nextSetNumber(for: benchPress, on: yesterday, context: context), 2)
    }

    // MARK: - copyWorkout

    func testCopyWorkoutDuplicatesAllExercisesAndSets() throws {
        let context = TestSupport.makeContext()
        let benchPress = Exercise(name: "ベンチプレス", bodyPart: .chest)
        let squat = Exercise(name: "スクワット", bodyPart: .legs)
        context.insert(benchPress)
        context.insert(squat)

        let source = TestSupport.date(2026, 9, 1)
        let target = TestSupport.date(2026, 9, 7)

        context.insert(WorkoutSet(date: source, exercise: benchPress, weight: 60, reps: 10, setNumber: 1))
        context.insert(WorkoutSet(date: source, exercise: benchPress, weight: 65, reps: 8, setNumber: 2))
        context.insert(WorkoutSet(date: source, exercise: squat, weight: 80, reps: 5, setNumber: 1))

        let copiedCount = WorkoutRepository.copyWorkout(from: source, to: target, context: context)
        XCTAssertEqual(copiedCount, 3)

        let targetSets = try context.fetch(FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> { $0.date == target }
        ))
        XCTAssertEqual(targetSets.count, 3)

        let benchSets = targetSets
            .filter { $0.exercise?.persistentModelID == benchPress.persistentModelID }
            .sorted { $0.setNumber < $1.setNumber }
        XCTAssertEqual(benchSets.map(\.setNumber), [1, 2])
        XCTAssertEqual(benchSets.map(\.weight), [60, 65])
        XCTAssertEqual(benchSets.map(\.reps), [10, 8])

        let squatSets = targetSets.filter { $0.exercise?.persistentModelID == squat.persistentModelID }
        XCTAssertEqual(squatSets.count, 1)

        // コピー元は変更されない
        let sourceSets = try context.fetch(FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> { $0.date == source }
        ))
        XCTAssertEqual(sourceSets.count, 3)
    }

    func testCopyWorkoutAppendsAfterExistingSetsOnTargetDate() throws {
        let context = TestSupport.makeContext()
        let benchPress = Exercise(name: "ベンチプレス", bodyPart: .chest)
        context.insert(benchPress)

        let source = TestSupport.date(2026, 9, 1)
        let target = TestSupport.date(2026, 9, 7)

        context.insert(WorkoutSet(date: source, exercise: benchPress, weight: 60, reps: 10, setNumber: 1))
        // 対象日にはすでに1セット記録済み
        context.insert(WorkoutSet(date: target, exercise: benchPress, weight: 40, reps: 12, setNumber: 1))

        WorkoutRepository.copyWorkout(from: source, to: target, context: context)

        let targetSets = try context.fetch(FetchDescriptor<WorkoutSet>(
            predicate: #Predicate<WorkoutSet> { $0.date == target }
        )).sorted { $0.setNumber < $1.setNumber }

        XCTAssertEqual(targetSets.count, 2)
        XCTAssertEqual(targetSets.map(\.setNumber), [1, 2])
        // 既存の1セット目は上書きされない
        XCTAssertEqual(targetSets[0].weight, 40)
        // コピーされた分は続き番号で追加される
        XCTAssertEqual(targetSets[1].weight, 60)
    }

    func testCopyWorkoutFromEmptyDayDoesNothing() throws {
        let context = TestSupport.makeContext()
        let source = TestSupport.date(2026, 9, 1)
        let target = TestSupport.date(2026, 9, 7)

        let copiedCount = WorkoutRepository.copyWorkout(from: source, to: target, context: context)
        XCTAssertEqual(copiedCount, 0)
        XCTAssertEqual(try context.fetchCount(FetchDescriptor<WorkoutSet>()), 0)
    }

    // MARK: - applyWeight

    func testApplyWeightSetsSameWeightOnAllGivenSets() {
        let context = TestSupport.makeContext()
        let exercise = Exercise(name: "ベンチプレス", bodyPart: .chest)
        context.insert(exercise)
        let day = TestSupport.date(2026, 9, 7)

        let sets = [
            WorkoutSet(date: day, exercise: exercise, weight: nil, reps: 10, setNumber: 1),
            WorkoutSet(date: day, exercise: exercise, weight: 40, reps: 8, setNumber: 2),
            WorkoutSet(date: day, exercise: exercise, weight: 20, reps: 12, setNumber: 3),
        ]
        sets.forEach { context.insert($0) }

        WorkoutRepository.applyWeight(mode: .normal, weight: 60, to: sets)

        XCTAssertEqual(sets.map(\.weight), [60, 60, 60])
        XCTAssertEqual(sets.map(\.weightMode), [.normal, .normal, .normal])
        // 回数は変更されない
        XCTAssertEqual(sets.map(\.reps), [10, 8, 12])
    }

    func testApplyWeightBodyweightClearsWeightValue() {
        let context = TestSupport.makeContext()
        let exercise = Exercise(name: "懸垂", bodyPart: .back)
        context.insert(exercise)
        let day = TestSupport.date(2026, 9, 7)

        let sets = [
            WorkoutSet(date: day, exercise: exercise, weight: 60, reps: 10, setNumber: 1),
            WorkoutSet(date: day, exercise: exercise, weight: 60, reps: 8, setNumber: 2),
        ]
        sets.forEach { context.insert($0) }

        WorkoutRepository.applyWeight(mode: .bodyweight, weight: 999, to: sets)

        XCTAssertEqual(sets.map(\.weightMode), [.bodyweight, .bodyweight])
        XCTAssertTrue(sets.allSatisfy { $0.weight == nil })
    }

    func testApplyWeightWithEmptySetsDoesNothing() {
        WorkoutRepository.applyWeight(mode: .normal, weight: 60, to: [])
        // クラッシュしないことのみ確認
    }
}
