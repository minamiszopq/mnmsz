import SwiftUI

/// ある種目の「表示されているセット全て」に対して、同じ重量（と重量モード）を
/// まとめて登録するシート。回数は変更しない。
struct BulkWeightSheet: View {
    let exerciseName: String
    let sets: [WorkoutSet]
    let onApply: (WeightMode, Double?) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var weightMode: WeightMode = .normal
    @State private var weightValue: Double?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("\(exerciseName) の \(sets.count) セットすべてに適用します")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .listRowBackground(Color.clear)

                Section("重量") {
                    Picker("種類", selection: $weightMode) {
                        ForEach(WeightMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                    .listRowBackground(Color.clear)

                    if weightMode.requiresWeightValue {
                        NumericStepperField(
                            label: weightMode == .assisted ? "軽減" : "重量",
                            value: $weightValue,
                            step: 2.5,
                            decimalPlaces: 1,
                            unit: "kg"
                        )
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .glassScreenBackground()
            .dismissKeyboardOnTap()
            .navigationTitle("重量を一括登録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("適用") {
                        onApply(weightMode, weightValue)
                        dismiss()
                    }
                    .disabled(weightMode.requiresWeightValue && weightValue == nil)
                }
            }
        }
    }
}
