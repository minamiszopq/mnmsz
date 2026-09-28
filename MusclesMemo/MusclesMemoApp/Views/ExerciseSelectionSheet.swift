import SwiftUI
import SwiftData

/// 部位別にグルーピングした種目一覧から、グラフ表示対象の種目を選ぶだけのシート。
struct ExerciseSelectionSheet: View {
    let selected: Exercise?
    let onSelect: (Exercise) -> Void

    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Exercise.sortOrder) private var exercises: [Exercise]
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(exercises.groupedByBodyPart(matching: searchText), id: \.bodyPart) { group in
                    Section(group.bodyPart.rawValue) {
                        ForEach(group.exercises) { exercise in
                            Button {
                                onSelect(exercise)
                                dismiss()
                            } label: {
                                HStack {
                                    Text(exercise.name)
                                        .foregroundStyle(AppTheme.textPrimary)
                                    Spacer()
                                    if exercise.persistentModelID == selected?.persistentModelID {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(AppTheme.accent)
                                    }
                                }
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
            }
        }
    }
}
