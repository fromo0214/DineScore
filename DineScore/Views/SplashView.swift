import SwiftUI

struct SplashView: View {
    @State private var showMainView = false

    var body: some View {
        ZStack {
            if showMainView {
                SignInView()
                    .transition(.opacity)
            } else {
                Color(Color.backgroundColor) // Exact app background
                    .ignoresSafeArea()
                VStack{
                    Image("dineScoreSymbol") // updated image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .transition(.opacity)
                    Text("DineScore")
                        .bold()
                        .foregroundColor(Color.accentColor)
                        .font(.system(size: 70))
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    showMainView = true
                }
            }
        }
    }
}

#Preview {
    SplashView()
}
