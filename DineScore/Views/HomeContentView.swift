//
//  HomeContentView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct HomeContentView: View {
    @Binding var searchText: String
    var body: some View {
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
    }
}

