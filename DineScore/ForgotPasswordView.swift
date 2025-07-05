//
//  ForgotPasswordView.swift
//  DineScore
//
//  Created by Fernando Romo on 7/5/25.
//

import SwiftUI
import FirebaseAuth

struct ForgotPasswordView: View {
    @State var email: String = ""
    @State var errorMessage: String = ""
    @State var emailMessage: String = ""
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                Image("dineScoreLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width:200, height: 200)
                
                Text("Input email address to send reset password link!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.textColor)
                    .font(.callout)
                    .bold()
                
                TextField("Email", text: $email)
                    .bold()
                    .foregroundColor(Color.textColor)
                    .submitLabel(.done)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.plain)
                    .placeholder(when: email.isEmpty){
                        Text("Email")
                            .foregroundColor(Color.textColor)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.textColor)
                
                Button{
                    //func to send link to email
                    sendResetLink()
                }label: {
                    Text("Send Reset Link")
                        .bold()
                        .foregroundColor(Color.backgroundColor)
                        .frame(width:200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style:
                                    .continuous)
                                .foregroundColor(Color.textColor)
                        )
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                
                if !emailMessage.isEmpty {
                    Text(emailMessage)
                        .foregroundColor(.blue)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                    
                
            }.frame(width: 350)
        }
       
    }
    
    func sendResetLink(){
        Auth.auth().sendPasswordReset(withEmail: email){ error in
            
            if let error = error as NSError?{
                
                //convert to Firebase AuthErrorCode
                if let errorCode = AuthErrorCode(rawValue: error.code){
                    switch errorCode{
                    case .invalidEmail, .invalidRecipientEmail:
                        errorMessage = "Invalid email address."
                    default:
                        errorMessage = "Something went wrong. Please try again."
                    }
                }else{
                    errorMessage = "Unexpected error occured."
                }
            }else{
                emailMessage = "Password reset link sent!"
                errorMessage = ""
            }
        }
    }

}
#Preview {
    ForgotPasswordView()
}
