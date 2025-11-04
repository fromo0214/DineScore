//
//  HomeContentView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct HomeContentView: View {
    @State private var showAddRestaurant = false

    @StateObject private var vm = SearchViewModel()
    @State private var selectedUserId: String?
    
    //Transition to a search view
    @State private var isSearching = false
    @State private var searchText: String = ""

    var body: some View {
    
    
        ScrollView{
                VStack{
                    //logo
                    HStack{
                        Image("dineScoreSymbol")
                            .resizable()
                            .frame(width:50, height:50)
                            .padding(.leading, 60)
                            .foregroundColor(Color.accentColor)
                        Text("DineScore")
                            .bold()
                            .foregroundColor(Color.accentColor)
                            .font(.title)
                        Spacer()
                    }
                    .padding(.top, 1)
                    .padding(.leading, 16)
                    
                    //search bar
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color.accentColor)
                        TextField("Search restaurants, dishes, ...", text: $vm.searchText)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .foregroundColor(Color.accentColor)
                            .bold()
                            .placeholder(when: vm.searchText.isEmpty){
                                Text("Search restaurants, dishes, ...")
                                    .foregroundColor(Color.accentColor)
                                    .bold()
                            }
                        
                        
                    }.padding(.leading, 16)
                        .padding(.top, 5)
                    
                    if vm.isLoading{
                        ProgressView().padding(.top, 16)
                    } else if !vm.errorMessage.isEmpty{
                        Text(vm.errorMessage).foregroundColor(.red).padding(.top, 16)
                    } else if vm.results.isEmpty, !vm.searchText.isEmpty{
                        Text("Nothing found!").foregroundColor(.accentColor).padding(.top, 16)
                    }else{
                        LazyVStack(alignment: .leading, spacing: 0){
                            ForEach(vm.results){ user in
                                Button{ selectedUserId = user.id } label:
                                {UserRow(user: user)}
                                Divider()//.padding(.leading, 72)
                            }.padding()
                        }//.padding()
                    }
                      
                    
                    Rectangle()
                        .frame(width: 360, height:1)
                        .foregroundColor(Color.accentColor)
                    
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
                                        .foregroundColor(Color.accentColor)
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
                                        .foregroundColor(Color.accentColor)
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
                                        .foregroundColor(Color.accentColor)
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
                                        .foregroundColor(Color.accentColor)
                                )
                        }
                    }
                    
                    Button{
                        showAddRestaurant = true
                    }label:{
                        Image(systemName: "plus.app.fill")
                            .bold()
                            .font(.system(size:40))
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
                                .foregroundColor(Color.accentColor))
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
                                .foregroundColor(Color.accentColor))
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
                                .foregroundColor(Color.accentColor))
                    }
                }.padding()
                
            .navigationBarBackButtonHidden(true)
                .frame(width: 350)
                .frame(maxWidth: .infinity)
                .sheet(isPresented: $showAddRestaurant){
                    AddRestaurantView()
                }
                .navigationDestination(item:$selectedUserId) { userId in
                    PublicProfileView(userId: userId)
                }
        }
    }
}


