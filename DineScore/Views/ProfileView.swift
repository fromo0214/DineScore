//
//  ProfileView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        ZStack(alignment: .center){
            VStack{
                Image(systemName: "person.fill")
                    .font(Font.system(size: 100))
            }
        }
    }
}

#Preview {
    ProfileView()
}
