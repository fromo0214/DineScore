//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct SupportView: View {
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    List{
                        
                        settingsButton(title: "Contact Support"){
                            
                        }
                        settingsButton(title: "Report A Bug"){
                            
                        }
                        settingsButton(title: "Suggest A Feature (Feedback)"){
                            
                        }
                    }
                        
                    
                    
                    
                    
                }
            }
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
                    Text("Support")
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

