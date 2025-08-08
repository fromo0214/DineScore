//
//  UserLikesView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI

struct UserLikesView: View {
    
    //dismisses the current view, used for back button
    @Environment(\.dismiss) var dismiss
    
    @State var selectedTab: NavTab = .restaurants

    enum NavTab: String, CaseIterable, Identifiable{
        case restaurants = "Restaurants"
        case reviews = "Reviews"
        var id: String { self.rawValue }
    }
    
    // hardcode — replace with Firebase user data
       @State private var restaurants = ["Restaurant 1", "Restaurant 2", "Restaurant 3"]
       @State private var reviews = ["Review 1", "Review 2", "Review 3"]

    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing:0){
                    //picker tab
                    Picker("Nav Tab", selection: $selectedTab){
                        ForEach(NavTab.allCases){tab in
                            Text(tab.rawValue).tag(tab)
                                .foregroundColor(.accentColor)
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding(.top, 5)
                    
                    List{
                        ForEach(selectedTab == .restaurants ? restaurants : reviews, id: \.self) { user in
                            HStack{
                                
                                Button(action: {
                                    //visit review/restaurant logic
                                    
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
                                    if selectedTab == .restaurants {
                                        restaurants.removeAll { $0 == user }
                                    }else{
                                        reviews.removeAll { $0 == user }
                                    }
                                }){
                                    Image(systemName: "heart.fill")
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
                Text("My Likes")
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


