// FolderView.swift
// 親を持たないルートフォルダの作成、検索、削除を行う開始画面。

import SwiftUI
import SwiftData

/// フォルダ階層の最上位を表示する画面。
struct FolderView: View {

    // 保存されている全フォルダを取得し、表示時にルートだけへ絞り込む。
    @Query private var folders: [Folder]

    // ドロップされたメモをIDから取得するため、全メモも監視する。
    @Query private var memos: [Memo]

    // SwiftData操作
    @Environment(\.modelContext) private var context

    // 新規フォルダ名
    @State private var folderName = ""

    // ルートフォルダを名前で検索するための文字列。
    @State private var searchText = ""

    // 親がないフォルダだけを名前順に並べ、検索文字列があればさらに絞り込む。
    private var filteredFolders: [Folder] {
        let rootFolders = folders.filter { $0.parent == nil }
        let sortedFolders = rootFolders.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }

        guard !searchText.isEmpty else {
            return sortedFolders
        }

        return sortedFolders.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {

        NavigationStack {

            VStack {

                // ルートフォルダのクイック追加欄。
                HStack {

                    TextField("フォルダ名", text: $folderName)
                        .textFieldStyle(.roundedBorder)
                        .submitLabel(.done)
                        .onSubmit(addFolder)

                    Button("追加", action: addFolder)
                        .disabled(trimmedFolderName.isEmpty)
                }
                .padding()

                if filteredFolders.isEmpty {
                    // データがない場合と検索結果がない場合で案内を切り替える。
                    ContentUnavailableView(
                        searchText.isEmpty ? "フォルダがありません" : "見つかりません",
                        systemImage: searchText.isEmpty ? "folder.badge.plus" : "magnifyingglass",
                        description: Text(searchText.isEmpty ? "上の入力欄からフォルダを追加できます" : "別の名前で検索してください")
                    )
                } else {
                    // ツリー表示と通常の一覧を同じ画面で確認できる。
                    List {
                        Section("フォルダツリー") {
                            FolderTreeView(
                                folders: folders.filter { $0.parent == nil },
                                onDrop: moveItem
                            )
                            .listRowBackground(Color.blue.opacity(0.04))
                        }

                        Section("ルートフォルダ") {
                            rootDropTarget

                            ForEach(filteredFolders) { folder in

                                NavigationLink {

                                    FolderDetailView(folder: folder)

                                } label: {

                                    HStack(spacing: 12) {

                                        Image(systemName: "folder.fill")
                                            .font(.title2)
                                            .foregroundStyle(.blue)

                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(folder.name)
                                                .font(.headline)

                                            Text(folderSummary(for: folder))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .draggable(
                                    LibraryTransferItem(kind: .folder, id: folder.transferID)
                                )
                                .dropDestination(for: LibraryTransferItem.self) { items, _ in
                                    guard let item = items.first else {
                                        return false
                                    }
                                    return moveItem(item, to: folder)
                                }
                            }
                            .onDelete(perform: deleteFolder)
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
            .navigationTitle("フォルダ")
            .searchable(text: $searchText, prompt: "フォルダを検索")
        }
    }

    private var trimmedFolderName: String {
        folderName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // フォルダを最上位へ戻すための明示的なドロップ領域。
    private var rootDropTarget: some View {
        Label("ここにドロップして最上位へ移動", systemImage: "arrow.up.to.line")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(.blue)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .dropDestination(for: LibraryTransferItem.self) { items, _ in
                guard let item = items.first, item.kind == .folder else {
                    return false
                }
                return moveFolderToRoot(item)
            }
    }

    // 空白だけの名前を除外し、ルートフォルダとして保存する。
    private func addFolder() {
        guard !trimmedFolderName.isEmpty else {
            return
        }

        context.insert(Folder(name: trimmedFolderName))
        folderName = ""
    }

    // 削除時はcascade設定により、配下のフォルダとメモも削除される。
    private func deleteFolder(at offsets: IndexSet) {
        for index in offsets {
            context.delete(filteredFolders[index])
        }
    }

    // フォルダ行に直下の内容件数を短く表示する。
    private func folderSummary(for folder: Folder) -> String {
        "\(folder.subfolders.count)フォルダ・\(folder.memos.count)メモ"
    }

    // ツリーまたはフォルダ行へドロップされた項目を移動する。
    private func moveItem(_ item: LibraryTransferItem, to destination: Folder) -> Bool {
        switch item.kind {
        case .folder:
            guard let movedFolder = folders.first(where: { $0.transferID == item.id }),
                  !movedFolder.containsInSubtree(destination) else {
                return false
            }
            movedFolder.parent = destination

        case .memo:
            guard let memo = memos.first(where: { $0.transferID == item.id }) else {
                return false
            }
            memo.folder = destination
            memo.updatedAt = Date()
        }

        try? context.save()
        return true
    }

    // フォルダの親を外してルート階層へ戻す。
    private func moveFolderToRoot(_ item: LibraryTransferItem) -> Bool {
        guard let movedFolder = folders.first(where: { $0.transferID == item.id }),
              movedFolder.parent != nil else {
            return false
        }

        movedFolder.parent = nil
        try? context.save()
        return true
    }
}

// SwiftDataをメモリ上に用意して画面を確認するプレビュー。
#Preview {

    FolderView()
        .modelContainer(for: [Folder.self, Memo.self])
}
