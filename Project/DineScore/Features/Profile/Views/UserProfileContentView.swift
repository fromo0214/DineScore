//
//  UserProfileContentView.swift
//  DineScore
//
//  Created by Fernando Romo on 8/19/25.
//
import SwiftUI
import PhotosUI

struct UserProfileContentView: View {
    
    let currentUser: AppUser
    @ObservedObject var vm = UserProfileViewModel()
    //profile details
    @State var firstName: String
    @State var lastName: String
    @State var email: String
    @State var zipCode: String
    @State var dob : Date = Date()
    
    init(currentUser: AppUser, vm: UserProfileViewModel) {
        self.currentUser = currentUser
        _vm = ObservedObject(wrappedValue: vm)
        _firstName = State(initialValue: currentUser.firstName)
        _lastName  = State(initialValue: currentUser.lastName)
        _email     = State(initialValue: currentUser.email)
        _zipCode   = State(initialValue: currentUser.zipCode ?? "")
    }
    
    
    
    var body: some View {
        ZStack(alignment: .topLeading){
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading){
                HStack(alignment: .top, spacing: 16){
                    VStack(spacing: 8){
                        //--TODO: CHANGE TO BUTTON
                        Group{
                            if let picked = vm.pickedImage{
                                Image(uiImage: picked)
                                    .resizable()
                                    .scaledToFill()
                            }else if let urlStr = vm.currentUser?.profileImageURL ??
                                        currentUser.profileImageURL,
                                     let url = URL(string: urlStr){
                                AsyncImage(url: url) { img in
                                    img.resizable().scaledToFill()
                                }placeholder: {
                                    Circle().fill(Color.gray.opacity(0.2))
                                }
                            }else{
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color.accentColor)
                            }
                            
                        }
                        .frame(width: 110, height: 110)
                        .clipShape(Circle())
                        
                        PhotosPicker(selection: $vm.selectedPhoto, matching: .images){
                            Label("Change Photo", systemImage: "photo")
                                .font(.footnote)
                        }.onChange(of: vm.selectedPhoto) { _, _ in
                            Task { await vm.loadPickedPhoto() }
                        }
                        
                        Button{
                            Task { await vm.saveProfilePhoto() }
                        } label: {
                            HStack {
                                if vm.isSavingPhoto { ProgressView() }
                                Text("Save Photo")
                            }
                        }
                        .disabled(vm.pickedImage == nil || vm.isSavingPhoto)
                        .buttonStyle(.borderedProminent)
                        
                        if vm.photoSaved{
                            Text("Photo Updated!")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        
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

