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
    @State private var searchText: String = ""

    var body: some View {
        //alignment: .topLeading allows position views in top-left corner
        ZStack(alignment: .topLeading){
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                //logo
                HStack{
                    Image("dineScoreSymbol")
                        .resizable()
                        .frame(width:50, height:50)
                    Text("DineScore")
                        .bold()
                        .foregroundColor(Color.textColor)
                        .font(.title)
                    Spacer()
                }
                .padding(.top, 16)
                .padding(.leading, 16)
                
                //search bar
                HStack{
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color.textColor)
                    TextField("Search restaurants, dishes, ...", text: $searchText)
                        .disableAutocorrection(true)
                        .autocapitalization(.none)
                        .foregroundColor(Color.textColor)
                        .bold()
                        .placeholder(when: searchText.isEmpty){
                            Text("Search restaurants, dishes, ...")
                                .foregroundColor(Color.textColor)
                                .bold()
                        }
                    
                }.padding(.leading, 16)
    
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                
                Spacer()
                
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
            
        }}
}

#Preview {
    HomeView()
}
