import Foundation
import SwiftData

/// トレーニング種目（ベンチプレス、スクワットなど）。
@Model
final class Exercise {
    var name: String
    var bodyPart: BodyPart = BodyPart.other
    var sortOrder: Int
    var createdAt: Date

    init(name: String, bodyPart: BodyPart, sortOrder: Int = 0, createdAt: Date = .now) {
        self.name = name
        self.bodyPart = bodyPart
        self.sortOrder = sortOrder
        self.createdAt = createdAt
    }
}

extension Exercise {
    /// 初回起動時に登録しておく代表的な種目（部位ごと）。
    static let defaults: [(name: String, bodyPart: BodyPart)] = [
        ("ベンチプレス", .chest),
        ("ダンベルフライ", .chest),
        ("懸垂", .back),
        ("ラットプルダウン", .back),
        ("バーベルロウ", .back),
        ("デッドリフト", .back),
        ("スクワット", .legs),
        ("レッグプレス", .legs),
        ("ショルダープレス", .shoulders),
        ("サイドレイズ", .shoulders),
        ("アームカール", .biceps),
        ("トライセプスエクステンション", .triceps),
        ("クランチ", .abs),
    ]
}

extension [Exercise] {
    /// 検索文字で絞り込み、部位ごとにまとめる（該当なしの部位は除く）。
    func groupedByBodyPart(matching searchText: String) -> [(bodyPart: BodyPart, exercises: [Exercise])] {
        let filtered = searchText.isEmpty ? self : filter { $0.name.localizedStandardContains(searchText) }
        return BodyPart.allCases.compactMap { part in
            let items = filtered.filter { $0.bodyPart == part }
            return items.isEmpty ? nil : (part, items)
        }
    }
}
