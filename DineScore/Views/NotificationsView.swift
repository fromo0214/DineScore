//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct NotificationsView: View {
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {

                        
                    
                    
                    
                    
                }.padding()
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
                    Text("Notifications")
                        .foregroundColor(Color.backgroundColor)
                        .font(.system(size: 20, weight: .bold))
                        .frame(height: 20)
                }
            }

        
    }
    


    

    
}
