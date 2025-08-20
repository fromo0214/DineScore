//
//  AddRestaurantView.swift
//  DineScore
//
//  Created by Fernando Romo on 8/19/25.
//

import SwiftUI

struct AddRestaurantView: View {
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(spacing:0){
                Text("Add a restaurant").font(.title)
                    .foregroundColor(.accentColor)
            }
            Spacer()
            VStack{
                Form{
                    
                }
            }
        }
    }
}

#Preview {
    AddRestaurantView()
}
