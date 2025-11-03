import Foundation

// ObservableObjectプロトコルに準拠させると、この中のデータが変更されたことをViewに通知できる
class DiagnosisSession: ObservableObject {
    // @Publishedを付けると、変更が自動的にViewに通知される
    @Published var wantToEatItems: [Recipe] = []
    @Published var notWantToEatItems: [Recipe] = []
    // ▼ 古いプロパティは削除してもOKですが、念のため残しておきます ▼
    @Published var selectedCarbs: [MainCarb] = []
    @Published var selectedGenres: [Genre] = []
    @Published var selectedMainFoods: [MainFood] = []
    @Published var selectedTastes: [Taste] = []
    @Published var selectedTemps: [Temp] = []
    // ▲ ここまで ▲
    @Published var selectedTags: Set<Tag> = []
    
    func performDiagnosis() -> [Recipe] {
        // --- ▼ここからデバッグコードを追加▼ ---
        print("\n\n--- 診断開始 (デバッグモード Ver.2) ---")
        print("ユーザーが選んだタグ: \(selectedTags.map { $0.name })")
        // --- ▲ここまでデバッグコードを追加▲ ---
        
        var candidates = RecipeDatabase.allRecipes
        
        // 1. 「食べたくないもの」は最優先で除外
        if !notWantToEatItems.isEmpty {
            let excludedIds = Set(notWantToEatItems.map { $0.id })
            candidates.removeAll { excludedIds.contains($0.id) }
        }
        
        // 2. スコアリング（改訂版）
        let selectedTagsByCategory = Dictionary(grouping: selectedTags, by: { $0.category })
        
        let scoredRecipes = candidates.map { recipe -> (Recipe, Int) in
            var score = 0
            
            // --- ▼ここからデバッグコードを追加▼ ---
            print("\n[チェック中] レシピ: \(recipe.name)")
            // --- ▲ここまでデバッグコードを追加▲ ---
            
            // ユーザーが選んだカテゴリごとに、マッチを判定する
            for (category, tags) in selectedTagsByCategory {
                let tagValues = tags.map { $0.value }
                var isMatch = false // デバッグ用に一時変数を用意
                
                switch category {
                case .mainCarb:
                    if let mainCarb = recipe.mainCarb, tagValues.contains(mainCarb) { isMatch = true }
                case .genre:
                    if let genre = recipe.genre, tagValues.contains(genre) { isMatch = true }
                case .mainFood:
                    if let mainFood = recipe.mainFood, tagValues.contains(mainFood) { isMatch = true }
                case .taste:
                    if let taste = recipe.taste, tagValues.contains(taste) { isMatch = true }
                case .temp:
                    if let temp = recipe.temp, tagValues.contains(temp) { isMatch = true }
                }
                
                // --- ▼ここからデバッグコードを追加▼ ---
                if isMatch {
                    score += 1
                    print("  ✅ マッチ！ カテゴリ: \(category) -> スコア+1 (現在: \(score))")
                } else {
                    print("  ❌ ミスマッチ カテゴリ: \(category)")
                }
                // --- ▲ここまでデバッグコードを追加▲ ---
            }

            // 「食べたいもの」のボーナス点は別途加算
            if !wantToEatItems.isEmpty && wantToEatItems.contains(where: { $0.id == recipe.id }) {
                score += 10
                // --- ▼ここからデバッグコードを追加▼ ---
                print("  ボーナス点+10！")
                // --- ▲ここまでデバッグコードを追加▲ ---
            }
    
            // --- ▼ここからデバッグコードを追加▼ ---
            if score > 0 {
                print("  ⭐️ 最終スコア: \(score)")
            }
            // --- ▲ここまでデバッグコードを追加▲ ---
            return (recipe, score)
        }
        
        // 3. 結果の加工
        // スコアが1点以上のものを全て抽出
        // ▼ .score を .1 に修正 ▼
        let hitRecipes = scoredRecipes.filter { $0.1 > 0 }
        
        // もしヒットが0件なら、5件保証ロジックへ
        if hitRecipes.isEmpty {
            // ▼ .recipe を .0 に修正 ▼
            let zeroScoreRecipes = scoredRecipes.map { $0.0 }
            return Array(zeroScoreRecipes.shuffled().prefix(5))
        }
        
        // 最高スコアが何点かを調べる
        // ▼ .score を .1 に修正 ▼
        let maxScore = hitRecipes.map { $0.1 }.max() ?? 0
        
        // 最高スコアのレシピをすべて取得し、シャッフルする
        // ▼ .score を .1 に修正 ▼
        let topTierRecipes = hitRecipes.filter { $0.1 == maxScore }.shuffled()
        
        // 最終的な結果リスト
        // ▼ .recipe を .0 に修正 ▼
        var finalResult = topTierRecipes.map { $0.0 }
        
        // もし最高スコアのレシピが5件未満なら、次点のレシピで補充する
        if finalResult.count < 5 {
            // 次点のスコアが何点かを調べる
            // ▼ .score を .1 に修正 ▼
            if let nextMaxScore = hitRecipes.filter({ $0.1 < maxScore }).map({ $0.1 }).max() {
                
                // 次点のスコアのレシピをすべて取得し、シャッフルする
                // ▼ .score を .1 に修正 ▼
                let secondTierRecipes = hitRecipes.filter { $0.1 == nextMaxScore }.shuffled()
                
                // 不足している件数を計算
                let remainingCount = 5 - finalResult.count
                
                // 次点のレシピから不足分だけ取り出して追加
                let fillerRecipes = secondTierRecipes.prefix(remainingCount)
                
                // ▼ .recipe を .0 に修正 ▼
                finalResult.append(contentsOf: fillerRecipes.map { $0.0 })
            }
        }
        
        // 最終的な表示件数を最大5件に制限する
        return Array(finalResult.prefix(5))
    }
}
