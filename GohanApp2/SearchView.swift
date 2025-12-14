import SwiftUI

struct SearchView: View {
    // ユーザーが検索ボックスに入力したテキストを保持
    @State private var inputText: String = ""
    
    // ジャンル別ショートカットの定義
    private let shortcuts: [Genre] = [.japanese, .western, .chinese, .other]
    
    // 検索結果のレシピリストを保持（nilはまだ検索されていない状態を表す）
    @State private var searchResults: [Recipe]? = nil
    // 遷移先の画面に表示するタイトルを保持
    @State private var navigationTitle = ""
    // 画面遷移を実行するためのフラグ（trueになると.navigationDestinationが発火する）
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
                    searchByKeyword()//キーワード検索を実行
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            // ジャンル別ショートカット
            ScrollView {
                VStack(spacing: 15) {
                    Text("ジャンルから探す")
                        .font(.headline)
                    
                    // shortcutsリストの各要素（Genre enum）に対してボタンを生成
                    // id: \.self は enumのrawValue（"和食"など）を一意のIDとして使うことを意味
                    ForEach(shortcuts, id: \.self) { genre in// ボタンのテキストはenumのrawValue
                        Button(genre.rawValue) {
                            // --- ▼Google検索させる▼ ---
                            searchByGenre(genre)// 「食べ物　レシピ」検索を実行
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
        // shouldNavigateがtrueになったら、{}内の遷移先Viewに画面を切り替える
        .navigationDestination(isPresented: $shouldNavigate) {
            // searchResultsに値が入っている（nilでない）場合のみ実行
            if let results = searchResults {
                RecipeListView(recipes: results, title: navigationTitle)
            }
        }
    }
    
    // --- ロジック（メソッド） ---
        
    // キーワード検索を実行するメソッド
    private func searchByKeyword() {
        // 全角スペースを半角スペースに置換し、複数のキーワードに対応
        let replacedText = inputText.replacingOccurrences(of: "　", with: " ")
        let keywords = replacedText.split(separator: " ").map { String($0) }
        // キーワードが空なら何もしない
        guard !keywords.isEmpty else { return }
        
        // 全レシピをフィルタリング（絞り込み）
        let results = RecipeDatabase.allRecipes.filter { recipe in
            // ユーザーが入力したキーワードを一つずつチェック
            for keyword in keywords {
                // レシピ名 または キーワードリストにマッチしたら true
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
