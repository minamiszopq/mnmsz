import SwiftUI
import SwiftData

/// トレーニングに追加する種目を部位別に選択する画面。
/// 種目を選ぶ（または新規追加する）と、その日の1セット目を作成してセット一覧画面に戻る。
struct ExercisePickerScreen: View {
    let date: Date

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.sortOrder) private var exercises: [Exercise]

    @State private var searchText = ""
    @State private var isAddingNewExercise = false
    @State private var isCopyingFromDay = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        isCopyingFromDay = true
                    } label: {
                        Label("別の日からコピー", systemImage: "calendar.badge.clock")
                    }
                    .listRowBackground(AppTheme.glassBackground())
                }

                ForEach(exercises.groupedByBodyPart(matching: searchText), id: \.bodyPart) { group in
                    Section(group.bodyPart.rawValue) {
                        ForEach(group.exercises) { exercise in
                            Button {
                                selectExercise(exercise)
                            } label: {
                                Text(exercise.name)
                                    .foregroundStyle(AppTheme.textPrimary)
                            }
                            .listRowBackground(AppTheme.glassBackground())
                        }
                    }
                }
            }
            .glassScreenBackground()
            .searchable(text: $searchText, prompt: "種目を検索")
            .navigationTitle("種目を選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isAddingNewExercise = true
                    } label: {
                        Label("新規種目", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingNewExercise) {
                AddExerciseSheet { name, bodyPart in
                    let exercise = Exercise(name: name, bodyPart: bodyPart, sortOrder: exercises.count)
                    modelContext.insert(exercise)
                    selectExercise(exercise)
                }
            }
            .navigationDestination(isPresented: $isCopyingFromDay) {
                CopyFromDayScreen(targetDate: date)
            }
        }
    }

    /// 種目を確定し、その日の1セット目（空欄）を作成してこの画面を閉じる。
    private func selectExercise(_ exercise: Exercise) {
        let set = WorkoutSet(
            date: date.startOfDay,
            exercise: exercise,
            weight: nil,
            reps: nil,
            setNumber: WorkoutRepository.nextSetNumber(for: exercise, on: date, context: modelContext)
        )
        modelContext.insert(set)
        dismiss()
    }
}

/// 新しい種目名と部位を入力するシート。
private struct AddExerciseSheet: View {
    let onAdd: (String, BodyPart) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var bodyPart: BodyPart = .other

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("種目名") {
                    TextField("種目名", text: $name)
                }
                Section("部位") {
                    Picker("部位", selection: $bodyPart) {
                        ForEach(BodyPart.allCases) { part in
                            Text(part.rawValue).tag(part)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
            }
            .glassScreenBackground()
            .dismissKeyboardOnTap()
            .navigationTitle("新しい種目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        // onAdd が種目選択画面全体を閉じるため、ここでは dismiss() を呼ばない。
                        // 両方で呼ぶと二重にシートを閉じようとして実機でクラッシュすることがある。
                        onAdd(trimmedName, bodyPart)
                    }
                    .disabled(trimmedName.isEmpty)
                }
            }
        }
    }
}
