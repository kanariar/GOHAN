//「食べたくないもの」はやめた

import Foundation

// ObservableObjectプロトコルに準拠させると、この中のデータが変更されたことをViewに通知できる
class DiagnosisSession: ObservableObject {
    
    //ユーザーが選んだデータを保持する場所
    
    // @Publishedを付けると、変更が自動的にViewに通知される
    @Published var wantToEatItems: [Recipe] = []
    @Published var notWantToEatItems: [Recipe] = []
    
    // ▼ 古いプロパティ
//    @Published var selectedCarbs: [MainCarb] = []
//    @Published var selectedGenres: [Genre] = []
//    @Published var selectedMainFoods: [MainFood] = []
//    @Published var selectedTastes: [Taste] = []
//    @Published var selectedTemps: [Temp] = []

    // ユーザーが画面で選んだ「タグ」全体を保持するSet（重複のないリスト）。これが現在の診断の主要データ。
    @Published var selectedTags: Set<Tag> = []
    
    
    
    
    //診断ロジック
    func performDiagnosis() -> [Recipe] {
        // --- ▼ここからデバッグコード▼ ---
        print("\n\n--- 診断開始 (デバッグモード Ver.2) ---")
        print("ユーザーが選んだタグ: \(selectedTags.map { $0.name })")
        // --- ▲ここまでデバッグコード▲ ---
        
        var candidates = RecipeDatabase.allRecipes
        
        // 1. 「食べたくないもの」は最優先で除外
        if !notWantToEatItems.isEmpty {
            let excludedIds = Set(notWantToEatItems.map { $0.id })
            candidates.removeAll { excludedIds.contains($0.id) }
        }
        
        // 2. スコアリング（改訂版）
        let selectedTagsByCategory = Dictionary(grouping: selectedTags, by: { $0.category })
        
        // 候補レシピ一つ一つをチェックし、「レシピとスコアのタプル」に変換（map）
        let scoredRecipes = candidates.map { recipe -> (Recipe, Int) in
            var score = 0
            
            // --- ▼ここからデバッグコード▼ ---
            print("\n[チェック中] レシピ: \(recipe.name)")
            // --- ▲ここまでデバッグコード▲ ---
            
            //ユーザーが選んだカテゴリ（キー）と、そのカテゴリに属するタグ（値）をループで処理
            for (category, tags) in selectedTagsByCategory {
                let tagValues = tags.map { $0.value }
                var isMatch = false // デバッグ用に一時変数を用意
                
                //レシピのカテゴリデータと、選択されたタグデータが一致するかをチェック（Switch文にする）
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
                
                // --- ▼ここからデバッグコード▼ ---
                if isMatch {
                    score += 1
                    print("  ✅ マッチ！ カテゴリ: \(category) -> スコア+1 (現在: \(score))")
                } else {
                    print("  ❌ ミスマッチ カテゴリ: \(category)")
                }
                // --- ▲ここまでデバッグコード▲ ---
            }

            // 「食べたいもの」のボーナス点は別途加算
            if !wantToEatItems.isEmpty && wantToEatItems.contains(where: { $0.id == recipe.id }) {
                score += 10
                // --- ▼ここからデバッグコード▼ ---
                print("  ボーナス点+10！")
                // --- ▲ここまでデバッグコード▲ ---
            }
    
            // --- ▼ここからデバッグコード▼ ---
            if score > 0 {
                print("  ⭐️ 最終スコア: \(score)")
            }
            // --- ▲ここまでデバッグコード▲ ---
            return (recipe, score)
        }
        
        // 3. 結果の加工
        // スコアが1点以上のものを全て抽出
        let hitRecipes = scoredRecipes.filter { $0.1 > 0 }
        
        // もしヒットが0件なら、5件保証ロジックへ
        if hitRecipes.isEmpty {
            let zeroScoreRecipes = scoredRecipes.map { $0.0 }
            return Array(zeroScoreRecipes.shuffled().prefix(5))
        }
        
        // 最高スコアが何点かを調べる
        let maxScore = hitRecipes.map { $0.1 }.max() ?? 0
        
        // 最高スコアのレシピをすべて取得し、シャッフルする
        let topTierRecipes = hitRecipes.filter { $0.1 == maxScore }.shuffled()
        
        // 最終的な結果リスト
        var finalResult = topTierRecipes.map { $0.0 }
        
        // もし最高スコアのレシピが5件未満なら、次点のレシピで補充する
        if finalResult.count < 5 {
            // 次点のスコアが何点かを調べる
            if let nextMaxScore = hitRecipes.filter({ $0.1 < maxScore }).map({ $0.1 }).max() {
                
                // 次点のスコアのレシピをすべて取得し、シャッフルする
                let secondTierRecipes = hitRecipes.filter { $0.1 == nextMaxScore }.shuffled()
                
                // 不足している件数を計算
                let remainingCount = 5 - finalResult.count
                
                // 次点のレシピから不足分だけ取り出して追加
                let fillerRecipes = secondTierRecipes.prefix(remainingCount)
                
                finalResult.append(contentsOf: fillerRecipes.map { $0.0 })
            }
        }
        
        // 最終的な表示件数を最大5件に制限する
        return Array(finalResult.prefix(5))
    }
}
