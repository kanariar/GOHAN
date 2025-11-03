import Foundation

struct AllTags {
    static let list: [Tag] = [
        // お腹のすき具合
        Tag(name: "がっつり", emoji: "🔥", category: .taste, value: Taste.gatturi),
        Tag(name: "あっさり", emoji: "🌿", category: .taste, value: Taste.assari),
        Tag(name: "こってり", emoji: "🧀", category: .taste, value: Taste.kotteri), // バターの絵文字
        
        // 主食
        Tag(name: "お米", emoji: "🍚", category: .mainCarb, value: MainCarb.rice),
        Tag(name: "めん", emoji: "🍜", category: .mainCarb, value: MainCarb.noodle),
        Tag(name: "パン", emoji: "🍞", category: .mainCarb, value: MainCarb.bread),
        
        // メイン
        Tag(name: "お肉", emoji: "🍖", category: .mainFood, value: MainFood.meat),
        Tag(name: "お魚", emoji: "🐟", category: .mainFood, value: MainFood.fish),
        Tag(name: "野菜", emoji: "🥕", category: .mainFood, value: MainFood.vegetable),
        
        // ジャンル
        Tag(name: "和食", emoji: "🇯🇵", category: .genre, value: Genre.japanese),
        Tag(name: "洋食", emoji: "🍝", category: .genre, value: Genre.western), // パスタの絵文字
        Tag(name: "中華", emoji: "🇨🇳", category: .genre, value: Genre.chinese),
        
        // 温度
        Tag(name: "あったかい", emoji: "☀️", category: .temp, value: Temp.hot),
        Tag(name: "つめたい", emoji: "❄️", category: .temp, value: Temp.cold)
    ]
}
