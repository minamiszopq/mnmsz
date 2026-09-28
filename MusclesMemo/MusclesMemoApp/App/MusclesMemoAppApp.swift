import SwiftUI
import SwiftData

@main
struct MusclesMemoAppApp: App {
    let modelContainer: ModelContainer

    init() {
        Self.resetStoreIfIncompatible()

        if let container = try? ModelContainer(for: Exercise.self, WorkoutSet.self) {
            modelContainer = container
        } else {
            // 通常のロードで読み込めない場合（想定外のスキーマ不整合など）も、
            // ストアを作り直して必ず起動できるようにする。既存の記録は失われる。
            Self.deleteStoreFiles()
            modelContainer = try! ModelContainer(for: Exercise.self, WorkoutSet.self)
        }
        seedDefaultExercisesIfNeeded()
    }

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
                .tint(AppTheme.accent)
        }
        .modelContainer(modelContainer)
    }

    /// 初回起動時のみ、代表的な種目をあらかじめ登録しておく。
    private func seedDefaultExercisesIfNeeded() {
        let context = modelContainer.mainContext
        WorkoutRepository.seedDefaultExercisesIfNeeded(context: context)
        try? context.save()
    }

    /// アプリ更新前（bodyPart・weightMode 追加前など）に作られた古い形式のデータが
    /// 端末に残っていると、そのレコードを読み込んだ瞬間に SwiftData 内部で abort し、
    /// try/catch では捕まえられないクラッシュになることがある。
    /// これは実行前にしか防げないため、バージョンを1つ進めるたびにこのキーを更新し、
    /// 未対応の端末では初回起動時にストアを1回だけ作り直す（記録は失われるが起動を優先する）。
    private static let storeCompatibilityKey = "MusclesMemoApp.storeCompatibilityVersion"
    private static let currentStoreCompatibilityVersion = 2

    private static func resetStoreIfIncompatible() {
        let defaults = UserDefaults.standard
        let savedVersion = defaults.integer(forKey: storeCompatibilityKey)
        guard savedVersion < currentStoreCompatibilityVersion else { return }

        deleteStoreFiles()
        defaults.set(currentStoreCompatibilityVersion, forKey: storeCompatibilityKey)
    }

    private static func deleteStoreFiles() {
        let config = ModelConfiguration()
        let storeURL = config.url
        let suffixes = ["", "-wal", "-shm"]
        for suffix in suffixes {
            let url = URL(fileURLWithPath: storeURL.path + suffix)
            try? FileManager.default.removeItem(at: url)
        }
    }
}
