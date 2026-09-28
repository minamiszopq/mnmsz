import SwiftUI

extension View {
    /// キーボード表示中に、画面の他の部分をタップしたときにキーボードを閉じる。
    /// simultaneousGesture を使うことで、他の行・ボタンのタップ動作は妨げない。
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}
