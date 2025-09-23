//
//  UserProfileContentView.swift
//  DineScore
//
//  Created by Fernando Romo on 8/19/25.
//
import SwiftUI

struct UserProfileContentView: View {
    let currentUser: AppUser
    init(currentUser: AppUser, vm: UserProfileViewModel) {
           self.currentUser = currentUser
           self.vm = vm
           _firstName = State(initialValue: currentUser.firstName)
           _lastName  = State(initialValue: currentUser.lastName)
           _email     = State(initialValue: currentUser.email)
           _zipCode   = State(initialValue: currentUser.zipCode ?? "")
       }
    //profile details
    @State var firstName: String
    @State var lastName: String
    @State var email: String
    @State var zipCode: String
    @State var dob : Date = Date()
    
    @ObservedObject var vm = UserProfileViewModel()
    
   
    
    var body: some View {
        ZStack(alignment: .topLeading){
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading){
                HStack{
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
                        Text("Followers: \(currentUser.followers.count)")
                            .foregroundColor(Color.accentColor)
                            .bold()
                            .padding(.bottom, 5)
                        Text("Following: \(currentUser.following.count)")
                            .foregroundColor(Color.accentColor)
                            .bold()
                        
                    }//.padding(.bottom, 60)
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
                        
                        Button("Save"){
                            Task{
                                await vm.updateCurrentUser(firstName: firstName, lastName: lastName, zipCode: zipCode)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading){
                    Text("Recent Activity")
                        .padding()
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.accentColor)
                    
                    Text("More Activity")
                        .padding()
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.accentColor)
                    
                }
            }
            
        }
    }
}


