import XCTest
@testable import MusclesMemoApp

final class StatMetricTests: XCTestCase {
    private let sets: [(weight: Double, reps: Int)] = [
        (60, 10),
        (70, 5),
        (50, 12),
    ]

    func testMaxWeightPicksHeaviestSet() {
        XCTAssertEqual(StatMetric.maxWeight.value(for: sets), 70)
    }

    func testVolumeSumsWeightTimesReps() {
        // 60*10 + 70*5 + 50*12 = 600 + 350 + 600 = 1550
        XCTAssertEqual(StatMetric.volume.value(for: sets), 1550)
    }

    func testEstimated1RMUsesEpleyFormulaAndPicksMax() {
        // 60*(1+10/30)=80, 70*(1+5/30)=81.67, 50*(1+12/30)=70 -> max is 70*(1+5/30)
        let expected = 70 * (1 + 5.0 / 30)
        XCTAssertEqual(StatMetric.estimated1RM.value(for: sets), expected, accuracy: 0.001)
    }

    func testMetricsReturnZeroForEmptySets() {
        for metric in StatMetric.allCases {
            XCTAssertEqual(metric.value(for: []), 0)
        }
    }
}
