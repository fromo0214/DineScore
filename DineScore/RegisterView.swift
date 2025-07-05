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
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var zipCode: String = ""
    @State private var errorMessage: String = ""
    @State private var emailMessage: String = ""
    
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
                Image("dineScoreLogo")
                    .resizable()
                    .frame(width:200, height: 200)
                    .scaledToFit()
                
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(Color.textColor)
                
                TextField("First Name", text: $firstName)
                    .bold()
                    .submitLabel(.next)
                    .focused($focusedField, equals:.firstName)
                    .foregroundColor(Color.textColor)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: firstName.isEmpty){
                        Text("First Name")
                            .foregroundColor(Color.textColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .lastName
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                
                TextField("Last Name", text: $lastName)
                    .bold()
                    .foregroundColor(Color.textColor)
                    .submitLabel(.next)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .lastName)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: lastName.isEmpty){
                        Text("Last Name")
                            .foregroundColor(Color.textColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .email
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                
                TextField("Email", text: $email)
                    .bold()
                    .foregroundColor(Color.textColor)
                    .submitLabel(.next)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .email)
                    .autocapitalization(.none)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty){
                        Text("Email")
                            .foregroundColor(Color.textColor)
                            .bold()
                    }.onSubmit {
                        focusedField = .password
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                    
                
                SecureField("Password", text:$password)
                    .foregroundColor(Color.textColor)
                    .textFieldStyle(.plain)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: password.isEmpty){
                        Text("Password")
                            .foregroundColor(Color.textColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .confirmPassword
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                
                SecureField("Confirm Password", text:$confirmPassword)
                    .foregroundColor(Color.textColor)
                    .textFieldStyle(.plain)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .confirmPassword)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: confirmPassword.isEmpty){
                        Text("Confirm Password")
                            .foregroundColor(Color.textColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = .zipCode
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                
                TextField("Zip Code", text: $zipCode)
                    .bold()
                    .foregroundColor(Color.textColor)
                    .submitLabel(.done)
                    .focused($focusedField, equals: .zipCode)
                    .disableAutocorrection(true)
                    .textFieldStyle(.plain)
                    .onChange(of: zipCode){ oldValue, newValue in
                        //Allow only digits (limit to 5 digits
                        let filtered = newValue.filter{$0.isNumber}
                        if filtered.count > 5 {
                            zipCode = String(filtered.prefix(5))
                        }else{
                            zipCode = filtered
                        }
                    }
                    .placeholder(when: zipCode.isEmpty){
                        Text("Zip Code")
                            .foregroundColor(Color.textColor)
                            .bold()
                    }
                    .onSubmit {
                        focusedField = nil
                    }
                
                
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                
                Button{
                    //sign in
                    register()
                    
                }label:{
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(Color.backgroundColor)
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(Color.textColor)
                        )
                }
               
                if !errorMessage.isEmpty{
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                
                if !emailMessage.isEmpty{
                    Text(emailMessage)
                        .foregroundColor(.blue)
                        .bold()
                        .multilineTextAlignment(.center)
                }
            }.frame(width:350)
            
        }
    }
    
    func register(){
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        guard zipCode.count == 5 else {
            errorMessage = "Please enter a valid 5-digit zip code."
            return
        }
        
        
        Auth.auth().createUser(withEmail: email, password: password){ result, error in
            if let error = error{
                errorMessage = error.localizedDescription
            }
            
            //Sends email verifcation
            result?.user.sendEmailVerification(){ error in
                if let error = error{
                    print("Verification Email error: \(error.localizedDescription)")
                }else{
                    emailMessage = "Email verification sent!"
                    print("Verification email sent!")
                }
                
                //Marks slideshow as not seen
                UserDefaults.standard.set(false, forKey: "hasSeenSlideshow")
                print("New user created, slide show not seen.")
                
            }
        }
    }
}

#Preview {
    RegisterView()
}
