//
//  ActivityView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct ActivityView: View {

    @State var selectedTab: ActivityTab = .friends
    
    enum ActivityTab: String, CaseIterable, Identifiable{
        case friends = "Friends"
        case you = "You"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()

            //top section
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text("Activity")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(Color.backgroundColor)
                    Spacer()
                }
                .padding()
                .background(Color.textColor)
                
                Picker("Activity Tab", selection: $selectedTab){
                    ForEach(ActivityTab.allCases){tab in
                        Text(tab.rawValue).tag(tab)
                            .foregroundColor(.accentColor)
                    }
                }.pickerStyle(SegmentedPickerStyle())
                
                Spacer()
            }
            
//            VStack(spacing: 0){
//                //picker tab
//                Picker("Activity Tab", selection: $selectedTab){
//                    ForEach(ActivityTab.allCases){tab in
//                        Text(tab.rawValue).tag(tab)
//                            .foregroundColor(.accentColor)
//                    }
//                }.pickerStyle(SegmentedPickerStyle())
//                    .padding(.top, 60)
//                
//                Spacer()
//                List{
//                    ForEach(selectedTab == .friends ? friends : you, id: \.self) { user in
//                        HStack{
//                            
//                            Button(action: {
//                                //visit review/restaurant logic
//                                
//                            }){
//                                HStack{
//                                    //display user pfp
//                                    Image(systemName: "person.circle.fill")
//                                        .foregroundColor(Color.accentColor)
//                            
//                                    //display username
//                                    Text(user)
//                                        .foregroundColor(Color.accentColor)
//                                }
//                            }
//                            Spacer()
//                            
//                            //remove/unfollow logic button
//                            Button(action: {
//                                if selectedTab == .restaurants {
//                                    restaurants.removeAll { $0 == user }
//                                }else{
//                                    reviews.removeAll { $0 == user }
//                                }
//                            }){
//                                Image(systemName: "heart.fill")
//                                    .foregroundColor(.red)
//                            }.buttonStyle(BorderlessButtonStyle())//doesn't extend button to full row
//                        }}
//                }.listRowBackground(Color.backgroundColor)
                
            }
        }
    }

#Preview {
    ActivityView()
}
