//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI
import UserNotifications

struct AppPreferencesView: View {
    
    @State private var notificationsEnabled = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    
                    List{
                        
                        Toggle("Notifications", isOn: $notificationsEnabled)
                        //if switch is toggled then notification will
                            .onChange(of: notificationsEnabled){ newValue, error in
                                if newValue {
                                    requestNotificationPermission()
                                }else{
                                    print("Error with notifications.")
                                }
                            }
                            .bold()
                            .foregroundColor(Color.accentColor)
                            .padding()
                            .font(.system(size: 18))
                        
                        
                        
                        
                    }.listRowBackground(Color.backgroundColor)
                    
                    
                    
                    
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
                                .foregroundColor(Color.accentColor)
                                .bold()
                            
                        }
                    }
                }
                
                //navigation title
                ToolbarItem(placement: .principal){
                    Text("App Preferences")
                        .foregroundColor(Color.backgroundColor)
                        .font(.system(size: 20, weight: .bold))
                        .frame(height: 20)
                        
                }
            }

        
    }
    
    
    //checking user notification settings
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]){ granted, error in
                    DispatchQueue.main.async{
                        if granted {
                            print( "Notification permission granted.")
                        }else{
                            print("Permission Denied")
                            notificationsEnabled = true
                        }
                    }
                }
            case .denied:
                DispatchQueue.main.async {
                    notificationsEnabled = true
                    openSettingsAlert()
                }
            case .authorized, .provisional, .ephemeral:
                print("Already authorized.")
                
            @unknown default:
                break
                
            }
        }
    }
    
    func openSettingsAlert() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }

    
    
    
}
#Preview {
    AppPreferencesView()
}
