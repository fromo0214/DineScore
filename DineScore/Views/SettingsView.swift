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
        Image(systemName: "gearshape.fill")
            .font(Font.system(size: 100))
        
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
    }
    
}

#Preview {
    SettingsView()
}
