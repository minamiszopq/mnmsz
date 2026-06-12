// MemoCardView.swift
// メモ一覧でタイトル、本文抜粋、更新日時を表示する再利用可能な行ビュー。

import SwiftUI

struct MemoCardView: View {

    // 表示対象
    let memo: Memo

    var body: some View {

        VStack(alignment: .leading,
               spacing: 8) {

            HStack(alignment: .firstTextBaseline) {
                // タイトル
                Text(memo.title)
                    .font(.headline)

                Spacer()

                if memo.isPinned {
                    // ピン留め済みであることを一覧上でも視覚的に示す。
                    Image(systemName: "pin.fill")
                        .font(.caption)
                        .foregroundStyle(.cyan)
                }
            }

            // 本文
            Text(
                memo.bodyText.isEmpty
                ? "本文なし"
                : memo.bodyText
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .lineLimit(2)

            // 「3分前」のような相対時刻で最終更新を表示する。
            Text(memo.updatedAt, format: .relative(presentation: .named))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(maxWidth: .infinity,
               alignment: .leading)

        .background(

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.blue.opacity(0.08))
        )
    }
}

// カード単体の見た目を確認するプレビュー。
#Preview {

    MemoCardView(
        memo: Memo(
            title: "サンプル",
            bodyText: "これは本文です"
        )
    )
}
