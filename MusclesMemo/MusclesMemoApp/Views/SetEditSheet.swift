import SwiftUI
import SwiftData

/// 既存の1セットの重量・回数を編集、または削除する画面。
struct SetEditSheet: View {
    @Bindable var set: WorkoutSet

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var weightMode: WeightMode = .normal
    @State private var weightValue: Double?
    @State private var repsValue: Double?

    var body: some View {
        NavigationStack {
            Form {
                Section(set.exercise?.name ?? "") {
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

                    NumericStepperField(
                        label: "回数",
                        value: $repsValue,
                        step: 1,
                        minValue: 0,
                        decimalPlaces: 0,
                        unit: "回"
                    )
                    .listRowBackground(Color.clear)
                }

                Section {
                    Button("このセットを削除", role: .destructive) {
                        modelContext.delete(set)
                        dismiss()
                    }
                }
            }
            .glassScreenBackground()
            .dismissKeyboardOnTap()
            .navigationTitle("セット \(set.setNumber)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .disabled(!isValid)
                }
            }
            .onAppear {
                weightMode = set.weightMode
                weightValue = set.weight
                repsValue = set.reps.map(Double.init)
            }
        }
    }

    private var isValid: Bool {
        guard let reps = repsValue, reps > 0 else { return false }
        if weightMode.requiresWeightValue {
            return weightValue != nil
        }
        return true
    }

    private func save() {
        guard isValid else { return }
        set.weightMode = weightMode
        set.weight = weightMode.requiresWeightValue ? weightValue : nil
        set.reps = repsValue.map { Int($0) }
        dismiss()
    }
}
