import Foundation

// 各タグがどの種類の絞り込みに対応するかを定義
enum TagCategory: Hashable {
    case mainCarb, genre, mainFood, taste, temp
}

// 画面に表示するタグとその裏側のデータを持つ構造体
struct Tag: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let iconName: String // アイコン名/絵文字を保存するプロパティ
    let isEmoji: Bool     // iconNameが絵文字かどうかを判定するフラグ
    let category: TagCategory
    let value: AnyHashable
    
    // SF Symbol用の初期化メソッド
    init<T: Hashable>(name: String, iconName: String, category: TagCategory, value: T) {
        self.name = name
        self.iconName = iconName
        self.isEmoji = false
        self.category = category
        self.value = value
    }

    // 絵文字用の初期化メソッド
    init<T: Hashable>(name: String, emoji: String, category: TagCategory, value: T) {
        self.name = name
        self.iconName = emoji
        self.isEmoji = true
        self.category = category
        self.value = value
    }
    
    func matches<T>(_ valueToMatch: T?) -> Bool where T: Hashable {
        // 渡された値(valueToMatch)がnilなら、falseを返す
        guard let valueToMatch = valueToMatch else { return false }
        
        // このタグが内部に持っている値(self.value)を、
        // 渡された値と同じ型(T)に変換できるか試す
        guard let storedValue = self.value as? T else { return false }
        
        // 型が同じなら、値が一致するかどうかを比較して返す
        return storedValue == valueToMatch
    }
}
