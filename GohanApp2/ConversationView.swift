import SwiftUI

struct ConversationView: View {
    // このViewに表示したいセリフと画像名を外から受け取る
    //letは定数
    let message: String
    let imageName: String
    
    var body: some View {
        // HStack: 複数の部品を「横一列」に並べる
        // alignment: 部品の縦位置を「一番上（.top）」に揃える（画像と吹き出しの上端を揃えるため）
        // spacing: 部品間の横のすき間を「15ポイント」に設定
        HStack(alignment: .top, spacing: 15) {
            // --- ① キャラクター画像 ---
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(Circle()) // 画像を円形に切り抜く
                .overlay(Circle().stroke(Color.gray, lineWidth: 2)) // 円形の枠線
                .shadow(radius: 3) // ちょっとした影

            // --- ② 吹き出し ---
            Text(message)
                .padding(12)
                .font(.title3)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(16)
                // 吹き出しの「しっぽ」を描画
                .overlay(alignment: .leading) {
                    Image(systemName: "arrowtriangle.left.fill")
                        .foregroundColor(Color.gray.opacity(0.15))
                        .offset(x: -10)
                }
            
            Spacer() // 右側の余白を埋める
        }
        .padding()
    }
}

#Preview {
//    VStack {
//        ConversationView(message: "今日の主食は\nどうしますか？", imageName: "cat_normal")
//        ConversationView(message: "なるほど！\nお肉の気分なのですね！", imageName: "cat_happy")
//    }
}
