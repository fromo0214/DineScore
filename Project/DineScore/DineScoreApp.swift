//
//  DineScoreApp.swift
//  DineScore
//
//  Created by Fernando Romo on 5/28/25.
//

import SwiftUI
import Firebase
import UIKit
import FirebaseAuth



@main
struct DineScoreApp: App {
    @StateObject private var session = UserSession()
    
    init(){
        FirebaseApp.configure()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "AccentColor") ?? .red// active dot
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.gray) // inactive dots
    }
    
    var body: some Scene {
        WindowGroup {
            SplashView()
                .environmentObject(session)
                .onAppear{
                    if Auth.auth().currentUser != nil{
                        session.start()
                    }
                }
        }
    }
}
