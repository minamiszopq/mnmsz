// FolderTreeView.swift
// フォルダ階層をインデントと接続線で視覚化する再帰ビュー。

import SwiftUI

/// ルートフォルダ群からツリー全体を表示する。
struct FolderTreeView: View {
    let folders: [Folder]
    let onDrop: (LibraryTransferItem, Folder) -> Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(sortedFolders) { folder in
                FolderTreeNodeView(folder: folder, depth: 0, onDrop: onDrop)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var sortedFolders: [Folder] {
        folders.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}

/// 1つのフォルダと、その子フォルダを再帰的に描画する。
private struct FolderTreeNodeView: View {
    let folder: Folder
    let depth: Int
    let onDrop: (LibraryTransferItem, Folder) -> Bool

    @State private var isExpanded = true
    @State private var isDropTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                if folder.subfolders.isEmpty {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 5))
                        .frame(width: 14)
                        .foregroundStyle(.cyan)
                } else {
                    Button {
                        withAnimation(.snappy) {
                            isExpanded.toggle()
                        }
                    } label: {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                            .font(.caption.bold())
                            .frame(width: 14)
                    }
                    .buttonStyle(.plain)
                }

                Image(systemName: isExpanded ? "folder.fill" : "folder")
                    .foregroundStyle(.blue)

                Text(folder.name)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                Text("\(folder.memos.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isDropTargeted ? Color.blue.opacity(0.18) : Color.blue.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDropTargeted ? Color.blue : Color.clear, lineWidth: 2)
            )
            .draggable(LibraryTransferItem(kind: .folder, id: folder.transferID))
            .dropDestination(for: LibraryTransferItem.self) { items, _ in
                guard let item = items.first else {
                    return false
                }
                return onDrop(item, folder)
            } isTargeted: { targeted in
                isDropTargeted = targeted
            }

            if isExpanded && !folder.subfolders.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(sortedSubfolders) { subfolder in
                        FolderTreeNodeView(
                            folder: subfolder,
                            depth: depth + 1,
                            onDrop: onDrop
                        )
                    }
                }
                .padding(.leading, 22)
                .overlay(alignment: .leading) {
                    Rectangle()
                        .fill(Color.blue.opacity(0.25))
                        .frame(width: 2)
                        .padding(.leading, 7)
                }
            }
        }
        .padding(.leading, depth == 0 ? 0 : 2)
    }

    private var sortedSubfolders: [Folder] {
        folder.subfolders.sorted {
            $0.name.localizedStandardCompare($1.name) == .orderedAscending
        }
    }
}
