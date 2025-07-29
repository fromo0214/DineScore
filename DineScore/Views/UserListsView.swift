import SwiftUI

struct UserListsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                Text("User Lists View")
            }
            .navigationBarBackButtonHidden(true)
            .navigationTitle("") // Empty title to avoid spacing issues
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.textColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                
                // Custom Back Button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Profile")
                        }
                        .foregroundColor(Color.backgroundColor)
                        .bold()
                    }
                }
                
                // Title
                ToolbarItem(placement: .principal) {
                    Text("My Lists")
                        .foregroundColor(Color.backgroundColor)
                        .bold()
                }
                
                // Add Button
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Add list logic
                    }) {
                        Image(systemName: "plus")
                            .foregroundColor(Color.backgroundColor)
                    }
                }
            }
        }
    }
}
