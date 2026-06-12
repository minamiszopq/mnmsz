// MemoEditView.swift
// 選択したメモのタイトル、本文、ピン留め状態を編集する画面。

import SwiftUI
import SwiftData

struct MemoEditView: View {

    // 編集対象
    @Bindable var memo: Memo

    var body: some View {

        VStack {

            // タイトル入力
            TextField("タイトル", text: $memo.title)
                .font(.title2)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            // 本文入力
            TextEditor(text: $memo.bodyText)
                .padding()
        }
        .navigationTitle("編集")
        .navigationBarTitleDisplayMode(.inline)
        // 内容が変わるたびに更新日時を進め、一覧の並び順へ反映する。
        .onChange(of: memo.title) {
            memo.updatedAt = Date()
        }
        .onChange(of: memo.bodyText) {
            memo.updatedAt = Date()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                // 編集中のメモをツールバーからピン留めできる。
                Button {
                    memo.isPinned.toggle()
                    memo.updatedAt = Date()
                } label: {
                    Image(systemName: memo.isPinned ? "pin.fill" : "pin")
                }
                .foregroundStyle(memo.isPinned ? Color.cyan : Color.blue)
                .accessibilityLabel(memo.isPinned ? "ピンを外す" : "ピン留め")
            }
        }
    }
}

// 単体のメモを使った編集画面のプレビュー。
#Preview {

    let preview = Memo(
        title: "サンプル",
        bodyText: "本文です"
    )

    MemoEditView(memo: preview)
}
