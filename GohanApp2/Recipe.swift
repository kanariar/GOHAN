import Foundation

//enum (Enumeration / 列挙型) は、「選択肢が限られているデータ」を扱うときに使う「専用のデータ型」
// 選択肢をenumで定義しておくと、定義されていない値が入ることを防ぎ、安全になる
//→つまり自由入力にしないでボタン選択にするということ
// String: 内部的に各項目を「文字列（String）」として扱う
// CaseIterable: このenumに含まれる全ての選択肢（例: rice, noodle...）を簡単に取得できるようにする
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

//改行しなくても省略してかける
enum MainFood: String, CaseIterable { // CaseIterable を追加すると全選択肢を取得できる
    case meat = "肉", fish = "魚", vegetable = "野菜"
}
enum Taste: String, CaseIterable {
    case gatturi = "がっつり", assari = "あっさり", kotteri = "こってり"
}
enum Temp: String, CaseIterable {
    case hot = "温かい", cold = "冷たい"
}

// --- 【レシピの設計図： struct (構造体) 】 ---

// レシピ１つ分の情報をまとめるための設計図（構造体）
struct Recipe: Identifiable {
    // Identifiable: SwiftUIでリスト表示するときに必要。各要素を一意に識別するためのIDを自動生成
    let id = UUID()
    let name: String            // 料理名 (recipe_name)
    let keywords: [String]      // 検索用キーワード
    
    // --- 診断項目 ---
    // これまでのenumプロパティを全てtagsにまとめる
    let tags: [Tag]
    
    // 既存のコードとの互換性のため、各プロパティにアクセスできるcomputed propertyを用意
    // computed property: 「値を保持せず、アクセスされたときに計算して返す」プロパティ
    // 例: tagsリストの中から、categoryが.mainCarbであるTagを探し、そのvalue（値）をMainCarb型として返す
    var mainCarb: MainCarb? { tags.first(where: { $0.category == .mainCarb })?.value as? MainCarb }
    var genre: Genre? { tags.first(where: { $0.category == .genre })?.value as? Genre }
    var mainFood: MainFood? { tags.first(where: { $0.category == .mainFood })?.value as? MainFood }
    var taste: Taste? { tags.first(where: { $0.category == .taste })?.value as? Taste }
    var temp: Temp? { tags.first(where: { $0.category == .temp })?.value as? Temp }
    
    //初期化処理
    //Recipeを新しく作るときに、必要な初期値を設定するための関数（init）
    init(name: String, keywords: [String], mainCarb: MainCarb, genre: Genre, mainFood: MainFood, taste: Taste, temp: Temp) {
        self.name = name
        self.keywords = keywords
        
        // 新しいTagの仕様に合わせて、受け取ったenum値をTagのリストに変換して格納
        self.tags = [
            Tag(name: "", iconName: "", category: .mainCarb, value: mainCarb),
            Tag(name: "", iconName: "", category: .genre, value: genre),
            Tag(name: "", iconName: "", category: .mainFood, value: mainFood),
            Tag(name: "", iconName: "", category: .taste, value: taste),
            Tag(name: "", iconName: "", category: .temp, value: temp)
        ]
    }
}
