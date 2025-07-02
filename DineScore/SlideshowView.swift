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
    
    
    let slides = [
        SlideshowSlide(title: "Welcome to DineScore!", imageName: "dineScoreLogo", description: "Where food and service deserve their spotlight.", showButton: true),
        SlideshowSlide(title: "Dual Rating System", imageName: "", description: "Great service matters just as great food!"),
        SlideshowSlide(title: "Dish-Specific & Service Tags", imageName: "", description: "Highlight dish reviews and quick tags like 'Friendly', 'Fast', etc."),
        SlideshowSlide(title: "Real-Time Trends", imageName: "", description: "Have access to real time wait times, best visit hours, and service consistency via heat maps!"),
        SlideshowSlide(title: "Earn Badges & Share Your Taste!", imageName: "", description: "Level up your profile by leaving reviews wherever you go!", showButton: true)
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
                                
                                Text(slide.title)
                                    .bold()
                                    .font(.title)
                                    .foregroundColor(Color.textColor)
                                    .multilineTextAlignment(.center)
                                
                                if !slide.imageName.isEmpty{
                                    Image(slide.imageName)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 200, height: 200)
                                }
                                
                                
                                Text(slide.description)
                                    .font(.body)
                                    .fontWeight(.regular)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.textColor)
                                
                                if slides[index].showButton{
                                    if index == slides.count - 1{
                                        Button(action: {
                                            hasSeenSlideshow = true
                                            print("hasSeenSlideshow = \(hasSeenSlideshow)")
                                        }){
                                            Text("Start Reviewing!")
                                        }
                                    }
                                    
//                                    if index == 0 {
//                                        Button(action: {
//                                            //add locations services function
//                                            hasSeenSlideshow = true
//                                        }){
//                                            Text("Get Started!")
//                                        }
//                                    }
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

