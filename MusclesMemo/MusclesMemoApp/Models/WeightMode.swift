import Foundation

/// セットの重量の種類。通常の重量以外に、自重トレーニングやアシストマシンにも対応する。
enum WeightMode: String, CaseIterable, Identifiable, Codable {
    /// 通常のウェイト（バーベル・ダンベルなど）。数値を kg で記録する。
    case normal = "重量"
    /// 自重トレーニング。数値は記録しない。
    case bodyweight = "自重"
    /// アシストマシンなど、補助分の重量を軽減して行うトレーニング。軽減量を kg で記録する。
    case assisted = "アシスト"

    var id: String { rawValue }

    /// この種類が重量の数値入力を必要とするか。
    var requiresWeightValue: Bool {
        self != .bodyweight
    }
}
