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
    
    let backgroundColor: Color = Color(hex: 0xf9f8f7)
    let textColor: Color = Color(hex: 0x3e4949)
    
    var body: some View {
        ZStack{
            backgroundColor
                .ignoresSafeArea()
            VStack() {
                Image("dineScoreLogo")
                    .resizable()
                    .frame(width:200, height: 200)
                    .scaledToFit()
                
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(textColor)
                
                TextField("First Name", text: $firstName)
                    .bold()
                    .foregroundColor(textColor)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: firstName.isEmpty){
                        Text("First Name")
                            .foregroundColor(textColor)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(textColor)
                
                TextField("Last Name", text: $lastName)
                    .bold()
                    .foregroundColor(textColor)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .placeholder(when: lastName.isEmpty){
                        Text("Last Name")
                            .foregroundColor(textColor)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(textColor)
                
                TextField("Email", text: $email)
                    .bold()
                    .foregroundColor(textColor)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty){
                        Text("Email")
                            .foregroundColor(textColor)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(textColor)
                
                SecureField("Password", text:$password)
                    .foregroundColor(textColor)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: password.isEmpty){
                        Text("Password")
                            .foregroundColor(textColor)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(textColor)
                
                SecureField("Confirm Password", text:$confirmPassword)
                    .foregroundColor(textColor)
                    .textFieldStyle(.plain)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .bold()
                    .placeholder(when: confirmPassword.isEmpty){
                        Text("Confirm Password")
                            .foregroundColor(textColor)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(textColor)
                
                TextField("Zip Code", text: $zipCode)
                    .bold()
                    .foregroundColor(textColor)
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
                            .foregroundColor(textColor)
                            .bold()
                    }
                
                
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(textColor)
                
                Button{
                    //sign in
                    register()
                    
                }label:{
                    Text("Sign Up")
                        .bold()
                        .foregroundColor(backgroundColor)
                        .frame(width: 200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .foregroundColor(textColor)
                        )
                }
                //              Button{
                //                                    //log in
                //                                }label:{
                //                                    Text("Already have an account? Log in!")
                //                                        .foregroundColor(textColor)
                //                                        .underline()
                //                                }
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
                //if user creation is successful and we get a valid user id
                //            else if let uid = result?.user.uid{
                //                //Gets a reference of the firestore database
                //                let db = Firestore.firestore()
                //
                //                // Create a new document in the "users" collection with the user's UID as the document ID
                //                db.collection("users").document(uid).setData([
                //                    "email": email,
                //                    "zipCode": zipCode,
                ////                    "createdAt": TimeStamp()
                //                ]){err in
                //                    if let err = err {
                //                        errorMessage = "Failed to save user data: \(err.localizedDescription)"
                //
                //                    }else{
                //                        print("User registered and data saved!")
                //                    }}
                
            }
        }
    }
}

#Preview {
    RegisterView()
}
