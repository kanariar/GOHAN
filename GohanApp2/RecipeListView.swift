import SwiftUI

struct RecipeListView: View {
    // 表示するレシピのリストと、表示理由のタイトルを受け取る
    let recipes: [Recipe]
    let title: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // アメリちゃんの一言
                //ConversationView(message: "こんなのはどうかな？", imageName: "cat_happy")
                
                // レシピリスト
                ForEach(recipes) { recipe in
                    // Link Viewで、カード全体をタップ可能なリンクにする
                    Link(destination: generateSearchURL(for: recipe.name)) {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            // レシピが持つ主要なタグを全て表示する
                            HStack {
                                if let mainCarb = recipe.mainCarb {
                                    Text(mainCarb.rawValue)
                                        .font(.caption).padding(5)
                                        .background(Color.orange.opacity(0.1)).cornerRadius(5)
                                }
                                if let mainFood = recipe.mainFood {
                                    Text(mainFood.rawValue)
                                        .font(.caption).padding(5)
                                        .background(Color.red.opacity(0.1)).cornerRadius(5)
                                }
                                if let genre = recipe.genre {
                                    Text(genre.rawValue)
                                        .font(.caption).padding(5)
                                        .background(Color.blue.opacity(0.1)).cornerRadius(5)
                                }
                                if let taste = recipe.taste {
                                    Text(taste.rawValue)
                                        .font(.caption).padding(5)
                                        .background(Color.green.opacity(0.1)).cornerRadius(5)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    // リンクにすると文字が青くなるのを防ぎ、元の色を維持する
                    .foregroundColor(.primary)
                }
            }
            .padding()
        }
        .background(Color.yellow.opacity(0.1).ignoresSafeArea())
        .navigationTitle(title) // 受け取ったタイトルを表示
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func generateSearchURL(for recipeName: String) -> URL {
        // 1. 検索したい文字列を作成
        let searchText = "\(recipeName) レシピ"
        
        // 2. 日本語などをURLで安全に使える形式に変換（パーセントエンコーディング）
        guard let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            // 変換に失敗した場合は、Googleのトップページを返す
            return URL(string: "https://www.google.com")!
        }
        
        // 3. Google検索のURLを組み立てる
        let urlString = "https://www.google.com/search?q=\(encodedText)"
        
        // 4. URLオブジェクトを生成して返す
        return URL(string: urlString)!
    }
}


#Preview {
    // プレビュー用に仮データを渡す
    RecipeListView(recipes: Array(RecipeDatabase.allRecipes.prefix(3)), title: "検索結果")
}
