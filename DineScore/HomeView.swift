//
//  HomeView.swift
//  DineScore
//
//  Created by Fernando Romo on 6/6/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false

    var body: some View {
        VStack{
            Text("DineScore")
            
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
            
        }.navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
}
