//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    
    @State var showAppPreferences = false
    @State var showNotifications = false
    @State var showPrivacySecurity  = false
    @State var showSupport  = false
    @State var showAccountSettings  = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Settings")
                            .font(.system(size: 20, weight: .bold)) // Matches native nav bar
                            .foregroundColor(Color.backgroundColor)
                        Spacer()
                    }
                    .frame(height: 40)
                    .background(Color.textColor)

                    
                    List{
                        
                        settingsButton(title: "App Preferences"){
                            showAppPreferences = true
                        }
                        settingsButton(title: "Notifications"){
                            showNotifications = true
                        }
                        settingsButton(title: "Privacy & Security"){
                            showPrivacySecurity = true
                        }
                        settingsButton(title: "Account"){
                            showAccountSettings = true
                        }
                        settingsButton(title: "Support"){
                            showSupport = true
                        }
                        
                    }.listRowBackground(Color.backgroundColor)
                    
                    
                    
                   
                }
            }.navigationDestination(isPresented: $showAppPreferences){
                AppPreferencesView()
            }
            .navigationDestination(isPresented: $showNotifications){
                NotificationsView()
            }.navigationDestination(isPresented: $showPrivacySecurity){
                PrivacySecurityView()
            }.navigationDestination(isPresented: $showSupport){
                SupportView()
            }.navigationDestination(isPresented: $showAccountSettings){
                AccountSettingsView()
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
            }.padding()
        }
    }
    
}

#Preview {
    SettingsView()
}
