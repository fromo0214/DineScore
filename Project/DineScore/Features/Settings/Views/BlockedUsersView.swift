//
//  UserSocialsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI

struct BlockedUsersView: View {
    
    //dismisses the current view, used for back button
    @Environment(\.dismiss) var dismiss
    
    
    
    // hardcode — replace with Firebase user data
    //show pfp, username
       @State private var blockedUsers = ["Fernando R.", "Eric R.", "Diego R."]

    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing:0){
                    //picker tab
                    
                    
                    List{
                        ForEach(blockedUsers, id: \.self) { user in
                            HStack{
                                
                                Button(action: {
                                    //visit profile logic
                                    
                                }){
                                    HStack{
                                        //display user pfp
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(Color.accentColor)
                                
                                        //display username
                                        Text(user)
                                            .foregroundColor(Color.accentColor)
                                    }
                                }
                                Spacer()
                                
                                //remove/unfollow logic button
                                Button(action: {
                                        blockedUsers.removeAll { $0 == user }
                                }){
                                    Text("Unblock")
                                        .foregroundColor(.red)
                                }.buttonStyle(BorderlessButtonStyle())//doesn't extend button to full row
                            }}
                    }.listRowBackground(Color.backgroundColor)
                    
                }
            }.scrollContentBackground(.hidden)
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.textColor, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Blocked Users")
                    .foregroundColor(Color.backgroundColor)
                    .bold()
            }
                ToolbarItem(placement: .navigationBarLeading){
                    Button(action: {
                        dismiss()
                    }){
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundColor(Color.backgroundColor)
                            
                            Text("Privacy")
                                .foregroundColor(Color.backgroundColor)
                                .bold()
                        }
                    }
                }
        }
    }
}


