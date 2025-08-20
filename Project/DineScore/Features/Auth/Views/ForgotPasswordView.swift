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
    
    @StateObject private var vm = AuthViewModel()
    
    var body: some View {
        ZStack{
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{
                Image("dineScoreSymbol")
                    .resizable()
                    .scaledToFit()
                    .frame(width:100, height: 100)
                    
                Text("DineScore")
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                
                Text("Input email address to send reset password link!")
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.accentColor)
                    .font(.callout)
                    .bold()
                
                TextField("Email", text: $vm.email)
                    .bold()
                    .foregroundColor(Color.accentColor)
                    .submitLabel(.done)
                    .disableAutocorrection(true)
                    .autocapitalization(.none)
                    .textFieldStyle(.plain)
                    .placeholder(when: vm.email.isEmpty){
                        Text("Email")
                            .foregroundColor(Color.accentColor)
                            .bold()
                    }
                
                Rectangle()
                    .frame(width: 350, height: 1)
                    .foregroundColor(Color.accentColor)
                
                Button{
                    //func to send link to email
                    Task {await vm.sendResetLink() }
                }label: {
                    Text("Send Reset Link")
                        .bold()
                        .foregroundColor(Color.backgroundColor)
                        .frame(width:200, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style:
                                    .continuous)
                                .foregroundColor(Color.accentColor)
                        )
                }
                
                if !vm.errorMessage.isEmpty {
                    Text(vm.errorMessage)
                        .foregroundColor(.red)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                
                if !vm.emailMessage.isEmpty {
                    Text(vm.emailMessage)
                        .foregroundColor(.blue)
                        .bold()
                        .multilineTextAlignment(.center)
                }
                    
                
            }.frame(width: 350)
        }
       
    }

}
#Preview {
    ForgotPasswordView()
}
