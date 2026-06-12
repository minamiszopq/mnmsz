// Memo.swift
// タイトル、本文、所属先、表示順に必要な情報を保持するSwiftDataモデル。

import Foundation
import SwiftData

@Model
class Memo {

    // ドラッグ&ドロップ時に保存済みメモを特定する安定したID。
    var transferID: UUID = UUID()

    // タイトル
    var title: String

    // 本文
    var bodyText: String

    // 所属フォルダ。フォルダ側のmemosと双方向に同期される。
    var folder: Folder?

    // 作成日時は履歴用、更新日時は一覧の並び替えと表示に使用する。
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // trueのメモは同じフォルダ内で先頭に表示する。
    var isPinned: Bool = false

    /// 新しいメモを作成する。日時を引数化してプレビューや将来の移行にも対応する。
    init(
        title: String,
        bodyText: String = "",
        folder: Folder? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isPinned: Bool = false,
        transferID: UUID = UUID()
    ) {

        self.title = title
        self.bodyText = bodyText
        self.folder = folder
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isPinned = isPinned
        self.transferID = transferID
    }
}
