import Foundation

// 選択肢をenumで定義しておくと、間違いが減って安全になる
enum MainCarb: String, CaseIterable {
    case rice = "米"
    case noodle = "麺"
    case bread = "パン"
    case other = "その他"
}

enum Genre: String, CaseIterable {
    case japanese = "和食"
    case western = "洋食"
    case chinese = "中華"
    case other = "その他"
}

// ...他の項目も同様にenumで定義できる...

enum MainFood: String, CaseIterable { // CaseIterable を追加すると全選択肢を取得できる
    case meat = "肉", fish = "魚", vegetable = "野菜"
}
enum Taste: String, CaseIterable {
    case gatturi = "がっつり", assari = "あっさり", kotteri = "こってり"
}
enum Temp: String, CaseIterable {
    case hot = "温かい", cold = "冷たい"
}

// Recipe構造体も、これらの項目を持つように拡張する（これは診断ロジックで使います）

// レシピ１つ分の情報をまとめるための設計図（構造体）
struct Recipe: Identifiable {
    let id = UUID()
    let name: String            // 料理名 (recipe_name)
    let keywords: [String]      // 検索用キーワード
    
    // --- 診断項目 ---
    // これまでのenumプロパティを全てtagsにまとめる
    let tags: [Tag]
    
    // 既存のコードとの互換性のため、各プロパティにアクセスできるcomputed propertyを用意
    var mainCarb: MainCarb? { tags.first(where: { $0.category == .mainCarb })?.value as? MainCarb }
    var genre: Genre? { tags.first(where: { $0.category == .genre })?.value as? Genre }
    var mainFood: MainFood? { tags.first(where: { $0.category == .mainFood })?.value as? MainFood }
    var taste: Taste? { tags.first(where: { $0.category == .taste })?.value as? Taste }
    var temp: Temp? { tags.first(where: { $0.category == .temp })?.value as? Temp }
    
    init(name: String, keywords: [String], mainCarb: MainCarb, genre: Genre, mainFood: MainFood, taste: Taste, temp: Temp) {
        self.name = name
        self.keywords = keywords
        
        // 新しいTagの仕様に合わせて、ダミーのiconName("")を渡す
        self.tags = [
            Tag(name: "", iconName: "", category: .mainCarb, value: mainCarb),
            Tag(name: "", iconName: "", category: .genre, value: genre),
            Tag(name: "", iconName: "", category: .mainFood, value: mainFood),
            Tag(name: "", iconName: "", category: .taste, value: taste),
            Tag(name: "", iconName: "", category: .temp, value: temp)
        ]
    }
}
