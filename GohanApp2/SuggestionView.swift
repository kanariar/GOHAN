import SwiftUI

struct SuggestionView: View {
    @EnvironmentObject var session: DiagnosisSession
    
    // もし前の画面から結果を渡されたら、それを使う
    var predeterminedSuggestions: [Recipe]? = nil
    
    @State private var finalSuggestions: [Recipe] = []
    
    // 共有する画像を生成するためのViewを保持
    private var shareImage: some View {
        ShareImageView(
            tags: Array(session.selectedTags),
            recipes: finalSuggestions
        )
    }
    
    var body: some View {
        VStack {
            if !finalSuggestions.isEmpty {
                // 結果が見つかった場合
                ConversationView(message: "決まりだね！\n今日のあなたには、これがピッタリだよ！", imageName: "cat_happy")
                
                ShareLink(
                    item: Image(uiImage: shareImage.snapshot()), // Viewを画像に変換して渡す
                    preview: SharePreview("診断結果", image: Image(uiImage: shareImage.snapshot()))
                ) {
                    Label("この結果を画像でシェア", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .padding(.bottom)
                
                // 以前作ったRecipeListViewを再利用して結果を表示
                RecipeListView(recipes: finalSuggestions, title: "")
                
            } else {
                // 結果が見つからなかった場合
                ConversationView(message: "うーん、ごめんニャ…\nピッタリなのが見つからなかった…\n条件を変えて試してみて！", imageName: "cat_sad") // 「悲しい顔」の画像がもしあれば
                
                Spacer()
            }
        }
        .background(Color.yellow.opacity(0.1).ignoresSafeArea())
        .navigationTitle("診断けっか")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // 戻るボタンを非表示
        .onAppear(perform: performFinalDiagnosis) // 画面表示時に最終診断を実行
    }
    
    private func performFinalDiagnosis() {
        if let suggestions = predeterminedSuggestions {
            // もし、渡された結果があれば、それを使う
            self.finalSuggestions = suggestions
        } else {
            // なければ、自分で診断を実行する（これまでの動き）
            self.finalSuggestions = session.performDiagnosis()
        }
    }
    private func generateShareText() -> String {
        // ユーザーが選んだ気分タグの名前を取得
        let tagNames = session.selectedTags.map { $0.name }.joined(separator: ", ")
        
        // おすすめレシピのトップ3の名前を取得
        let recipeNames = finalSuggestions.prefix(3).map { $0.name }.joined(separator: "\n・")
        
        // 共有するテキストを組み立てる
        let shareText = """
        今日のわたしの気分は…
        【 \(tagNames) 】
        
        アメリちゃんのおすすめはこれだったよ！
        ・\(recipeNames)
        
        #今日のごはんどうする #ごはん診断
        """
        
        return shareText
    }
}


#Preview {
    NavigationStack {
        SuggestionView()
            .environmentObject({
                let session = DiagnosisSession()
                // プレビュー用に、最終質問まで終わった状態のデータを作る
                session.selectedTags = [
                    AllTags.list.first(where: { $0.name == "がっつり" })!,
                    AllTags.list.first(where: { $0.name == "お肉" })!,
                    AllTags.list.first(where: { $0.name == "和食" })!
                ]
                return session
            }())
    }
}
