// FolderDetailView.swift
// 選択したフォルダ直下のサブフォルダとメモを管理する画面。

import SwiftData
import SwiftUI

/// フォルダを掘り下げながら、サブフォルダとメモを追加・編集する画面。
struct FolderDetailView: View {

    // 現在表示しているフォルダ。
    let folder: Folder

    // SwiftDataへの追加と削除に使用するコンテキスト。
    @Environment(\.modelContext) private var context

    // ドロップデータのIDから移動対象を取得するため、全項目を監視する。
    @Query private var allFolders: [Folder]
    @Query private var allMemos: [Memo]

    // クイック追加欄と検索バーの入力状態。
    @State private var newFolder = ""
    @State private var newMemo = ""
    @State private var searchText = ""

    // サブフォルダを名前順に並べ、検索文字列で絞り込む。
    private var filteredSubfolders: [Folder] {
        folder.subfolders
            .filter { subfolder in
                searchText.isEmpty
                || subfolder.name.localizedCaseInsensitiveContains(searchText)
            }
            .sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
    }

    // メモはタイトルと本文を検索し、ピン留め、更新日時の順で表示する。
    private var filteredMemos: [Memo] {
        folder.memos
            .filter { memo in
                searchText.isEmpty
                || memo.title.localizedCaseInsensitiveContains(searchText)
                || memo.bodyText.localizedCaseInsensitiveContains(searchText)
            }
            .sorted { lhs, rhs in
                if lhs.isPinned != rhs.isPinned {
                    return lhs.isPinned
                }
                return lhs.updatedAt > rhs.updatedAt
            }
    }

    var body: some View {
        VStack {
            // 現在の階層へサブフォルダまたはメモを素早く追加する。
            VStack(spacing: 10) {
                HStack {
                    TextField("サブフォルダ名", text: $newFolder)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(addSubfolder)

                    Button(action: addSubfolder) {
                        Image(systemName: "folder.badge.plus")
                            .font(.title2)
                    }
                    .disabled(trimmedFolderName.isEmpty)
                    .accessibilityLabel("サブフォルダを追加")
                }

                HStack {
                    TextField("メモを入力", text: $newMemo)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(addMemo)

                    Button(action: addMemo) {
                        Image(systemName: "note.text.badge.plus")
                            .font(.title2)
                    }
                    .disabled(trimmedMemoTitle.isEmpty)
                    .accessibilityLabel("メモを追加")
                }
            }
            .padding()

            // 検索時に一致する項目がなければ専用の案内を表示する。
            if !searchText.isEmpty && filteredSubfolders.isEmpty && filteredMemos.isEmpty {
                ContentUnavailableView(
                    "見つかりません",
                    systemImage: "magnifyingglass",
                    description: Text("別のキーワードで検索してください")
                )
            } else {
                // 直下のサブフォルダとメモを種類ごとのセクションで表示する。
                List {
                    Section("フォルダツリー") {
                        FolderTreeView(
                            folders: [rootFolder],
                            onDrop: moveItem
                        )
                        .listRowBackground(Color.blue.opacity(0.04))
                    }

                    if filteredSubfolders.isEmpty && filteredMemos.isEmpty {
                        Section {
                            Label(
                                "上の入力欄からフォルダまたはメモを追加できます",
                                systemImage: "tray"
                            )
                            .foregroundStyle(.secondary)
                        }
                    }

                    if !filteredSubfolders.isEmpty {
                        Section("フォルダ") {
                            ForEach(filteredSubfolders) { subfolder in
                                NavigationLink {
                                    // 同じ詳細画面を使うことで任意の深さまで移動できる。
                                    FolderDetailView(folder: subfolder)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "folder.fill")
                                            .font(.title2)
                                            .foregroundStyle(.blue)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(subfolder.name)
                                                .font(.headline)

                                            Text(folderSummary(for: subfolder))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .draggable(
                                    LibraryTransferItem(
                                        kind: .folder,
                                        id: subfolder.transferID
                                    )
                                )
                                .dropDestination(for: LibraryTransferItem.self) { items, _ in
                                    guard let item = items.first else {
                                        return false
                                    }
                                    return moveItem(item, to: subfolder)
                                }
                            }
                            .onDelete(perform: deleteSubfolder)
                        }
                    }

                    if !filteredMemos.isEmpty {
                        Section("メモ") {
                            ForEach(filteredMemos) { memo in
                                NavigationLink {
                                    MemoEditView(memo: memo)
                                } label: {
                                    MemoCardView(memo: memo)
                                }
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .draggable(
                                    LibraryTransferItem(kind: .memo, id: memo.transferID)
                                )
                                .swipeActions(edge: .leading) {
                                    // 編集画面を開かずにピン状態を切り替える。
                                    Button {
                                        memo.isPinned.toggle()
                                        memo.updatedAt = Date()
                                    } label: {
                                        Label(
                                            memo.isPinned ? "ピンを外す" : "ピン留め",
                                            systemImage: memo.isPinned ? "pin.slash" : "pin"
                                        )
                                    }
                                    .tint(.blue)
                                }
                            }
                            .onDelete(perform: deleteMemo)
                        }
                    }
                }
                .listStyle(.insetGrouped)
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
        .navigationTitle(folder.name)
        .searchable(text: $searchText, prompt: "メモとフォルダを検索")
    }

    // 入力値の前後にある空白と改行を除去する。
    private var trimmedFolderName: String {
        newFolder.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedMemoTitle: String {
        newMemo.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // 現在の階層が属する最上位フォルダ。ツリー全体の起点にする。
    private var rootFolder: Folder {
        var current = folder
        while let parent = current.parent {
            current = parent
        }
        return current
    }

    // 現在表示しているフォルダを親としてサブフォルダを保存する。
    private func addSubfolder() {
        guard !trimmedFolderName.isEmpty else {
            return
        }

        let subfolder = Folder(name: trimmedFolderName, parent: folder)
        context.insert(subfolder)
        newFolder = ""
    }

    // 現在表示しているフォルダへメモを保存する。
    private func addMemo() {
        guard !trimmedMemoTitle.isEmpty else {
            return
        }

        let memo = Memo(title: trimmedMemoTitle, folder: folder)
        context.insert(memo)
        newMemo = ""
    }

    // サブフォルダ削除時は配下もcascade設定で削除される。
    private func deleteSubfolder(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filteredSubfolders[index])
        }
    }

    // 表示中の順番に対応するメモを削除する。
    private func deleteMemo(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filteredMemos[index])
        }
    }

    // フォルダ行に直下の内容件数を表示する。
    private func folderSummary(for folder: Folder) -> String {
        "\(folder.subfolders.count)フォルダ・\(folder.memos.count)メモ"
    }

    // ツリーまたはフォルダ行へドロップされたメモ・フォルダを移動する。
    private func moveItem(_ item: LibraryTransferItem, to destination: Folder) -> Bool {
        switch item.kind {
        case .folder:
            guard let movedFolder = allFolders.first(where: { $0.transferID == item.id }),
                  !movedFolder.containsInSubtree(destination) else {
                return false
            }
            movedFolder.parent = destination

        case .memo:
            guard let memo = allMemos.first(where: { $0.transferID == item.id }) else {
                return false
            }
            memo.folder = destination
            memo.updatedAt = Date()
        }

        try? context.save()
        return true
    }
}

// 入れ子表示に使う詳細画面のプレビュー。
#Preview {
    let previewFolder = Folder(name: "Preview")

    FolderDetailView(folder: previewFolder)
        .modelContainer(for: [Memo.self, Folder.self], inMemory: true)
}
