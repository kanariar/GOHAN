import SwiftUI

// どのリストを操作するかを示すためのenum
//enumについてはDiagnosisSessionで調べた
enum ListType {
    case wantToEat//食べたいものリスト
    case notWantToEat//食べたくないものリスト
}

//レシピを検索・追加する
// <Destination: View> は、遷移先の画面（SuggestionViewなど）の型を外から指定できるようにするための書き方
struct SearchAndAddView<Destination: View>: View {
    let title: String
    let destinationView: Destination // 遷移先の画面を外から受け取る
    let listType: ListType
    
    // @EnvironmentObject:アプリ全体で共有されているDiagnosisSessionのデータを取得
    @EnvironmentObject var session: DiagnosisSession
    
    //@State:ユーザーの入力内容を一時的に保持
    @State private var inputText: String = ""
    //@State:検索ボタンを押した結果を一時的に保持
    @State private var searchResults: [Recipe] = []
    
    //UIの定義
    var body: some View {
        VStack(alignment: .leading) {
            // --- ① 検索エリア ---
            Text(title)
                .font(.title).fontWeight(.bold)
            HStack {
                TextField("キーワードを入力", text: $inputText)
                    .textFieldStyle(.roundedBorder)
                Button("検索") {
                    performSearch()
                }
                .buttonStyle(.borderedProminent)
            }
            
            // --- ② 検索結果エリア ---
            if !searchResults.isEmpty {
                List(searchResults) { recipe in
                    HStack {
                        Text(recipe.name)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectItem(recipe)
                    }
                }
                .listStyle(.plain)//リストのスタイルを枠線なしにする
                .frame(height: 150)
            }
            
            // --- ③ 選択済みエリア ---
            Text("選択したものリスト")
                .font(.headline)
                .padding(.top)
            
            List {
                // ForEach: listTypeに応じて、sessionの wantToEatItems または notWantToEatItems を表示
                ForEach(listType == .wantToEat ? session.wantToEatItems : session.notWantToEatItems) { item in
                    Text(item.name)
                }
                .onDelete(perform: removeItem)// リストの行を左にスワイプしたときに削除関数を実行
            }
            .listStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            )
            
            // --- ④ 次へ進むボタン ---
            NavigationLink(destination: destinationView) {
                 Text("次へ")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    // --- ロジック（関数） ---
    private func performSearch() {
        // 全角スペース(　)を半角スペース( )に置換 キーワード複数入力でユーザーが半角全角どっち使うか分からないから
        let replacedText = inputText.replacingOccurrences(of: "　", with: " ")
        // スペースで区切ってキーワードの配列を作成
        let keywords = replacedText.split(separator: " ").map { String($0) }
        
        // キーワードが空なら検索結果を空にして終了
        guard !keywords.isEmpty else {
            searchResults = []
            return
        }
        // 全レシピをフィルタリング
        searchResults = RecipeDatabase.allRecipes.filter { recipe in
            // ユーザーが入力したキーワードを一つずつチェック
            for keyword in keywords {
                // レシピ名 OR キーワードリストに、検索キーワードが含まれていれば
                if recipe.name.contains(keyword) || recipe.keywords.contains(keyword) {
                    return true// このレシピは残す
                }
            }
            return false// どのキーワードにもマッチしなければ、このレシピは除外
        }
    }
    // 検索結果の項目がタップされたときに実行される関数
    private func selectItem(_ recipe: Recipe) {
        // wantToEatリストに、今選んだレシピがまだ含まれていなければ
        if listType == .wantToEat {
            if !session.wantToEatItems.contains(where: { $0.id == recipe.id }) {
                session.wantToEatItems.append(recipe)// リストに追加
            }
        } else {
            // notWantToEatリストに、今選んだレシピがまだ含まれていなければ
            if !session.notWantToEatItems.contains(where: { $0.id == recipe.id }) {
                session.notWantToEatItems.append(recipe)// リストに追加
            }
        }
        searchResults = []// 選択したら検索結果をクリア
        inputText = ""// 入力欄もクリア
    }
    
    private func removeItem(at offsets: IndexSet) {
        if listType == .wantToEat {
            // offsets（削除されたインデックス）を使って、sessionのリストから要素を削除
            session.wantToEatItems.remove(atOffsets: offsets)
        } else {
            session.notWantToEatItems.remove(atOffsets: offsets)
        }
    }
}
