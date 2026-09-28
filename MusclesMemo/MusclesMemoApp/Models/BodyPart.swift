import Foundation

/// 種目を分類する部位。
enum BodyPart: String, CaseIterable, Identifiable, Codable {
    case chest = "胸"
    case back = "背中"
    case legs = "脚"
    case shoulders = "肩"
    case biceps = "二頭"
    case triceps = "三頭"
    case abs = "腹筋"
    case other = "その他"

    var id: String { rawValue }
}
