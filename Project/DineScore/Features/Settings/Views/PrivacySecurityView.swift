//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct PrivacySecurityView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedVisibility: ReviewVisibility = .public
    @State private var showBlockedUsers: Bool = false
    
    enum ReviewVisibility: String, CaseIterable, Identifiable{
        case `public` = "Public"
        case friends = "Friends"
        
        var id: String { rawValue }
    }

    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    List{
                        HStack{
                            Text("Account Visibility")
                                .bold()
                                .foregroundColor(Color.accentColor)
                                .font(.system(size: 18))
                                .padding()
                            Picker("Visibility", selection: $selectedVisibility){
                                ForEach(ReviewVisibility.allCases) { visibility in
                                    Text(visibility.rawValue).tag(visibility)
                                }
                            }.pickerStyle(.segmented)
                        }
                        
                        settingsButton(title: "Blocked Users"){
                            showBlockedUsers = true
                        }
                    }.listRowBackground(Color.backgroundColor)
                    }
                    
                }
                
            }
        
        .navigationDestination(isPresented: $showBlockedUsers){
            BlockedUsersView()
        } .navigationBarBackButtonHidden(true)
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
                                .foregroundColor(Color.backgroundColor)
                                .bold()
                        }
                    }
                }
                
                //navigation title
                ToolbarItem(placement: .principal){
                    Text("Privacy & Security")
                        .foregroundColor(Color.backgroundColor)
                        .font(.system(size: 20, weight: .bold))
                        .frame(height: 20)
                }
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
