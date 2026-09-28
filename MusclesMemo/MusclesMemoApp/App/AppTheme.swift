import SwiftUI

/// アプリ全体の見た目の方針：寒色メイン・透明感のあるデータ系デザイン。
/// 新しい画面／コンポーネントを追加するときは必ずこのテーマを使うこと。
enum AppTheme {
    /// メインアクセント（シアン寄りのブルー）。
    static let accent = Color(red: 0.35, green: 0.80, blue: 0.98)
    /// サブアクセント（インディゴ）。グラフの2系統目などに使う。
    static let accentSecondary = Color(red: 0.53, green: 0.55, blue: 0.98)
    /// 強調・警告色（クールなパープル寄りレッドは使わずティール系で統一）。
    static let accentTertiary = Color(red: 0.30, green: 0.92, blue: 0.82)

    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.62)

    /// 背景の紺〜藍のグラデーション。透明感を出すため各画面共通で使う。
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.03, green: 0.06, blue: 0.14),
            Color(red: 0.05, green: 0.11, blue: 0.22),
            Color(red: 0.04, green: 0.08, blue: 0.18),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// カードやセクションに使うガラス風の背景マテリアル。
    static func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
    }
}

/// リストの背景を透過させ、AppTheme の背景グラデーションを透けさせるための共通モディファイア。
struct GlassScreenBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(AppTheme.backgroundGradient.ignoresSafeArea())
    }
}

extension View {
    func glassScreenBackground() -> some View {
        modifier(GlassScreenBackground())
    }
}
