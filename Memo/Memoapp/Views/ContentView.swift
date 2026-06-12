// ContentView.swift
// 全メモをフォルダ横断で表示するための補助画面。現在の起動画面はFolderView。
import SwiftData
import SwiftUI

struct ContentView: View {

    // SwiftDataから取得
    @Query private var memos: [Memo]

    // SwiftData操作
    @Environment(\.modelContext) private var context

    // 新規メモ入力
    @State private var newMemo = ""

    // 検索文字列
    @State private var searchText = ""

    // タイトルまたは本文に検索文字列を含むメモだけを返す。
    var filteredMemos: [Memo] {

        // 検索空なら全件
        if searchText.isEmpty {
            return memos
        }

        // タイトル or 本文検索
        return memos.filter { memo in

            memo.title.localizedCaseInsensitiveContains(searchText)
            ||
            memo.bodyText.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {

        NavigationStack {

            VStack {

                // フォルダに属さないメモを直接追加する入力欄。
                HStack {

                    TextField("メモを入力", text: $newMemo)
                        .textFieldStyle(.roundedBorder)

                    Button {

                        // 空白だけのメモは追加しない。
                        let trimmedMemo = newMemo.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmedMemo.isEmpty else {
                            return
                        }

                        // メモ作成
                        let memo = Memo(title: trimmedMemo)

                        // 保存
                        context.insert(memo)

                        // 入力欄クリア
                        newMemo = ""

                    } label: {

                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
                .padding()

                // 検索結果を含めてメモが0件の場合の案内。
                if filteredMemos.isEmpty {

                    VStack(spacing: 16) {

                        Image(systemName: "note.text")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)

                        Text("メモがありません")
                            .font(.headline)

                        Text("上から追加してみましょう")
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity,
                           maxHeight: .infinity)

                } else {

                    // フォルダを横断したメモ一覧。
                    List {

                        ForEach(filteredMemos) { memo in

                            NavigationLink {

                                // 編集画面
                                MemoEditView(memo: memo)

                            } label: {

                                MemoCardView(memo: memo)
                            }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteMemo)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.08), Color.cyan.opacity(0.03)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .navigationTitle("My Notes")

            // 検索バー
            .searchable(
                text: $searchText,
                prompt: "検索"
            )
        }
    }

    // MARK: - Delete

    // 現在表示している検索結果の順番に対応するメモを削除する。
    func deleteMemo(at offsets: IndexSet) {

        for index in offsets {

            let memo = filteredMemos[index]

            context.delete(memo)
        }
    }
}

// MARK: - Preview

#Preview {

    ContentView()
        .modelContainer(for: Memo.self)
}
