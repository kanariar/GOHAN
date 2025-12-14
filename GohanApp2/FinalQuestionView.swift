//選択が少ない時、絞り込むために質問を追加する


import SwiftUI

// 最後の質問を表示し、回答後に結果画面へ遷移するView
struct FinalQuestionView: View {
    // @EnvironmentObject:アプリ全体で共有されているDiagnosisSessionのデータを、
    // このViewで使えるように宣言。データが変更されると画面も自動更新される
    @EnvironmentObject var session: DiagnosisSession
    
    // --- 状態管理 ---
    // @State: このView内でのみ一時的に保持するデータ（状態）を定義する
    // 最後にユーザーに提示する質問の選択肢（Tagのリスト）
    @State private var finalQuestionOptions: [Tag] = []
    //質問をスキップして、結果画面へ強制的に遷移させるためのフラグ（真偽値）
    @State private var shouldSkipToSuggestion = false
    // 質問をスキップした際に、すぐに表示させるレシピ結果を一時的に保持
    // このプロパティは下に定義されている .navigationDestination で使われているが、
    // 質問が表示された場合は使用されないため、少し冗長らしい。。
    // 現状は維持で問題ないが、ロジックが複雑になったら削除しても良いかも
    @State private var finalSuggestions: [Recipe] = []

    var body: some View {
        // ZStack: 複数の部品をZ軸方向に重ねて配置
        ZStack {
            Color.yellow.opacity(0.1).ignoresSafeArea()
            
            VStack {
                // finalQuestionOptionsが空でない（＝質問が生成された）場合
                if !finalQuestionOptions.isEmpty {
                    
                    // --- 質問が表示される場合 ---
                    
                    // 以前定義した「吹き出し」部品を使って質問文を表示
                    ConversationView(message: "なるほどね！\nそれなら…最後の質問！\nどっちの気分？", imageName: "cat_happy")
                    Spacer()
                    // finalQuestionOptionsの各タグ（選択肢）をボタンとして表示
                    ForEach(finalQuestionOptions) { tag in
                        // NavigationLink: タップすると、指定された destinationへ画面を遷移させる
                        NavigationLink(destination: SuggestionView()) {
                            // ボタンの見た目
                            Text(tag.name)
                                .font(.title).fontWeight(.bold).padding()
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(Color.white)
                                .cornerRadius(15).shadow(radius: 3)
                        }
                        // .simultaneousGesture: 画面遷移（NavigationLink）と同時に、別の動作（TapGesture）を実行
                        .simultaneousGesture(TapGesture().onEnded {
                            // タップされたタグを、共有データ（session）のselectedTagsに追加
                            session.selectedTags.insert(tag)
                        })
                    }
                    Spacer()
                } else {
                    // --- 質問生成中の表示 ---
                    ConversationView(message: "うーん、ちょっと待ってね…\n考えてるニャ…", imageName: "cat_normal")
                    Spacer()
                }
            }
            .padding()
        }
        //Viewの共通設定
        .navigationTitle("最後の質問")// 画面上部のタイトル
        .navigationBarTitleDisplayMode(.inline)// タイトルを中央に表示
        .navigationBarBackButtonHidden(true)// 画面左上の「戻るボタン」を非表示にする
        // .onAppear: このViewが表示されたときに一度だけ実行する処理を定義
        .onAppear(perform: generateFinalQuestion)//生成ロジックを呼び出す
        // プログラムから強制的に画面遷移を実行（スキップ処理に利用）
        .navigationDestination(isPresented: $shouldSkipToSuggestion) {
            SuggestionView(predeterminedSuggestions: finalSuggestions)
        }
    }
    
    // --- ロジック （質問生成）---
    
    // 最後の質問の選択肢を生成する関数
    private func generateFinalQuestion() {
        
        // 優先順位：ジャンル > 主食 > メイン食材
        let questionPriorities: [TagCategory] = [.genre, .mainCarb, .mainFood]
        
        // ユーザーが既に選んだタグが属するカテゴリを全て抽出
        let selectedCategories = Set(session.selectedTags.map { $0.category })
        
        // 優先順位リストの中から、まだ選んでいないカテゴリを最初に見つける
        if let questionCategory = questionPriorities.first(where: { !selectedCategories.contains($0) }) {
            // --- ケース1: 未選択の質問カテゴリが見つかった場合 ---
            print("質問を生成します: \(questionCategory)")
            
            // そのカテゴリに属するタグを、AllTagsから全て取得する
            let optionsForCategory = AllTags.list.filter { $0.category == questionCategory }
            
            // 最大2つの選択肢を生成する
            self.finalQuestionOptions = Array(optionsForCategory.prefix(2))
            
            // もし選択肢が2つ未満なら、念のためスキップルートへ
            if self.finalQuestionOptions.count < 2 {
                skipToSuggestionView()
            }
        } else {
            // --- ケース2: 全ての優先カテゴリが選択済みだった場合 ---
            print("主要なカテゴリが全て選択済みのため、質問をスキップします。")
            skipToSuggestionView()
        }
    }
    
    // 質問をスキップして、すぐに結果画面へ遷移させるための関数
    private func skipToSuggestionView() {
        // sessionの診断ロジックを呼び出して、最終結果を作る
        self.finalSuggestions = session.performDiagnosis()
        // 結果画面へ進むためのスイッチをONにする
        self.shouldSkipToSuggestion = true
    }
}

//プレビューテスト
#Preview {
    NavigationStack {
        FinalQuestionView()
            .environmentObject({
                let session = DiagnosisSession()
                session.selectedTags = [
                    AllTags.list.first(where: { $0.name == "がっつり" })!,
                    AllTags.list.first(where: { $0.name == "お肉" })!
                ]
                return session
            }())
    }
}
