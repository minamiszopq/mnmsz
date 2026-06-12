// Folder.swift
// フォルダ階層と、その中に保存されるメモを表すSwiftDataモデル。

import Foundation
import SwiftData

/// メモを整理するフォルダ。
/// `parent` と `subfolders` によって任意の深さの階層を作れる。
@Model
class Folder {

    // ドラッグ&ドロップ時に保存済みフォルダを特定する安定したID。
    var transferID: UUID = UUID()

    // フォルダ名
    var name: String

    // このフォルダの親。nilの場合はルート階層に表示する。
    var parent: Folder?

    // 直下の子フォルダ。親を削除したときは配下もまとめて削除する。
    @Relationship(deleteRule: .cascade, inverse: \Folder.parent)
    var subfolders: [Folder] = []

    // このフォルダに直接所属するメモ。
    @Relationship(deleteRule: .cascade, inverse: \Memo.folder)
    var memos: [Memo] = []

    /// 名前と任意の親フォルダを指定して作成する。
    init(name: String, parent: Folder? = nil, transferID: UUID = UUID()) {

        self.name = name
        self.parent = parent
        self.transferID = transferID
    }

    /// 指定したフォルダが自分自身、または自分の子孫ならtrueを返す。
    /// フォルダを自分の配下へ移動して循環構造になることを防ぐために使う。
    func containsInSubtree(_ candidate: Folder) -> Bool {
        var current: Folder? = candidate

        while let folder = current {
            if folder.transferID == transferID {
                return true
            }
            current = folder.parent
        }

        return false
    }
}
