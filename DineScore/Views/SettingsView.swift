//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("Settings")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.backgroundColor)
                Spacer()
            }
            .padding()
            .background(Color.textColor)
            Button(action: {
                do {
                    try Auth.auth().signOut()
                    userIsLoggedIn = false
                    print("User logged out successfully.")
                }catch{
                    print("Error signing user out.")
                }
            }) {
                Text("Logout")
            }
            Spacer()
        }
    }
    
}

#Preview {
    SettingsView()
}
