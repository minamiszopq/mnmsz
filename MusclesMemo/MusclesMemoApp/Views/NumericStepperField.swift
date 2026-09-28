import SwiftUI

/// 重量・回数などの数値入力用フィールド。±ボタン（44pt以上のタップ領域）と、
/// 直接入力できる大きめの数字表示を組み合わせている。
///
/// 表示用テキストは value から直接導出する一方向のバインディングにしている
/// （別の @State と value を双方向同期させると更新が競合し、±ボタンの反映が
/// 不安定になることがあるため）。
struct NumericStepperField: View {
    let label: String
    @Binding var value: Double?
    var step: Double = 1
    var minValue: Double = 0
    var decimalPlaces: Int = 0
    var unit: String = ""

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 48, alignment: .leading)

            stepButton(systemImage: "minus.circle.fill") { adjust(-step) }

            TextField("-", text: textBinding)
                .keyboardType(decimalPlaces > 0 ? .decimalPad : .numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(AppTheme.textPrimary)
                .frame(minWidth: 84, minHeight: 48)

            Text(unit)
                .font(.caption)
                .foregroundStyle(AppTheme.textSecondary)
                .frame(width: 30, alignment: .leading)

            stepButton(systemImage: "plus.circle.fill") { adjust(step) }
        }
    }

    /// TextField 表示用のバインディング。value を唯一の情報源とし、
    /// 数値に変換できる入力のみ反映する（変換できない途中入力は value を変えない）。
    private var textBinding: Binding<String> {
        Binding<String>(
            get: { value.map(format) ?? "" },
            set: { newText in
                guard !newText.isEmpty else {
                    value = nil
                    return
                }
                if let parsed = Double(newText) {
                    value = parsed
                }
            }
        )
    }

    private func stepButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 26))
                .foregroundStyle(AppTheme.accent)
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }

    private func adjust(_ delta: Double) {
        let base = value ?? 0
        value = max(minValue, roundToStep(base + delta))
    }

    private func roundToStep(_ value: Double) -> Double {
        decimalPlaces == 0 ? value.rounded() : (value * 10).rounded() / 10
    }

    private func format(_ value: Double) -> String {
        decimalPlaces == 0 ? String(Int(value)) : String(format: "%.\(decimalPlaces)f", value)
    }
}
