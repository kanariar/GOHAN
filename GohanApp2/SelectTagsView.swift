import SwiftUI

struct SelectTagsView: View {
    @EnvironmentObject var session: DiagnosisSession
    
    // レイアウト定義
    private var tagGroups: [TagCategory: [Tag]] { Dictionary(grouping: AllTags.list, by: { $0.category }) }
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
    
    private func toggleTagSelection(_ tag: Tag) {
        if session.selectedTags.contains(tag) {
            session.selectedTags.remove(tag)
        } else {
            session.selectedTags.insert(tag)
        }
    }
}


// --- ここから下は変更なし ---

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
