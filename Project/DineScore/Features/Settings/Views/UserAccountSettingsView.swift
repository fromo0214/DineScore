//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI
import FirebaseAuth

struct UserAccountSettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    @State var showLevelBadgesView: Bool = false
    @State var showConfirmationMessage: Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {

                        
                    List{
                        
                        settingsButton(title: "View Level & Badges"){
                            //dislay level/badges view
                            
                        }
                        
                        settingsButton(title: "Sign Out"){
                            showConfirmationMessage = true
                        }
                        
                    }.listRowBackground(Color.backgroundColor)
                    
                    
                    
                }
            }
            
            
        }.alert("Are you sure you want to sign out?", isPresented: $showConfirmationMessage){
            Button("Cancel", role: .cancel) { }
            Button ("Sign Out", role: .destructive){
                signOut()
            }
        }
        .navigationBarBackButtonHidden(true)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.textColor, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar{
                
                //custom back button
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        dismiss()
                    }){
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color.backgroundColor)
                                .bold()
                            Text("Settings")
                                .foregroundColor(Color.accentColor)
                                .bold()
                        }
                    }
                }
                
                //navigation title
                ToolbarItem(placement: .principal){
                    Text("Account")
                        .foregroundColor(Color.backgroundColor)
                        .font(.system(size: 20, weight: .bold))
                        .frame(height: 20)
                }
            }

        
    }

    func signOut(){
        do {
            try Auth.auth().signOut()
            userIsLoggedIn = false
            print("User signed out successfully")
        }catch{
            print("Error Signing Out")
        }
    }
    
    
    func settingsButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action){
            HStack{
                Text(title)
                    .font(.system(size: 18))
                    .bold()
                    .foregroundColor(.accentColor)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.accentColor)
                    .bold()
            }.padding()
        }
    }
    
}

