//
//  UserSocialsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI

struct UserSocialsView: View {
    let currentUser: AppUser
    @ObservedObject var vm = UserProfileViewModel()
    
    init(currentUser: AppUser, vm: UserProfileViewModel) {
           self.currentUser = currentUser
           self.vm = vm
        _followers = State(initialValue: currentUser.followers)
        _following = State(initialValue: currentUser.following)
       }
    
    //dismisses the current view, used for back button
    @Environment(\.dismiss) var dismiss
    
    @State var selectedTab: SocialTab = .followers

    enum SocialTab: String, CaseIterable, Identifiable{
        case followers = "Followers"
        case following = "Following"
        var id: String { self.rawValue }
    }
    
    // hardcode — replace with Firebase user data
    //show pfp, username
    @State private var followers: [AppUser] = []
    @State private var following: [AppUser] = []

    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing:0){
                    //picker tab
                    Picker("Social Tab", selection: $selectedTab){
                        ForEach(SocialTab.allCases){tab in
                            Text(tab.rawValue).tag(tab)
                                .foregroundColor(.accentColor)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding(.top, 5)
                    
                    List{
                        ForEach(selectedTab == .followers ? followers : following, id: \.self) { user in
                            HStack{
                                
                                Button(action: {
                                    //visit profile logic
                                    
                                }){
                                    HStack{
                                        //display user pfp
                                        Image(systemName: "person.circle.fill")
                                            .foregroundColor(Color.accentColor)
                                
                                        //display username
                                        Text(user.firstName)
                                            .foregroundColor(Color.accentColor)
                                    }
                                }
                                Spacer()
                                
                                //remove/unfollow logic button
                                Button(action: {
                                    if selectedTab == .followers {
                                        followers.removeAll { $0 == user }
                                    }else{
                                        following.removeAll { $0 == user }
                                    }
                                }){
                                    Text(selectedTab == .followers ? "Remove" : "Unfollow")
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
                Text("Socials")
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
                            Text("Profile")
                                .foregroundColor(Color.backgroundColor)
                                .bold()
                        }
                    }
                }
        }
    }
}


