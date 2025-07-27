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
                Image("dineScoreSymbol")
                    .resizable()
                    .frame(width:100, height: 100)
                    .scaledToFit()
                    .foregroundColor(Color.accentColor)
            
                Text("DineScore")
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .font(.largeTitle)
                
                TextField("First Name", text: $firstName)
                    .bold()
                    .submitLabel(.next)
                    .focused($focusedField, equals:.firstName)
                    .foregroundColor(Color.accentColor)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: firstName.isEmpty){
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
                
                TextField("Last Name", text: $lastName)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.next)
                    .textFieldStyle(.plain)
                    .focused($focusedField, equals: .lastName)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: lastName.isEmpty){
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
                
                TextField("Email", text: $email)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.next)
                    .disableAutocorrection(true)
                    .focused($focusedField, equals: .email)
                    .autocapitalization(.none)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty){
                        Text("Email")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }.onSubmit {
                        focusedField = .password
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                    
                
                SecureField("Password", text:$password)
                    .foregroundColor(Color.accentColor)
                    .textFieldStyle(.plain)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .password)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: password.isEmpty){
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
                
                SecureField("Confirm Password", text:$confirmPassword)
                    .foregroundColor(Color.accentColor)
                    .textFieldStyle(.plain)
                    .submitLabel(.next)
                    .focused($focusedField, equals: .confirmPassword)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: confirmPassword.isEmpty){
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
                
                TextField("Zip Code", text: $zipCode)
                    .bold()
                    .foregroundColor(Color.accentColor)
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
                    //sign in
                    register()
                    
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
