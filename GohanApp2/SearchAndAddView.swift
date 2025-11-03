import SwiftUI

// どのリストを操作するかを示すためのenum
enum ListType {
    case wantToEat
    case notWantToEat
}

struct SearchAndAddView<Destination: View>: View {
    let title: String
    let destinationView: Destination // 遷移先の画面を外から受け取る
    let listType: ListType
    
    @EnvironmentObject var session: DiagnosisSession
    
    @State private var inputText: String = ""
    @State private var searchResults: [Recipe] = []
    
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
                .listStyle(.plain)
                .frame(height: 150)
            }
            
            // --- ③ 選択済みエリア ---
            Text("選択したものリスト")
                .font(.headline)
                .padding(.top)
            
            List {
                ForEach(listType == .wantToEat ? session.wantToEatItems : session.notWantToEatItems) { item in
                    Text(item.name)
                }
                .onDelete(perform: removeItem)
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
        let replacedText = inputText.replacingOccurrences(of: "　", with: " ")
        let keywords = replacedText.split(separator: " ").map { String($0) }
        
        guard !keywords.isEmpty else {
            searchResults = []
            return
        }
        
        searchResults = RecipeDatabase.allRecipes.filter { recipe in
            for keyword in keywords {
                if recipe.name.contains(keyword) || recipe.keywords.contains(keyword) {
                    return true
                }
            }
            return false
        }
    }
    
    private func selectItem(_ recipe: Recipe) {
        if listType == .wantToEat {
            if !session.wantToEatItems.contains(where: { $0.id == recipe.id }) {
                session.wantToEatItems.append(recipe)
            }
        } else {
            if !session.notWantToEatItems.contains(where: { $0.id == recipe.id }) {
                session.notWantToEatItems.append(recipe)
            }
        }
        searchResults = []
        inputText = ""
    }
    
    private func removeItem(at offsets: IndexSet) {
        if listType == .wantToEat {
            session.wantToEatItems.remove(atOffsets: offsets)
        } else {
            session.notWantToEatItems.remove(atOffsets: offsets)
        }
    }
}
