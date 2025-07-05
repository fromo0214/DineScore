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

                Image("dineScoreLogo") // updated image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .transition(.opacity)
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
