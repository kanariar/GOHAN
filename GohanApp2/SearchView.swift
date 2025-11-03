import SwiftUI

struct SearchView: View {
    @State private var inputText: String = ""
    
    // ジャンル別ショートカットの定義
    private let shortcuts: [Genre] = [.japanese, .western, .chinese, .other]
    
    @State private var searchResults: [Recipe]? = nil
    @State private var navigationTitle = ""
    @State private var shouldNavigate = false
    
    var body: some View {
        VStack {
            // アメリちゃんの会話
            ConversationView(message: "おっ、いいね！\n何が食べたい気分？", imageName: "cat_happy")
            
            // キーワード検索ボックス
            HStack {
                TextField("料理名やキーワードで検索", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                Button("検索") {
                    // --- ▼検索ロジックを呼び出す▼ ---
                    searchByKeyword()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            // ジャンル別ショートカット
            ScrollView {
                VStack(spacing: 15) {
                    Text("ジャンルから探す")
                        .font(.headline)
                    
                    ForEach(shortcuts, id: \.self) { genre in
                        Button(genre.rawValue) {
                            // --- ▼ジャンル検索ロジックを呼び出す▼ ---
                            searchByGenre(genre)
                        }
                        .font(.title2)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
        }
        .background(Color.yellow.opacity(0.1).ignoresSafeArea()) // 背景色
        .navigationTitle("きまってる！")
        .navigationBarTitleDisplayMode(.inline)
        // --- ▼画面遷移の命令を追加▼ ---
        .navigationDestination(isPresented: $shouldNavigate) {
            if let results = searchResults {
                RecipeListView(recipes: results, title: navigationTitle)
            }
        }
    }
    private func searchByKeyword() {
        let replacedText = inputText.replacingOccurrences(of: "　", with: " ")
        let keywords = replacedText.split(separator: " ").map { String($0) }
        guard !keywords.isEmpty else { return }
        
        let results = RecipeDatabase.allRecipes.filter { recipe in
            for keyword in keywords {
                if recipe.name.contains(keyword) || recipe.keywords.contains(keyword) {
                    return true
                }
            }
            return false
        }
        
        self.searchResults = results
        self.navigationTitle = "「\(inputText)」の検索結果"
        self.shouldNavigate = true
    }
    
    private func searchByGenre(_ genre: Genre) {
        let results = RecipeDatabase.allRecipes.filter { $0.genre == genre }
        
        self.searchResults = results
        self.navigationTitle = "「\(genre.rawValue)」の一覧"
        self.shouldNavigate = true
    }
}
#Preview {
    NavigationStack {
        SearchView()
    }
}
