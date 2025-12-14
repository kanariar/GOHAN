// ボタンや画像など、アプリのUIを作る機能を使えるようにする
import SwiftUI

//ContentViewの中身
struct ContentView: View {
    // @StateObjectで、アプリが続く限りずっと存在するDiagnosisSessionのインスタンスを作る
    @StateObject private var diagnosisSession = DiagnosisSession()
    
    var body: some View {
        //ここから「画面を重ねて移動できる」エリアがスタート
        //iOS 16以前はNavigationViewだった
        NavigationStack {
            StartView()
        }
        
        // .environmentObjectで、この中の全てのView（StartViewとその先の画面全て）から
        // diagnosisSessionにアクセスできるようにする
        .environmentObject(diagnosisSession)
    }
}

//Xcode右側で即座に確認するためのPreview。アプリ自体には無関係
#Preview {
    ContentView()
}
