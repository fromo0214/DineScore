//
//  HomeView.swift
//  DineScore
//
//  Created by Fernando Romo on 6/6/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @State private var searchText: String = ""
    @State private var selectedTab: AppTab = .home
    
    @AppStorage("hasRequestedNotifications") private var hasRequestedNotifications = false
    
    enum AppTab {
        case home, profile, activity, settings
    }
    
    var body: some View {
        //alignment: .topLeading allows position views in top-left corner
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
        
            Group{
                switch selectedTab {
                case .home:
                    HomeContentView()
                case .profile:
                    UserProfileView()
                case .activity:
                    ActivityView()
                case .settings:
                    SettingsView()
                }
            }
            
            }.safeAreaInset(edge: .bottom, spacing: 12) {
                //Navigation Bar
                HStack {
                    navButton(icon: "house.fill", tab: .home)
                    Spacer()
                    navButton(icon: "person.crop.circle.fill", tab: .profile)
                    Spacer()
                    navButton(icon: "bolt.fill", tab: .activity)
                    Spacer()
                    navButton(icon: "gearshape.fill", tab: .settings)
                }
                .shadow(radius: 5)
                .frame(width:350, height:50)
                .frame(maxWidth: .infinity, alignment: .bottom)
                .background(Color.textColor)
            }
            
        
    }
    
    //used to show current active tab
    func navButton(icon: String, tab: AppTab) -> some View {
            Button(action: {
                selectedTab = tab
            }) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(selectedTab == tab ? Color.backgroundColor : .gray)
            }
        }
    
}

#Preview {
    HomeView()
}
