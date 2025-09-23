//
//  RegisterView.swift
//  DineScore
//
//  Created by Fernando Romo on 6/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @StateObject private var vm = RegisterViewModel()
    
    //keyboard focus fields destinations
    enum Field:Hashable{
        case firstName
        case lastName
        case email
        case password
        case confirmPassword
        case zipCode
    }
    
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            VStack(spacing: 20) {
                Image("dineScoreSymbol")
                    .resizable()
                    .frame(width:100, height: 100)
                    .scaledToFit()
                    .foregroundColor(Color.accentColor)
            
                Text("DineScore")
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .font(.largeTitle)
                
                TextField("First Name", text: $vm.firstName)
                    .bold()
                    .submitLabel(.next)
                    .focused($focusedField, equals:.firstName)
                    .foregroundColor(Color.accentColor)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: vm.firstName.isEmpty){
                        Text("First Name")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .lastName
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                
                TextField("Last Name", text: $vm.lastName)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.next)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .lastName)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: vm.lastName.isEmpty){
                        Text("Last Name")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .email
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                
                TextField("Email", text: $vm.email)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.next)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .email)
                    .autocapitalization(.none)
                    .textFieldStyle(.plain)
                    .placeholder(when: vm.email.isEmpty){
                        Text("Email")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }.onSubmit {
                        focusedField = .password
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                    
                
                SecureField("Password", text:$vm.password)
                    .foregroundColor(Color.accentColor)
                    .textFieldStyle(.plain)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: vm.password.isEmpty){
                        Text("Password")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                
                SecureField("Confirm Password", text:$vm.confirmPassword)
                    .foregroundColor(Color.accentColor)
                    .textFieldStyle(.plain)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .confirmPassword)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: vm.confirmPassword.isEmpty){
                        Text("Confirm Password")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .zipCode
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                
                TextField("Zip Code", text: $vm.zipCode)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .zipCode)
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                    .onChange(of: vm.zipCode){ oldValue, newValue in
                        //Allow only digits (limit to 5 digits
                        let filtered = newValue.filter{$0.isNumber}
                        if filtered.count > 5 {
                            vm.zipCode = String(filtered.prefix(5))
                        }else{
                            vm.zipCode = filtered
                        }
                    }
                    .placeholder(when: vm.zipCode.isEmpty){
                        Text("Zip Code")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = nil
                    }
                
                
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                
                Button{
                    //sign up
                    focusedField = nil
                    Task{
                        await vm.register()
                    }
                    
                }label:{
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(Color.backgroundColor)
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color.accentColor)
                        )
                }
               
                if !vm.errorMessage.isEmpty{
                    Text(vm.errorMessage)
                        .foregroundColor(.red)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                
                if !vm.emailMessage.isEmpty{
                    Text(vm.emailMessage)
                        .foregroundColor(.blue)
                        .bold()
                        .multilineTextAlignment(.center)
                }
            }.frame(width:350)
            
        }
    }
    
   
}

//#Preview {
//    RegisterView()
//}
