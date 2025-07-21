//
//  HomeView.swift
//  DineScore
//
//  Created by Fernando Romo on 6/6/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @AppStorage("userIsLoggedIn") var userIsLoggedIn: Bool = false
    @State private var searchText: String = ""
    @State private var selectedTab: AppTab = .home
    
    enum AppTab {
        case home, profile, activity, settings
    }
    
    var body: some View {
        //alignment: .topLeading allows position views in top-left corner
        ZStack(alignment: .bottom){
            Color.backgroundColor
                .ignoresSafeArea()
            ScrollView{
                VStack{
                    //logo
                    HStack{
                        Image("dineScoreSymbol")
                            .resizable()
                            .frame(width:50, height:50)
                        Text("DineScore")
                            .bold()
                            .foregroundColor(Color.textColor)
                            .font(.title)
                        Spacer()
                    }
                    .padding(.top, 16)
                    .padding(.leading, 16)
                    
                    //search bar
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.textColor)
                        TextField("Search restaurants, dishes, ...", text: $searchText)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(Color.textColor)
                            .bold()
                            .placeholder(when: searchText.isEmpty){
                                Text("Search restaurants, dishes, ...")
                                    .foregroundColor(Color.textColor)
                                    .bold()
                            }
                        
                    }.padding(.leading, 16)
                    
                    Rectangle()
                        .frame(width: 350, height:1)
                        .foregroundColor(Color.textColor)
                    
                    //search bar buttons
                    HStack{
                        Button{
                            
                        }label:{
                            Text("Food")
                                .bold()
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 60, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.textColor)
                                )
                        }
                        Button{
                            
                        }label:{
                            Text("Service")
                                .bold()
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 70, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.textColor)
                                )
                        }
                        Button{
                            
                        }label:{
                            Text("Nearby")
                                .bold()
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 70, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.textColor)
                                )
                        }
                        Button{
                            
                        }label:{
                            Text("Trending")
                                .bold()
                                .multilineTextAlignment(.center)
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 90, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.textColor)
                                )
                        }
                    }
                    
                    //display restaurants based on their categories
                    HStack{
                        Text("Featured Restaurants")
                            .bold()
                        Spacer()
                    }.padding()
                    VStack{
                        HStack{
                            Text("Featured Restaurants")
                                .foregroundColor(Color.backgroundColor)
                                .frame(width:180,height:80)
                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(Color.textColor))
                        }
                    }.padding()
                    
                    HStack{
                        Text("Top Rated Near You")
                            .bold()
                        Spacer()
                    }.padding()
                    VStack{
                        HStack{
                            Text("Restaurants")
                                .foregroundColor(Color.backgroundColor)
                                .frame(width:150,height:80)
                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(Color.textColor))
                        }
                    }.padding()
                    
                    HStack{
                        Text("Favorited Restaurants")
                            .bold()
                        Spacer()
                    }.padding()
                    
                    VStack{
                        HStack{
                            Text("Favorited Restaurants")
                                .foregroundColor(Color.backgroundColor)
                                .frame(width:180,height:80)
                                .background(RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .foregroundColor(Color.textColor))
                        }
                    }.padding()
                }.navigationBarBackButtonHidden(true)
                    .frame(width: 350)
                    .frame(maxWidth: .infinity)
            }
                    //Navigation bar
            
            Rectangle()
                .frame(width: 500, height: 2)
                .foregroundColor(Color.textColor)
                    HStack {
//                        Rectangle()
//                            .frame(width: 500, height: 2)
//                            .foregroundColor(Color.textColor)
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
                                .frame(maxWidth: .infinity)
                                .padding(.bottom, 20)
                                .background(Color.textColor)
                
                
            }.ignoresSafeArea(edges: .bottom)
        

    }
    
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
