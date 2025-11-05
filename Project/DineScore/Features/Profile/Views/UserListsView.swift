import SwiftUI

struct UserListsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(){
            Color.backgroundColor
                .ignoresSafeArea()
            VStack(alignment: .center, spacing: 0){
                // This header will appear below any parent navigation bar
                HStack {
                    Text("My Lists")
                        .foregroundColor(Color.backgroundColor)
                        .bold()
                    Spacer()
                    Button(action: {
                        // Add list logic
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.backgroundColor)
                            .padding()
                            .bold()
                    }
                }
                .padding(.horizontal)
                .frame(maxWidth: .infinity, minHeight: 44) // typical bar height
                .background(Color.textColor)

                Spacer()
                // Your lists/content go here
            }
        }
    }
}
