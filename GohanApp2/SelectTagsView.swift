import SwiftUI

struct SelectTagsView: View {
    @EnvironmentObject var session: DiagnosisSession
    
    // レイアウト定義
    // 計算型プロパティ: 全タグリスト（AllTags.list）を、そのcategory（カテゴリ）でグループ化してDictionaryに変換
    // これにより、「味」カテゴリのタグ、「主食」カテゴリのタグ、という形で簡単にデータを取り出せる
    private var tagGroups: [TagCategory: [Tag]] { Dictionary(grouping: AllTags.list, by: { $0.category }) }
    // タググループを画面に表示する順番を定義（定義した順番通りに画面に表示される）
    private let categoryOrder: [TagCategory] = [.taste, .mainCarb, .mainFood, .genre, .temp]
    
    var body: some View {
        // GeometryReaderを使って、レイアウト崩れを防ぐ
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ConversationView(message: "オッケー！\n今の気分はどんな感じ？", imageName: "cat_normal")

                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(categoryOrder, id: \.self) { category in
                            if let tags = tagGroups[category] {
                                Text(category.displayName)
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                //ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(tags) { tag in
                                            TagCard(tag: tag, isSelected: session.selectedTags.contains(tag)) {
                                                toggleTagSelection(tag)
                                            }
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.horizontal)
                                //}
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .frame(height: geometry.size.height * 0.7) // 高さを画面サイズの70%に
                
                Spacer()

                // --- 次へ進むボタン ---
                NavigationLink(destination: FinalQuestionView()) {
                    Text("これで探してみて！")
                        .font(.title2).fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .background(session.selectedTags.isEmpty ? Color.gray : Color.blue)
                .cornerRadius(15)
                .padding()
                .disabled(session.selectedTags.isEmpty)
            }
            .background(Color.yellow.opacity(0.1).ignoresSafeArea())
            .navigationTitle("いっしょに考える")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    // タグがタップされたときに、選択状態を切り替えるメソッド
    private func toggleTagSelection(_ tag: Tag) {
        if session.selectedTags.contains(tag) {
            session.selectedTags.remove(tag)
        } else {
            session.selectedTags.insert(tag)
        }
    }
}

// 個々のタグボタンの見た目を定義する部品
struct TagCard: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                if tag.isEmoji {
                    Text(tag.iconName).font(.title)
                } else {
                    Image(systemName: tag.iconName).font(.title)
                }
                Text(tag.name).fontWeight(.medium).font(.callout)
            }
            .padding(8)
            .frame(width: 110, height: 90)
            .background(isSelected ? Color.yellow.opacity(0.3) : Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isSelected ? Color.yellow : Color.gray.opacity(0.3), lineWidth: 2)
            )
            .foregroundColor(.primary)
            .shadow(radius: 2)
        }
    }
}
// TagCategory（enum）に、画面表示用の名前（displayName）を定義する機能を追加
extension TagCategory {
    var displayName: String {
        switch self {
        case .taste: return "お腹のすき具合は？"
        case .mainCarb: return "主食はどれ？"
        case .mainFood: return "メインは何がいい？"
        case .genre: return "どんなジャンル？"
        case .temp: return "温度は？"
        //case .veggieLevel: return "野菜の量は？"
        }
    }
}

#Preview {
    NavigationStack { // PreviewでもNavigationLinkを有効にするために必要
        SelectTagsView()
            .environmentObject(DiagnosisSession())
    }
}
