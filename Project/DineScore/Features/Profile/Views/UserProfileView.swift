//
//  ProfileView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/20/25.
//

import SwiftUI

struct UserProfileView: View {
    
    //profile details
    @State var firstName: String = "Fernando"
    @State var lastName: String = "Romo"
    @State var email: String = "fromo301@yahoo.com"
    @State var zipCode: String = "90247"
    @State var dob : Date = Date()
    
    //shows views
    @State var showUserReviews: Bool = false
    @State var showUserLists: Bool = false
    @State var showUserSocials: Bool = false
    @State var showUserLikes: Bool = false
    

    
    var body: some View {
        NavigationStack{
        ZStack(alignment: .topLeading){
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                HStack{
                    Spacer()
                    VStack{
                        
                        //--TODO: CHANGE TO BUTTON
                        Image(systemName: "person.crop.circle.fill")
                            .foregroundColor(Color.accentColor)
                            .font(Font.system(size:90))
                    
                        
                        Text("Taster 🍴")
                            .bold()
                            .foregroundColor(Color.textColor)
                        Rectangle()
                            .frame(width:100, height: 5)
                            .foregroundColor(Color.accentColor)
                            .padding(.bottom, 5)
                        Text("Followers: 10")
                            .foregroundColor(Color.accentColor)
                            .bold()
                            .padding(.bottom, 5)
                        Text("Following: 10")
                            .foregroundColor(Color.accentColor)
                            .bold()
                        
                    }.padding(.bottom, 60)
                        .padding(.leading)
                    
                    
                    VStack(){
                        Form{
                            Section{
                                TextField("First Name", text: $firstName)
                                TextField("Last Name", text: $lastName)
                                TextField("Email", text: $email)
                                TextField("Zip Code", text: $zipCode)
                                    .onChange(of: zipCode){ oldValue, newValue in
                                        //Allow only digits (limit to 5 digits
                                        let filtered = newValue.filter{$0.isNumber}
                                        if filtered.count > 5 {
                                            zipCode = String(filtered.prefix(5))
                                        }else{
                                            zipCode = filtered
                                        }
                                    }
                                DatePicker("Date of Birth:", selection:$dob, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                            .listRowBackground(Color.white.opacity(0.1))
                        }.frame(width:300, height: 285)
                            .scrollContentBackground(.hidden)
                            .background(Color.backgroundColor)
                            .cornerRadius(10)
                    }
                }
                
            
                    VStack{
                        Button(action: {
                            // show user reviews
                            showUserReviews = true
                        }) {
                            Text("Reviews                                       >")
                                .bold()
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 350, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.accentColor)
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // show user created lists
                            showUserLists = true
                        }) {
                            Text("Lists                                      >")
                                .bold()
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 350, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.accentColor)
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // show user socials
                            showUserSocials = true
                        }) {
                            Text("Socials                                      >")
                                .bold()
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 350, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.accentColor)
                                )
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // show user likes
                            showUserLikes = true
                        }) {
                            Text("Likes                                      >")
                                .bold()
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 350, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .foregroundColor(.accentColor)
                                )
                        }
                        
                        Spacer()
                        
                    }
                    .navigationDestination(isPresented: $showUserReviews){
                        UserReviewView()
                    }
                    .navigationDestination(isPresented: $showUserLists){
                        UserListsView()
                    }.navigationDestination(isPresented: $showUserSocials){
                        UserSocialsView()
                    }.navigationDestination(isPresented: $showUserLikes){
                        UserLikesView()
                    }
                }
            }
        }
    }
}

#Preview {
    UserProfileView()
}
