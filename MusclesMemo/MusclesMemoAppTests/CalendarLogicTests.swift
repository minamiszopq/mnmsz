import XCTest
@testable import MusclesMemoApp

final class MonthGridTests: XCTestCase {
    func testDaysReturns42CellsCoveringFullWeeks() {
        let september2026 = TestSupport.date(2026, 9, 7)
        let days = MonthGrid.days(for: september2026)

        XCTAssertEqual(days.count, 42)

        let calendar = Calendar.current
        XCTAssertEqual(calendar.component(.weekday, from: days.first!), 1, "先頭は日曜始まり")

        // 9月1日と9月30日が範囲に含まれる
        let sept1 = TestSupport.date(2026, 9, 1)
        let sept30 = TestSupport.date(2026, 9, 30)
        XCTAssertTrue(days.contains { calendar.isDate($0, inSameDayAs: sept1) })
        XCTAssertTrue(days.contains { calendar.isDate($0, inSameDayAs: sept30) })
    }

    func testWeekdaySymbolsHasSevenEntries() {
        XCTAssertEqual(MonthGrid.weekdaySymbols().count, 7)
    }
}

final class DateDayExtensionTests: XCTestCase {
    func testStartOfDayZeroesTime() {
        let calendar = Calendar.current
        var components = DateComponents()
        components.year = 2026
        components.month = 9
        components.day = 7
        components.hour = 15
        components.minute = 30
        let date = calendar.date(from: components)!

        let start = date.startOfDay
        XCTAssertEqual(calendar.component(.hour, from: start), 0)
        XCTAssertEqual(calendar.component(.minute, from: start), 0)
    }

    func testIsSameDayIgnoresTimeOfDay() {
        let morning = TestSupport.date(2026, 9, 7)
        let evening = Calendar.current.date(byAdding: .hour, value: 20, to: morning)!
        XCTAssertTrue(morning.isSameDay(as: evening))
    }

    func testIsSameMonthComparesYearAndMonth() {
        let early = TestSupport.date(2026, 9, 1)
        let late = TestSupport.date(2026, 9, 30)
        let nextMonth = TestSupport.date(2026, 10, 1)

        XCTAssertTrue(early.isSameMonth(as: late))
        XCTAssertFalse(early.isSameMonth(as: nextMonth))
    }
}

final class BodyPartTests: XCTestCase {
    func testAllCasesHaveUniqueRawValues() {
        let rawValues = BodyPart.allCases.map(\.rawValue)
        XCTAssertEqual(Set(rawValues).count, rawValues.count)
    }
}
