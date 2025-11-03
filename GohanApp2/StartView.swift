import SwiftUI

struct StartView: View {
    var body: some View {
        ZStack {
            // 背景色
            Color.yellow.opacity(0.1).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // アメリちゃんの会話
                ConversationView(message: "今日のごはん、\nどうする？", imageName: "cat_normal")

                Spacer()
                
                // --- 選択肢ボタン ---
                
                // フローAへの入り口
                NavigationLink(destination: SearchView()) {
                    Text("もう決まってる！")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.blue)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                }
                
                // フローBへの入り口
                NavigationLink(destination: SelectTagsView()) {
                    Text("一緒に考えて！")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 3)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}


#Preview {
    NavigationStack {
        StartView()
    }
}
