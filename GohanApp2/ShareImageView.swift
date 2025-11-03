import SwiftUI

struct ShareImageView: View {
    // 表示したいタグとレシピを受け取る
    let tags: [Tag]
    let recipes: [Recipe]
    
    var body: some View {
            VStack(spacing: 10) { // spacingを調整
                // --- ヘッダー ---
                HStack {
                    Image("cat_happy")
                        .resizable().scaledToFit().frame(width: 50, height: 50)
                        .clipShape(Circle())
                    Text("今日のごはん診断")
                        .font(.title2).fontWeight(.bold)
                    Spacer() // 右側にスペースを確保
                }
                .padding(.horizontal)

                Divider()

                // --- 今日の気分 ---
                VStack {
                    Text("今日のわたしの気分は…")
                        .font(.headline)
                        .padding(.bottom, 15)
                    
                    FlowLayout {
                        ForEach(tags) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .padding(8)
                                .background(Color.yellow.opacity(0.3))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.bottom, 45)
                }
                .padding(.horizontal)
                // ▼ このエリアに最低限の高さを確保 ▼
                .frame(minHeight: 150)

                Divider()

                // --- おすすめレシピ ---
                VStack(alignment: .leading) {
                    Text("アメリちゃんのおすすめはこれ！")
                        .font(.headline)
                        .padding(.bottom, 15)
                    
                    ForEach(recipes.prefix(3)) { recipe in
                        Text("・\(recipe.name)")
                            .font(.body)
                            .padding(.bottom, 2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                Spacer() // 残りのスペースを埋める
                
                // --- フッター ---
                Text("#今日のごはんどうする #ごはん診断")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 10)      // 上の余白を20ポイントに指定
            .padding(.bottom, 45)   // 下の余白を15ポイントに指定
            .padding(.horizontal, 0) // 左右の余白はなし
            .frame(width: 350, height: 500) // 画像のサイズを指定
            .background(Color.white)
        }
}

// --- タグを自動で折り返すためのヘルパーView ---
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var totalHeight: CGFloat = 0
        var totalWidth: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > proposal.width ?? 0 {
                totalHeight += lineHeight + spacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
            totalWidth = max(totalWidth, lineWidth)
        }
        totalHeight += lineHeight
        return .init(width: totalWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var point = bounds.origin
        var lineHeight: CGFloat = 0

        for index in subviews.indices {
            if point.x + sizes[index].width > bounds.width {
                point.x = bounds.origin.x
                point.y += lineHeight + spacing
                lineHeight = 0
            }
            subviews[index].place(at: point, proposal: .unspecified)
            lineHeight = max(lineHeight, sizes[index].height)
            point.x += sizes[index].width + spacing
        }
    }
}




#Preview {
    ShareImageView(
        tags: Array(AllTags.list.prefix(4)),
        recipes: Array(RecipeDatabase.allRecipes.prefix(3))
    )
}
