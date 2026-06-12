// MemoappApp.swift
// アプリの開始画面とSwiftDataコンテナを構成するエントリーポイント。

import SwiftUI
import SwiftData

@main
struct MemoAppApp: App {

    var body: some Scene {

        WindowGroup {
            // フォルダ階層のルート画面からアプリを開始する。
            FolderView()
                .tint(.blue)
        }
        // FolderとMemoを同じコンテナで永続化し、関係を自動保存する。
        .modelContainer(for: [Memo.self, Folder.self])
    }
}
