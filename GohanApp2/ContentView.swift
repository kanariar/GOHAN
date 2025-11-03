import SwiftUI

struct ContentView: View {
    // @StateObjectで、アプリが続く限りずっと存在するDiagnosisSessionのインスタンスを作る
    @StateObject private var diagnosisSession = DiagnosisSession()
    
    var body: some View {
        NavigationStack {
            StartView()
        }
        
        // .environmentObjectで、この中の全てのView（StartViewとその先の画面全て）から
        // diagnosisSessionにアクセスできるようにする
        .environmentObject(diagnosisSession)
    }
}

#Preview {
    ContentView()
}
