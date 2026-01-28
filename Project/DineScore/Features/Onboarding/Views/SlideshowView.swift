//
//  SlideshowView.swift
//  DineScore
//
//  Created by Fernando Romo on 6/24/25.
//

import SwiftUI
import CoreLocation

struct SlideshowView: View {
    @AppStorage("hasSeenSlideshow") var hasSeenSlideshow: Bool = false
    @State private var currentIndex: Int = 0
    @State private var showHome: Bool = false
    @State private var isVisible: Bool = false
    @StateObject private var locationManager = LocationManager()
    
    // Computed property for location button text
    private var locationButtonText: String {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            return "Location Enabled"
        case .denied, .restricted:
            return "Location Denied"
        case .notDetermined:
            return "Enable Location Services"
        @unknown default:
            return "Enable Location Services"
        }
    }
    
    // Computed property to check if location is authorized
    private var isLocationAuthorized: Bool {
        locationManager.authorizationStatus == .authorizedWhenInUse || 
        locationManager.authorizationStatus == .authorizedAlways
    }
    
    // Computed property to check if location is denied or restricted
    private var isLocationDeniedOrRestricted: Bool {
        locationManager.authorizationStatus == .denied || 
        locationManager.authorizationStatus == .restricted
    }
    
    // helper func to return sizes of each slide image
    private func imageSize(for index: Int) -> CGSize {
        switch index {
        case 0:
            return CGSize(width: 200, height: 200) // dineScoreLogo
        case 1:
            return CGSize(width: 500, height: 550) // dineScoreReview
        case 2:
            return CGSize(width: 300, height: 300) // dineScoreTags
        case 3:
            return CGSize(width: 400, height: 350) // dineScoreHeatMap
        case 4:
            return CGSize(width: 350, height: 300) // dineScoreProfile
        default:
            return CGSize(width: 200, height: 200)
        }
    }
    
    //slideshow list
    let slides = [
        SlideshowSlide(title: "Welcome to DineScore!", imageName: "dineScoreLogo", description: "Where food and service deserve their spotlight.", showButton: true),
        SlideshowSlide(title: "Dual Rating System", imageName: "dineScoreReview", description: "Great service matters just as great food!"),
        SlideshowSlide(title: "Dish-Specific & Service Tags", imageName: "dineScoreTags", description: "Highlight dish reviews and quick tags like 'Friendly', 'Fast', etc. Include photos, tag dishes, or shout out great staff in your reviews!"),
        SlideshowSlide(title: "Real-Time Trends", imageName: "dineScoreHeatMap", description: "Have access to real time wait times, best visit hours, and service consistency via heat maps!"),
        SlideshowSlide(title: "Earn Badges & Share Your Taste!", imageName: "dineScoreProfile", description: "Level up your profile by leaving reviews wherever you go!", showButton: true)
    ]
    
    
    var body: some View {
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack{
                    TabView(selection: $currentIndex) {
                        ForEach(0..<slides.count, id: \.self) { index in
                            let slide = slides[index]
                            VStack(spacing: 20){
                                
                                //displays slide title
                                Text(slide.title)
                                    .bold()
                                    .font(.title)
                                    .foregroundColor(Color.accentColor)
                                    .multilineTextAlignment(.center)
                                    .opacity(isVisible ? 1: 0)
                                    .scaleEffect(isVisible ? 1 : 0.8)
                                    .animation(.easeOut(duration: 1.0), value: isVisible)
                                    .onAppear{
                                        if index == 0{
                                            isVisible = true
                                        }
                                    }
                                
                                //displays slide image if exists
                                if !slide.imageName.isEmpty {
                                    Image(slide.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: imageSize(for: index).width, height: imageSize(for: index).height)
                                        .opacity(index == 0 ? (isVisible ? 1 : 0) : 1)
                                        .scaleEffect(index == 0 ? (isVisible ? 1 : 0.8) : 1)
                                        .animation(index == 0 ? .easeOut(duration: 1.0) : .none, value: isVisible)
                                }
                                
                                //Displays slideshow description
                                Text(slide.description)
                                    .font(.body)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.accentColor)
                                    .opacity(isVisible ? 1: 0)
                                    .scaleEffect(isVisible ? 1 : 0.8)
                                    .animation(.easeOut(duration: 1.0), value: isVisible)
//                                    .padding(.bottom, 100)
                                
                        
                                // display slideshow button if exists
                                if slide.showButton{
                                    if index == 0 {
                                        Button(action: {
                                            if isLocationDeniedOrRestricted {
                                                // Open Settings if permission was denied
                                                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                                    UIApplication.shared.open(settingsUrl)
                                                }
                                            } else {
                                                locationManager.requestLocationPermission()
                                            }
                                        }){
                                            HStack {
                                                Text(locationButtonText)
                                                if isLocationAuthorized {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                }
                                            }
                                            .opacity(isVisible ? 1: 0)
                                            .scaleEffect(isVisible ? 1 : 0.8)
                                            .animation(.easeOut(duration: 1.0), value: isVisible)
                                        }
                                        .disabled(isLocationAuthorized)
                                    } else if index == 4 {
                                        Button(action: {
                                            hasSeenSlideshow = true
                                            print("hasSeenSlideshow = \(hasSeenSlideshow)")
                                        }){
                                                Text("Start Reviewing!")
                                            }
                                               }
                                    
                                    
                                }
                                
                            }
                            .tag(index)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(width:350)
                    }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                        .ignoresSafeArea()
                }
            }.navigationDestination(isPresented: $showHome){
                HomeView()
            }
        }
    }
}

#Preview {
    SlideshowView()
}

