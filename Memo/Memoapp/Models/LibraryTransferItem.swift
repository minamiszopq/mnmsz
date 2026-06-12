// LibraryTransferItem.swift
// アプリ内のメモとフォルダをドラッグ&ドロップで識別する転送データ。

import CoreTransferable
import Foundation
import UniformTypeIdentifiers

/// 永続モデルそのものではなく、種類と安定したIDだけをドラッグ先へ渡す。
struct LibraryTransferItem: Codable, Transferable {
    enum ItemKind: String, Codable {
        case folder
        case memo
    }

    let kind: ItemKind
    let id: UUID

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .memoLibraryItem)
    }
}

extension UTType {
    /// このメモアプリ専用のドラッグデータ形式。
    static let memoLibraryItem = UTType(exportedAs: "mnm.memoapp.library-item")
}
