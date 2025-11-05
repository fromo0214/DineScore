//
//  SettingsView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct NotificationsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var reviewAlerts: Bool = true
    @State private var restaurantRecommendations: Bool = true
    @State private var badgeAlerts: Bool = true
    @State private var waitTimeAlert : Bool = true

    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    List{
                        settingsButton(title: "Review Alerts", isOn: $reviewAlerts){_ in
                            
                        }
                        settingsButton(title: "Restaurant Recommendations", isOn: $restaurantRecommendations){_ in
                            
                        }
                        settingsButton(title: "Badge/Milestone Alert", isOn: $badgeAlerts){_ in
                            
                        }
                        settingsButton(title: "Wait Time Alert\n(Liked Restaurants Only)", isOn: $waitTimeAlert){_ in
                            
                        }
                        
                        
                        
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
                    Text("Notifications")
                        .foregroundColor(Color.backgroundColor)
                        .font(.system(size: 20, weight: .bold))
                        .frame(height: 20)
                }
            }

        
    }
    
    func reviewAlertsNotifications() {
        UserDefaults.standard.set(reviewAlerts, forKey: "reviewAlerts")
    }
    
    
    func settingsButton(title: String, isOn: Binding<Bool>, onToggle: @escaping (Bool) -> Void) -> some View {
        Toggle(title, isOn: isOn)
        //if switch is toggled then notification will
            .onChange(of: isOn.wrappedValue){ newValue, error in
                    onToggle(newValue)
            }
            .bold()
            .foregroundColor(Color.accentColor)
            .padding()
            .font(.system(size: 18))
            .multilineTextAlignment(.leading)
    }
}
