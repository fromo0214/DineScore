//
//  UserReviewView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/28/25.
//

import SwiftUI

struct UserReviewView: View {
    
    //dismisses the current view, used for back button
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                Text("User Review View")
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
                    presentationMode.wrappedValue.dismiss()
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
            
            //navigation title
            ToolbarItem(placement: .principal){
                Text("My Reviews")
                    .foregroundColor(Color.backgroundColor)
                    .bold()
            }
            
            //filtering button
            ToolbarItem(placement: .topBarTrailing){
                Button(action: {
                    //sorting func
                }){
                    HStack{
                        Image(systemName: "slider.horizontal.3")
                            .foregroundColor(Color.backgroundColor)
                    }
                }
            }
        }
    }
}

#Preview {
    UserReviewView()
}
