//
//  DineScoreApp.swift
//  DineScore
//
//  Created by Fernando Romo on 5/28/25.
//

import SwiftUI
import Firebase
import UIKit



@main
struct DineScoreApp: App {
    
    init(){
        FirebaseApp.configure()
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor(named: "AccentColor") ?? .red// active dot
        UIPageControl.appearance().pageIndicatorTintColor = UIColor(.gray) // inactive dots
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
