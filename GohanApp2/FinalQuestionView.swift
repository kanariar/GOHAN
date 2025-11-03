import SwiftUI

struct FinalQuestionView: View {
    @EnvironmentObject var session: DiagnosisSession
    
    // --- 状態管理 ---
    @State private var finalQuestionOptions: [Tag] = []
    @State private var shouldSkipToSuggestion = false
    @State private var finalSuggestions: [Recipe] = []

    var body: some View {
        ZStack {
            Color.yellow.opacity(0.1).ignoresSafeArea()
            
            VStack {
                if !finalQuestionOptions.isEmpty {
                    // --- 質問が表示される場合 ---
                    ConversationView(message: "なるほどね！\nそれなら…最後の質問！\nどっちの気分？", imageName: "cat_happy")
                    Spacer()
                    ForEach(finalQuestionOptions) { tag in
                        NavigationLink(destination: SuggestionView()) {
                            Text(tag.name)
                                .font(.title).fontWeight(.bold).padding()
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(Color.white)
                                .cornerRadius(15).shadow(radius: 3)
                        }
                        .simultaneousGesture(TapGesture().onEnded {
                            session.selectedTags.insert(tag)
                        })
                    }
                    Spacer()
                } else {
                    // --- 質問生成中の表示 ---
                    ConversationView(message: "うーん、ちょっと待ってね…\n考えてるニャ…", imageName: "cat_normal")
                    Spacer()
                }
            }
            .padding()
        }
        .navigationTitle("最後の質問")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .onAppear(perform: generateFinalQuestion)
        .navigationDestination(isPresented: $shouldSkipToSuggestion) {
            SuggestionView(predeterminedSuggestions: finalSuggestions)
        }
    }
    
    // --- ロジック ---
    private func generateFinalQuestion() {
        // <<<<< この関数の中身が、唯一の正しいロジックです >>>>>
        
        // 優先順位：ジャンル > 主食 > メイン食材
        let questionPriorities: [TagCategory] = [.genre, .mainCarb, .mainFood]
        
        // ユーザーが既に選んだカテゴリのセットを作る
        let selectedCategories = Set(session.selectedTags.map { $0.category })
        
        // 優先順位リストの中から、まだ選んでいないカテゴリを最初に見つける
        if let questionCategory = questionPriorities.first(where: { !selectedCategories.contains($0) }) {
            // --- ケース1: 未選択の質問カテゴリが見つかった場合 ---
            print("質問を生成します: \(questionCategory)")
            
            // そのカテゴリに属するタグを、AllTagsから全て取得する
            let optionsForCategory = AllTags.list.filter { $0.category == questionCategory }
            
            // 最大2つの選択肢を生成する
            self.finalQuestionOptions = Array(optionsForCategory.prefix(2))
            
            // もし選択肢が2つ未満なら、念のためスキップルートへ
            if self.finalQuestionOptions.count < 2 {
                skipToSuggestionView()
            }
        } else {
            // --- ケース2: 全ての優先カテゴリが選択済みだった場合 ---
            print("主要なカテゴリが全て選択済みのため、質問をスキップします。")
            skipToSuggestionView()
        }
    }

    private func skipToSuggestionView() {
        // sessionの診断ロジックを呼び出して、最終結果を作る
        self.finalSuggestions = session.performDiagnosis()
        // 結果画面へ進むためのスイッチをONにする
        self.shouldSkipToSuggestion = true
    }
}

#Preview {
    NavigationStack {
        FinalQuestionView()
            .environmentObject({
                let session = DiagnosisSession()
                session.selectedTags = [
                    AllTags.list.first(where: { $0.name == "がっつり" })!,
                    AllTags.list.first(where: { $0.name == "お肉" })!
                ]
                return session
            }())
    }
}
