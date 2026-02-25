//
//  ContentView.swift
//  DineScore
//
//  Created by Fernando Romo on 5/28/25.
//
import SwiftUI
import Firebase
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit
import FacebookLogin
import UIKit

struct SignInView: View {
    //ViewModel that talks to AuthService
    @StateObject private var vm = SignInViewModel()
    private let authService = AuthService()
    
    //App flags driving navigation
    @AppStorage("userIsLoggedIn") private var userIsLoggedIn = false
    @AppStorage("hasSeenSlideshow") private var hasSeenSlideshow: Bool = false
    
    // View-only state
    @State private var showRegister = false
    @State private var showForgotPassword = false
    @State private var currentNonce: String?
    
    //keyboard focus fields destinations
    enum Field:Hashable {
        case email
        case password
    }
    
    //focusedField var to tab to next fields
    @FocusState private var focusedField: Field?
    
    var body: some View {
        Group{
            if !userIsLoggedIn{
                //go to home screen
                signInScreen
            }
            else if !hasSeenSlideshow{
                SlideshowView()
            }
            //if user is logged in
            else{
                HomeView()
            }
        }
        .onAppear{
            // 🧪 TEMP: Reset flags for clean testing
            UserDefaults.standard.removeObject(forKey: "hasSeenSlideshow")
            UserDefaults.standard.removeObject(forKey: "userIsLoggedIn")
            
            //checks if user is logged in and has seen slideshow or not
            _ = Auth.auth().addStateDidChangeListener{ auth, user in
                if let user = user, (user.isEmailVerified || user.providerData.contains(where: { $0.providerID != "password" })) {
                    print("✅ Firebase Auth Listener: user logged in and verified")
                    print("hasSeenSlideshow = \(hasSeenSlideshow)")
                    if UserDefaults.standard.object(forKey: "hasSeenSlideshow") == nil {
                        UserDefaults.standard.set(false, forKey: "hasSeenSlideshow")
                        print("🆕 First-time login: set hasSeenSlideshow = false")
                    }
                    
                    userIsLoggedIn = true
                } else {
                    print("🔁 Firebase Auth Listener: user not logged in")
                    userIsLoggedIn = false
                }}
            
        }
    }
    
    //sign in form view
    var signInScreen: some View{
        NavigationStack{
            ZStack{
                Color.backgroundColor
                    .ignoresSafeArea()
                VStack() {
                    
                    Image("dineScoreSymbol")
                        .resizable()
                        .frame(width:100, height: 100)
                        .scaledToFit()
                    
                    Text("DineScore")
                        .bold()
                        .font(.largeTitle)
                        .foregroundColor(Color.accentColor)
                        .padding(.bottom, 20)
                    
                    Text("To continue sign in to DineScore!")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Color.accentColor)
                    
                    TextField("Email", text: $vm.email)
                        .bold()
                        .submitLabel(.next)
                        .foregroundColor(Color.accentColor)
                        .textFieldStyle(.plain)
                        .autocapitalization(.none)
                        .focused($focusedField, equals: .email)
                        .disableAutocorrection(true)
                        .placeholder(when: vm.email.isEmpty){
                            Text("Email")
                                .foregroundColor(Color.accentColor)
                                .bold()
                        }
                        .onSubmit{
                            focusedField = .password
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(Color.accentColor)
                    
                    SecureField("Password", text:$vm.password)
                        .foregroundColor(Color.accentColor)
                        .textFieldStyle(.plain)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .bold()
                        .placeholder(when: vm.password.isEmpty){
                            Text("Password")
                                .foregroundColor(Color.accentColor)
                                .bold()
                        }
                        .onSubmit {
                            //dismisses keyboard
                            focusedField = nil
                        }
                    
                    Rectangle()
                        .frame(width: 350, height: 1)
                        .foregroundColor(Color.accentColor)
                    
                    //Sign in button
                    Button{
                        focusedField = nil
                        Task{
                            await vm.signIn()
                            //If authService succeeded, Firebase listener will flip userIsLoggedIn.
                            //Also verify email before proceeding:
                            if let user = Auth.auth().currentUser, user.isEmailVerified{
                                UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
                            } else if Auth.auth().currentUser != nil {
                                vm.errorMessage = "Please verify your email."
                                try? Auth.auth().signOut()
                            }
                        }
                    }label:{
                        HStack{
                            if vm.isLoading { ProgressView() }
                            Text("Sign In")
                        }
                                .bold()
                                .foregroundColor(Color.backgroundColor)
                                .frame(width: 200, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(Color.accentColor)
                                )
                        
                    }
                    
                    //displays error message
                    if !vm.errorMessage.isEmpty{
                        Text(vm.errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button{
                        //registration form view
                        showRegister = true
                    }label:{
                        Text("Don't have an account? Sign up!")
                            .foregroundColor(Color.accentColor)
                            .underline()
                    }
                    Button{
                        //show forgot pasword view
                        showForgotPassword = true
                    }label:{
                        Text("Forgot Password?")
                            .foregroundColor(Color.accentColor)
                            .underline()
                    }
                    Text("Or")
                        .foregroundColor(Color.accentColor)
                        .bold()
                    
                    Button(action: {
                        handleGoogleSignIn()
                    }) {
                        HStack {
                            Image("google_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("Continue with Google")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    }
                    
                    Button(action: {
                        handleFacebookSignIn()
                    }) {
                        HStack {
                            Image("facebook_logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                            
                            Text("Continue with Facebook")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 1)
                        )
                        .background(.white)
                    }
                    
                    SignInWithAppleButton(
                        .signIn,
                        onRequest: { request in
                            request.requestedScopes = [.fullName, .email]
                            let nonce = randomNonceString()
                            currentNonce = nonce
                            request.nonce = sha256(nonce)
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authResults):
                                handleAppleSignIn(authResults)
                            case .failure(let error):
                                print("❌ Authorization failed: \(error.localizedDescription)")
                                vm.errorMessage = error.localizedDescription
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.whiteOutline) // or .white, .whiteOutline
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    
                }.frame(width: 350)
                
            }.navigationDestination(isPresented: $showRegister){
                RegisterView()
            }
            .navigationDestination(isPresented:$showForgotPassword){
                ForgotPasswordView()
            }
        }
    }
    
    
    func handleGoogleSignIn(){
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            vm.errorMessage = "Missing Firebase client ID."
            return
        }
        
        guard let rootVC = rootViewController() else {
            vm.errorMessage = "Unable to start Google sign-in."
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { result, error in
            if let error {
                vm.errorMessage = error.localizedDescription
                return
            }
            
            guard
                let user = result?.user,
                let idToken = user.idToken?.tokenString
            else {
                vm.errorMessage = "Google sign-in failed."
                return
            }
            
            Task {
                do {
                    try await authService.signInWithGoogle(idToken: idToken, accessToken: user.accessToken.tokenString)
                    vm.errorMessage = ""
                    UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
                } catch {
                    vm.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func handleFacebookSignIn(){
        guard let rootVC = rootViewController() else {
            vm.errorMessage = "Unable to start Facebook sign-in."
            return
        }
        
        LoginManager().logIn(permissions: ["public_profile", "email"], from: rootVC) { result, error in
            if let error {
                vm.errorMessage = error.localizedDescription
                return
            }
            
            guard let result = result, !result.isCancelled, let accessToken = AccessToken.current?.tokenString else {
                vm.errorMessage = "Facebook sign-in was cancelled."
                return
            }
            
            Task {
                do {
                    try await authService.signInWithFacebook(accessToken: accessToken)
                    vm.errorMessage = ""
                    UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
                } catch {
                    vm.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func handleAppleSignIn(_ authResults: ASAuthorization) {
        guard
            let credential = authResults.credential as? ASAuthorizationAppleIDCredential,
            let identityToken = credential.identityToken,
            let nonce = currentNonce,
            let idTokenString = String(data: identityToken, encoding: .utf8)
        else {
            vm.errorMessage = "Apple sign-in failed."
            return
        }
        
        Task {
            do {
                try await authService.signInWithApple(idToken: idTokenString, rawNonce: nonce)
                vm.errorMessage = ""
                UserDefaults.standard.set(true, forKey: "userIsLoggedIn")
            } catch {
                vm.errorMessage = error.localizedDescription
            }
        }
    }
    
    func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in UInt8.random(in: 0...255) }
            randoms.forEach { random in
                if remainingLength == 0 { return }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }
    
    
    
}

//Access to hexadecimal colors
extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
        
    }
}

//Colors for application
extension Color{
    static let backgroundColor: Color = Color(hex: 0xf9f8f7)
    static let textColor: Color = Color(hex: 0x3e4949)
    static let accentColor = Color(hex: 0x4b6e7f) // slate blue-gray
}


//placeholder text for fields when empty
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}

//#Preview {
//    SignInView()
//        .onAppear {
//            UserDefaults.standard.set(false, forKey: "userIsLoggedIn")
//            UserDefaults.standard.set(false, forKey: "hasSeenSlideshow")
//        }
//}
